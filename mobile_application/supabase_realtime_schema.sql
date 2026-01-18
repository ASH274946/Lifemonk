-- =====================================================
-- Lifemonk App - Complete Real-time Database Schema
-- =====================================================
-- This schema supports all app features with real-time tracking
-- =====================================================

-- =====================================================
-- USER PROGRESS & ACTIVITY TRACKING
-- =====================================================

-- User profile extensions for app state
CREATE TABLE IF NOT EXISTS public.user_app_state (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    level INTEGER NOT NULL DEFAULT 1,
    xp INTEGER NOT NULL DEFAULT 0,
    streak_days INTEGER NOT NULL DEFAULT 0,
    last_active_date DATE DEFAULT CURRENT_DATE,
    total_sessions INTEGER NOT NULL DEFAULT 0,
    total_time_minutes INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_user_app_state_user_id ON public.user_app_state(user_id);

-- User activity log (for streak calculation and analytics)
CREATE TABLE IF NOT EXISTS public.user_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL, -- 'focus_session', 'workshop', 'byte_viewed', 'chapter_completed', 'quiz_completed'
    activity_id VARCHAR(255), -- ID of the activity (workshop_id, byte_id, etc.)
    xp_earned INTEGER DEFAULT 0,
    duration_minutes INTEGER DEFAULT 0,
    metadata JSONB, -- Additional data about the activity
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_user_activities_user_id ON public.user_activities(user_id);
CREATE INDEX idx_user_activities_user_date ON public.user_activities(user_id, created_at);
CREATE INDEX idx_user_activities_type ON public.user_activities(activity_type);

-- =====================================================
-- CMS CONTENT TABLES
-- =====================================================

-- Categories (Vedic Maths, Geography, etc.)
CREATE TABLE IF NOT EXISTS public.categories (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    icon_type VARCHAR(50) NOT NULL,
    icon_color VARCHAR(20),
    lesson_count INTEGER DEFAULT 0,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Courses (collection of chapters and bytes)
CREATE TABLE IF NOT EXISTS public.courses (
    id VARCHAR(50) PRIMARY KEY,
    category_id VARCHAR(50) REFERENCES public.categories(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    cover_image_url TEXT,
    quiz_available BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chapters within courses
CREATE TABLE IF NOT EXISTS public.chapters (
    id VARCHAR(50) PRIMARY KEY,
    course_id VARCHAR(50) NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    summary TEXT,
    content TEXT,
    video_url TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workshops
CREATE TABLE IF NOT EXISTS public.workshops (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    date_time TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER DEFAULT 60,
    max_participants INTEGER,
    cover_image_url TEXT,
    instructor_name VARCHAR(255),
    tags TEXT[], -- Array of tags
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_workshops_datetime ON public.workshops(date_time);

-- Workshop enrollments
CREATE TABLE IF NOT EXISTS public.workshop_enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    workshop_id VARCHAR(50) NOT NULL REFERENCES public.workshops(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    attended BOOLEAN DEFAULT false,
    attended_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, workshop_id)
);

CREATE INDEX idx_workshop_enrollments_user ON public.workshop_enrollments(user_id);
CREATE INDEX idx_workshop_enrollments_workshop ON public.workshop_enrollments(workshop_id);

-- Focus Sessions
CREATE TABLE IF NOT EXISTS public.focus_sessions (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL,
    icon_type VARCHAR(50),
    audio_url TEXT,
    video_url TEXT,
    instructions TEXT,
    tags TEXT[],
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User focus session completions
CREATE TABLE IF NOT EXISTS public.user_focus_completions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id VARCHAR(50) NOT NULL REFERENCES public.focus_sessions(id) ON DELETE CASCADE,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    duration_minutes INTEGER,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5)
);

CREATE INDEX idx_focus_completions_user ON public.user_focus_completions(user_id);

-- Word of the Day
CREATE TABLE IF NOT EXISTS public.word_of_day (
    id VARCHAR(50) PRIMARY KEY,
    word VARCHAR(255) NOT NULL,
    meaning TEXT NOT NULL,
    example_sentence TEXT,
    pronunciation VARCHAR(255),
    part_of_speech VARCHAR(50),
    date DATE NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_word_of_day_date ON public.word_of_day(date);

-- User progress on courses/chapters
CREATE TABLE IF NOT EXISTS public.user_course_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    course_id VARCHAR(50) NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    chapter_id VARCHAR(50) REFERENCES public.chapters(id) ON DELETE CASCADE,
    progress_percent DECIMAL(5,2) DEFAULT 0, -- 0.00 to 100.00
    completed BOOLEAN DEFAULT false,
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(user_id, course_id, chapter_id)
);

CREATE INDEX idx_user_course_progress_user ON public.user_course_progress(user_id);
CREATE INDEX idx_user_course_progress_course ON public.user_course_progress(course_id);

-- User byte views (for byte section)
CREATE TABLE IF NOT EXISTS public.user_byte_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    byte_path VARCHAR(500) NOT NULL, -- Firebase Storage path
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    watch_duration_seconds INTEGER,
    liked BOOLEAN DEFAULT false
);

CREATE INDEX idx_byte_views_user ON public.user_byte_views(user_id);
CREATE INDEX idx_byte_views_path ON public.user_byte_views(byte_path);

-- =====================================================
-- FUNCTIONS FOR AUTOMATIC UPDATES
-- =====================================================

-- Function to update streak
CREATE OR REPLACE FUNCTION public.update_user_streak()
RETURNS TRIGGER AS $$
DECLARE
    current_streak INTEGER;
    last_active DATE;
BEGIN
    SELECT streak_days, last_active_date INTO current_streak, last_active
    FROM public.user_app_state
    WHERE user_id = NEW.user_id;
    
    -- If activity is from today, no change needed
    IF last_active = CURRENT_DATE THEN
        RETURN NEW;
    END IF;
    
    -- If last active was yesterday, increment streak
    IF last_active = CURRENT_DATE - INTERVAL '1 day' THEN
        UPDATE public.user_app_state
        SET streak_days = streak_days + 1,
            last_active_date = CURRENT_DATE,
            updated_at = NOW()
        WHERE user_id = NEW.user_id;
    -- If gap is more than 1 day, reset streak
    ELSIF last_active < CURRENT_DATE - INTERVAL '1 day' OR last_active IS NULL THEN
        UPDATE public.user_app_state
        SET streak_days = 1,
            last_active_date = CURRENT_DATE,
            updated_at = NOW()
        WHERE user_id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update streak on activity
DROP TRIGGER IF EXISTS trigger_update_streak ON public.user_activities;
CREATE TRIGGER trigger_update_streak
    AFTER INSERT ON public.user_activities
    FOR EACH ROW
    EXECUTE FUNCTION public.update_user_streak();

-- Function to update XP and level
CREATE OR REPLACE FUNCTION public.update_user_xp()
RETURNS TRIGGER AS $$
DECLARE
    new_xp INTEGER;
    new_level INTEGER;
    xp_for_next_level INTEGER;
BEGIN
    -- Update XP
    UPDATE public.user_app_state
    SET xp = xp + NEW.xp_earned,
        total_sessions = total_sessions + 1,
        total_time_minutes = total_time_minutes + COALESCE(NEW.duration_minutes, 0),
        updated_at = NOW()
    WHERE user_id = NEW.user_id
    RETURNING xp, level INTO new_xp, new_level;
    
    -- Calculate level based on XP (100 XP per level)
    xp_for_next_level := new_level * 100;
    
    -- Level up if enough XP
    IF new_xp >= xp_for_next_level THEN
        UPDATE public.user_app_state
        SET level = level + 1,
            updated_at = NOW()
        WHERE user_id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update XP on activity
DROP TRIGGER IF EXISTS trigger_update_xp ON public.user_activities;
CREATE TRIGGER trigger_update_xp
    AFTER INSERT ON public.user_activities
    FOR EACH ROW
    WHEN (NEW.xp_earned > 0)
    EXECUTE FUNCTION public.update_user_xp();

-- Function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to all tables
DROP TRIGGER IF EXISTS set_updated_at ON public.user_app_state;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.user_app_state
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at ON public.categories;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.categories
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at ON public.courses;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.courses
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at ON public.chapters;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.chapters
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at ON public.workshops;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.workshops
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at ON public.focus_sessions;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.focus_sessions
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- ROW LEVEL SECURITY POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.user_app_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workshop_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_focus_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_course_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_byte_views ENABLE ROW LEVEL SECURITY;

-- User app state policies
CREATE POLICY "Users can view own app state" ON public.user_app_state
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own app state" ON public.user_app_state
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own app state" ON public.user_app_state
    FOR UPDATE USING (auth.uid() = user_id);

-- User activities policies
CREATE POLICY "Users can view own activities" ON public.user_activities
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own activities" ON public.user_activities
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Workshop enrollments policies
CREATE POLICY "Users can view own enrollments" ON public.workshop_enrollments
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own enrollments" ON public.workshop_enrollments
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own enrollments" ON public.workshop_enrollments
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own enrollments" ON public.workshop_enrollments
    FOR DELETE USING (auth.uid() = user_id);

-- Focus completions policies
CREATE POLICY "Users can view own focus completions" ON public.user_focus_completions
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own focus completions" ON public.user_focus_completions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Course progress policies
CREATE POLICY "Users can view own progress" ON public.user_course_progress
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own progress" ON public.user_course_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own progress" ON public.user_course_progress
    FOR UPDATE USING (auth.uid() = user_id);

-- Byte views policies
CREATE POLICY "Users can view own byte views" ON public.user_byte_views
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own byte views" ON public.user_byte_views
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Public read access for content tables
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workshops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.focus_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.word_of_day ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Categories are viewable by everyone" ON public.categories
    FOR SELECT USING (is_active = true);
CREATE POLICY "Courses are viewable by everyone" ON public.courses
    FOR SELECT USING (is_active = true);
CREATE POLICY "Chapters are viewable by everyone" ON public.chapters
    FOR SELECT USING (is_active = true);
CREATE POLICY "Workshops are viewable by everyone" ON public.workshops
    FOR SELECT USING (is_active = true);
CREATE POLICY "Focus sessions are viewable by everyone" ON public.focus_sessions
    FOR SELECT USING (is_active = true);
CREATE POLICY "Word of day is viewable by everyone" ON public.word_of_day
    FOR SELECT USING (true);

-- =====================================================
-- GRANT PERMISSIONS
-- =====================================================

GRANT USAGE ON SCHEMA public TO authenticated, anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO anon;

-- =====================================================
-- SAMPLE DATA FOR TESTING
-- =====================================================

-- Insert sample categories
INSERT INTO public.categories (id, title, icon_type, icon_color, lesson_count, sort_order) VALUES
('vedic', 'Vedic Maths', 'mathematics', '#9DB8FF', 28, 1),
('geography', 'Geography', 'geography', '#4A90E2', 24, 2),
('cognitive', 'Cognitive Skills', 'cognitive', '#A855F7', 18, 3),
('applied-math', 'Applied Maths', 'applied_maths', '#FFD58C', 22, 4),
('arts', 'Creative Arts', 'arts', '#FFB2B2', 16, 5),
('science', 'Science', 'science', '#86EFAC', 30, 6),
('language', 'Language Arts', 'language', '#C7E4FF', 25, 7)
ON CONFLICT (id) DO NOTHING;

-- Insert sample focus sessions
INSERT INTO public.focus_sessions (id, title, description, duration_minutes, icon_type, sort_order) VALUES
('breathing', 'Breathing Exercise', 'Calm your mind with simple breathing techniques', 5, 'meditation', 1),
('mindfulness', 'Mindfulness Meditation', 'Practice being present in the moment', 10, 'mindfulness', 2),
('concentration', 'Concentration Builder', 'Improve your focus and attention span', 7, 'focus', 3)
ON CONFLICT (id) DO NOTHING;

-- Insert today's word of the day
INSERT INTO public.word_of_day (id, word, meaning, example_sentence, part_of_speech, date) VALUES
(gen_random_uuid()::text, 'Persistence', 'Continuing firmly despite difficulties or opposition', 
 'Her persistence in learning paid off when she finally mastered the concept.', 
 'noun', CURRENT_DATE)
ON CONFLICT (date) DO NOTHING;

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- View for user dashboard summary
CREATE OR REPLACE VIEW public.user_dashboard_summary AS
SELECT 
    uas.user_id,
    uas.level,
    uas.xp,
    uas.streak_days,
    uas.total_sessions,
    uas.total_time_minutes,
    uas.last_active_date,
    sp.student_name,
    sp.school_name,
    sp.grade,
    COUNT(DISTINCT wf.workshop_id) as enrolled_workshops,
    COUNT(DISTINCT ufc.session_id) as completed_focus_sessions
FROM public.user_app_state uas
LEFT JOIN public.student_profiles sp ON uas.user_id = sp.user_id
LEFT JOIN public.workshop_enrollments we ON uas.user_id = we.user_id
LEFT JOIN public.user_focus_completions ufc ON uas.user_id = ufc.user_id
GROUP BY uas.user_id, uas.level, uas.xp, uas.streak_days, uas.total_sessions, 
         uas.total_time_minutes, uas.last_active_date, sp.student_name, 
         sp.school_name, sp.grade;

COMMENT ON TABLE public.user_app_state IS 'User app progression state - XP, level, streak';
COMMENT ON TABLE public.user_activities IS 'Log of all user activities for analytics and XP calculation';
COMMENT ON TABLE public.categories IS 'Learning categories (Vedic Maths, Geography, etc.)';
COMMENT ON TABLE public.workshops IS 'Available workshops for students';
COMMENT ON TABLE public.focus_sessions IS 'Focus and meditation sessions';
