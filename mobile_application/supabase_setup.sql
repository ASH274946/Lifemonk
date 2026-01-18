-- =====================================================
-- Lifemonk App - Supabase Database Setup
-- =====================================================
-- This script creates all necessary tables and policies
-- for the Lifemonk student learning app
-- =====================================================

-- =====================================================
-- 1. STUDENT PROFILES TABLE
-- =====================================================
-- Stores student information collected during onboarding

CREATE TABLE IF NOT EXISTS public.student_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    student_name VARCHAR(255) NOT NULL,
    school_name VARCHAR(255) NOT NULL,
    grade VARCHAR(50) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure one profile per user
    CONSTRAINT unique_user_profile UNIQUE (user_id)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_student_profiles_user_id 
ON public.student_profiles(user_id);

-- Add comment for documentation
COMMENT ON TABLE public.student_profiles IS 'Student profile information collected during onboarding';

-- =====================================================
-- 2. ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================
-- Enable RLS to protect user data

-- Enable RLS on student_profiles
ALTER TABLE public.student_profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view only their own profile
CREATE POLICY "Users can view their own profile" 
ON public.student_profiles
FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can insert their own profile
CREATE POLICY "Users can insert their own profile" 
ON public.student_profiles
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update their own profile" 
ON public.student_profiles
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own profile
CREATE POLICY "Users can delete their own profile" 
ON public.student_profiles
FOR DELETE
USING (auth.uid() = user_id);

-- =====================================================
-- 3. UPDATED_AT TRIGGER
-- =====================================================
-- Automatically update the updated_at timestamp

-- Create or replace the trigger function
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for student_profiles
DROP TRIGGER IF EXISTS set_updated_at ON public.student_profiles;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.student_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- 4. GRANT PERMISSIONS
-- =====================================================
-- Grant necessary permissions for authenticated users

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON public.student_profiles TO authenticated;

-- =====================================================
-- 5. SAMPLE DATA (Optional - for testing)
-- =====================================================
-- Uncomment below to insert sample data for testing

/*
INSERT INTO public.student_profiles (
    user_id,
    student_name,
    school_name,
    grade,
    city,
    state
) VALUES (
    'REPLACE_WITH_YOUR_USER_ID', -- Replace with actual user ID from auth.users
    'Test Student',
    'Test School',
    'Class 8',
    'Mumbai',
    'Maharashtra'
);
*/

-- =====================================================
-- 6. VERIFICATION QUERIES
-- =====================================================
-- Run these queries to verify the setup

-- Check if table exists
-- SELECT table_name FROM information_schema.tables 
-- WHERE table_schema = 'public' AND table_name = 'student_profiles';

-- Check RLS policies
-- SELECT * FROM pg_policies WHERE tablename = 'student_profiles';

-- Count profiles
-- SELECT COUNT(*) FROM public.student_profiles;

-- =====================================================
-- SETUP COMPLETE! 🎉
-- =====================================================
-- Now your Flutter app can store student data in Supabase
-- =====================================================
