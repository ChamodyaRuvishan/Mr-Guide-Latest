-- ========================================
-- Mr. Guide Supabase Database Schema
-- ========================================
-- Run this SQL in Supabase SQL Editor to create the database schema

-- 1. Create profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  role TEXT DEFAULT 'user' CHECK (role IN ('user', 'authentic_user')),
  mobile_number TEXT,
  country_code TEXT,
  country TEXT,
  
  -- Authentic user fields
  title TEXT,
  education TEXT,
  job_title TEXT,
  age INTEGER,
  description TEXT,
  has_business BOOLEAN DEFAULT false,
  business_name TEXT,
  business_type TEXT,
  business_description TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3. Create RLS Policies

-- Policy: Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id);

-- Policy: Allow authenticated users to insert their profile during registration
CREATE POLICY "Users can insert own profile"
  ON public.profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Policy: Public profiles viewable (optional - for viewing other authentic users)
CREATE POLICY "Public can view authentic user profiles"
  ON public.profiles
  FOR SELECT
  USING (role = 'authentic_user');

-- 4. Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. Create trigger for updated_at
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- 6. Create indexes for better performance
CREATE INDEX IF NOT EXISTS profiles_username_idx ON public.profiles(username);
CREATE INDEX IF NOT EXISTS profiles_role_idx ON public.profiles(role);
CREATE INDEX IF NOT EXISTS profiles_email_idx ON public.profiles(email);

-- 7. Grant permissions
GRANT ALL ON public.profiles TO authenticated;
GRANT SELECT ON public.profiles TO anon;

-- ========================================
-- DONE! Your database is ready to use!
-- ========================================
