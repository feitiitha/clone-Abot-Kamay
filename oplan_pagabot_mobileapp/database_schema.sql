-- Create users table for the signup system
-- Copy and paste this SQL into your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    firstname TEXT NOT NULL,
    middlename TEXT,
    lastname TEXT NOT NULL,
    suffix TEXT,
    sex TEXT NOT NULL CHECK (sex IN ('Male', 'Female')),
    birthday TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    address TEXT NOT NULL,
    idnumber TEXT NOT NULL,
    nationality TEXT NOT NULL,
    idtype TEXT NOT NULL,
    mpin TEXT NOT NULL CHECK (LENGTH(mpin) = 4 AND mpin ~ '^[0-9]+$'),
    isverified BOOLEAN DEFAULT FALSE,
    createdat TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create policy so users can only see their own data
CREATE POLICY "Users can view own data" ON public.users
    FOR SELECT USING (auth.uid() = id);

-- Create policy so users can insert their own data
CREATE POLICY "Users can insert own data" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Create policy so users can update their own data
CREATE POLICY "Users can update own data" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- Create index on isverified for filtering verified users
CREATE INDEX IF NOT EXISTS idx_users_isverified ON public.users(isverified);

-- Add comments for documentation
COMMENT ON TABLE public.users IS 'User profiles created through the signup process';
COMMENT ON COLUMN public.users.id IS 'References auth.users(id) - automatically set by Supabase Auth';
COMMENT ON COLUMN public.users.mpin IS '4-digit numeric PIN for app authentication';
COMMENT ON COLUMN public.users.isverified IS 'Admin verification status after account creation';