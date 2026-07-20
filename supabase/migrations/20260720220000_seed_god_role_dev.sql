-- Migration: Set developer god role for Fatih's test account
-- This migration is for local development only.
-- It grants service_role access to profiles and seeds the god role for the test user.

-- Grant necessary privileges to service_role so Supabase admin tools can manage profiles
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO service_role;

-- Set the testuser's role to 'god' directly via SQL to bypass the RLS trigger
-- (The trigger checks auth.uid() which is NULL for direct SQL execution, so this will succeed)
UPDATE public.profiles
SET role = 'god'
WHERE id IN (
  SELECT id FROM auth.users WHERE email = 'testuser@example.com'
);

