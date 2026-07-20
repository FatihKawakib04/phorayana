-- Migration: Set developer god role for Fatih's test account
-- This migration is for local development only.
-- It grants service_role access to profiles and seeds the god role for the test user.

-- Ensure pgcrypto is enabled
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

-- Seed test user into auth.users if not exists
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token,
  is_anonymous
)
SELECT 
  '00000000-0000-0000-0000-000000000000',
  'a3d90f23-8cfb-4a57-b501-4475459223e7',
  'authenticated',
  'authenticated',
  'testuser@example.com',
  extensions.crypt('Password123!', extensions.gen_salt('bf', 10)),
  now(),
  NULL,
  NULL,
  '{"provider": "email", "providers": ["email"]}'::jsonb,
  '{}'::jsonb,
  now(),
  now(),
  '',
  '',
  '',
  '',
  false
WHERE NOT EXISTS (
  SELECT 1 FROM auth.users WHERE email = 'testuser@example.com'
);

-- Seed profile for test user if not exists
INSERT INTO public.profiles (
  id,
  full_name,
  last_vehicle_used,
  role,
  updated_at
)
SELECT 
  'a3d90f23-8cfb-4a57-b501-4475459223e7',
  'Test User',
  'motor',
  'user',
  now()
WHERE EXISTS (
  SELECT 1 FROM auth.users WHERE email = 'testuser@example.com'
) AND NOT EXISTS (
  SELECT 1 FROM public.profiles WHERE id = 'a3d90f23-8cfb-4a57-b501-4475459223e7'
);

-- Grant necessary privileges to service_role so Supabase admin tools can manage profiles
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO service_role;

-- Set the testuser's role to 'god' directly via SQL to bypass the RLS trigger
-- (The trigger checks auth.uid() which is NULL for direct SQL execution, so this will succeed)
UPDATE public.profiles
SET role = 'god'
WHERE id IN (
  SELECT id FROM auth.users WHERE email = 'testuser@example.com'
);


