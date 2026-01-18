-- ============================================
-- LIFEMONK USER DATA SCHEMA
-- ============================================
-- This schema separates auth from app data
-- Auth = Supabase auth.users (authentication only)
-- App = Our custom tables (all profile & state)
-- ============================================

-- ============================================
-- 1. USERS TABLE (Main Profile)
-- ============================================
-- Primary source of truth for user profile data
-- Linked to auth.users via UUID
-- ============================================

CREATE TABLE IF NOT EXISTS public.users (
  -- Primary key matching auth.users.id
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Contact information
  phone TEXT NOT NULL,
  email TEXT,
  
  -- Profile information (collected during onboarding)
  name TEXT NOT NULL,
  school TEXT,
  grade TEXT,
  city TEXT,
  state TEXT,
  language TEXT DEFAULT 'en',
  
  -- User role
  role TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'parent', 'admin')),
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_phone ON public.users(phone);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);

-- Trigger to update updated_at automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 2. USER_APP_STATE TABLE (App-Specific State)
-- ============================================
-- Stores app behavior and progress
-- Separated from profile for cleaner data model
-- ============================================

CREATE TABLE IF NOT EXISTS public.user_app_state (
  -- Foreign key to users table
  user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  
  -- Onboarding state
  onboarding_completed BOOLEAN DEFAULT FALSE NOT NULL,
  onboarding_completed_at TIMESTAMPTZ,
  
  -- Activity tracking
  last_active_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  total_sessions INT DEFAULT 0 NOT NULL,
  
  -- Gamification
  current_level INT DEFAULT 1 NOT NULL,
  xp INT DEFAULT 0 NOT NULL,
  streak_days INT DEFAULT 0 NOT NULL,
  longest_streak INT DEFAULT 0 NOT NULL,
  last_streak_date DATE,
  
  -- Preferences
  theme TEXT DEFAULT 'light' CHECK (theme IN ('light', 'dark', 'auto')),
  notifications_enabled BOOLEAN DEFAULT TRUE NOT NULL,
  sound_enabled BOOLEAN DEFAULT TRUE NOT NULL,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Trigger for updated_at
CREATE TRIGGER user_app_state_updated_at
  BEFORE UPDATE ON public.user_app_state
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 3. FUTURE-READY TABLES (Schema Only)
-- ============================================
-- These demonstrate how to extend the system
-- Implement when features are ready
-- ============================================

-- Workshop Enrollments
CREATE TABLE IF NOT EXISTS public.workshop_enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  workshop_id TEXT NOT NULL,
  enrolled_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  status TEXT DEFAULT 'enrolled' CHECK (status IN ('enrolled', 'completed', 'cancelled')),
  completed_at TIMESTAMPTZ,
  
  -- Prevent duplicate enrollments
  UNIQUE(user_id, workshop_id),
  
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_workshop_enrollments_user ON public.workshop_enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_workshop_enrollments_workshop ON public.workshop_enrollments(workshop_id);

-- Breathing Sessions
CREATE TABLE IF NOT EXISTS public.breathing_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  
  -- Session details
  duration_seconds INT NOT NULL,
  completed BOOLEAN DEFAULT FALSE NOT NULL,
  pattern TEXT NOT NULL, -- e.g., '4-7-8', 'box-breathing'
  
  -- Tracking
  session_date DATE DEFAULT CURRENT_DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_breathing_sessions_user ON public.breathing_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_breathing_sessions_date ON public.breathing_sessions(session_date);

-- Vocabulary Progress
CREATE TABLE IF NOT EXISTS public.vocabulary_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  word_id TEXT NOT NULL,
  
  -- Learning state
  status TEXT DEFAULT 'learning' CHECK (status IN ('learning', 'reviewing', 'mastered')),
  times_reviewed INT DEFAULT 0 NOT NULL,
  last_reviewed_at TIMESTAMPTZ,
  next_review_at TIMESTAMPTZ,
  
  -- Spaced repetition data
  ease_factor DECIMAL(3,2) DEFAULT 2.5,
  interval_days INT DEFAULT 1,
  
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  
  -- Prevent duplicates
  UNIQUE(user_id, word_id)
);

CREATE INDEX IF NOT EXISTS idx_vocabulary_progress_user ON public.vocabulary_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_vocabulary_progress_next_review ON public.vocabulary_progress(next_review_at);

-- ============================================
-- 4. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================
-- Users can only access their own data
-- Admin role can access all data (future)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_app_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workshop_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.breathing_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vocabulary_progress ENABLE ROW LEVEL SECURITY;

-- ============================================
-- USERS TABLE POLICIES
-- ============================================

-- Policy: Users can read their own profile
CREATE POLICY users_select_own
  ON public.users
  FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users can insert their own profile (during signup)
CREATE POLICY users_insert_own
  ON public.users
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY users_update_own
  ON public.users
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Policy: Admin can read all users (future)
CREATE POLICY users_select_admin
  ON public.users
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- USER_APP_STATE TABLE POLICIES
-- ============================================

-- Policy: Users can read their own app state
CREATE POLICY user_app_state_select_own
  ON public.user_app_state
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own app state
CREATE POLICY user_app_state_insert_own
  ON public.user_app_state
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own app state
CREATE POLICY user_app_state_update_own
  ON public.user_app_state
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- WORKSHOP_ENROLLMENTS POLICIES
-- ============================================

CREATE POLICY workshop_enrollments_select_own
  ON public.workshop_enrollments
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY workshop_enrollments_insert_own
  ON public.workshop_enrollments
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY workshop_enrollments_update_own
  ON public.workshop_enrollments
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY workshop_enrollments_delete_own
  ON public.workshop_enrollments
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- BREATHING_SESSIONS POLICIES
-- ============================================

CREATE POLICY breathing_sessions_select_own
  ON public.breathing_sessions
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY breathing_sessions_insert_own
  ON public.breathing_sessions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- VOCABULARY_PROGRESS POLICIES
-- ============================================

CREATE POLICY vocabulary_progress_select_own
  ON public.vocabulary_progress
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY vocabulary_progress_insert_own
  ON public.vocabulary_progress
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY vocabulary_progress_update_own
  ON public.vocabulary_progress
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 5. HELPER FUNCTIONS
-- ============================================

-- Function to create user record after auth signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, phone, email, name, role)
  VALUES (
    NEW.id,
    NEW.phone,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
    'student'
  );
  
  -- Create app state record
  INSERT INTO public.user_app_state (user_id)
  VALUES (NEW.id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-create user records when auth user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 6. ANALYTICS VIEWS (Optional)
-- ============================================

-- View: Active users summary
CREATE OR REPLACE VIEW public.user_stats AS
SELECT
  COUNT(*) AS total_users,
  COUNT(*) FILTER (WHERE uas.onboarding_completed = TRUE) AS onboarded_users,
  COUNT(*) FILTER (WHERE uas.last_active_at > NOW() - INTERVAL '7 days') AS active_weekly,
  COUNT(*) FILTER (WHERE uas.last_active_at > NOW() - INTERVAL '30 days') AS active_monthly
FROM public.users u
LEFT JOIN public.user_app_state uas ON u.id = uas.user_id;

-- ============================================
-- DEPLOYMENT INSTRUCTIONS
-- ============================================
-- 1. Go to Supabase Dashboard → SQL Editor
-- 2. Paste this entire file
-- 3. Run the script
-- 4. Verify tables created under "Table Editor"
-- 5. Check RLS policies under "Authentication → Policies"
-- ============================================

-- ============================================
-- TESTING QUERIES
-- ============================================
-- Run these after schema creation to verify:
--
-- 1. Check tables exist:
-- SELECT table_name FROM information_schema.tables 
-- WHERE table_schema = 'public' 
-- AND table_name IN ('users', 'user_app_state', 'workshop_enrollments');
--
-- 2. Check RLS enabled:
-- SELECT tablename, rowsecurity FROM pg_tables 
-- WHERE schemaname = 'public' 
-- AND tablename IN ('users', 'user_app_state');
--
-- 3. Check policies:
-- SELECT schemaname, tablename, policyname 
-- FROM pg_policies 
-- WHERE schemaname = 'public';
-- ============================================
