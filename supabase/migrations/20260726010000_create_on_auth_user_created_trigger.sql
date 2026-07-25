-- Migration: 20260726010000_create_on_auth_user_created_trigger.sql
-- Description: Create PostgreSQL function and trigger on auth.users to automatically provision profile row in public.profiles with default 'user' role upon registration.

-- Function to handle new user registration auto-profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_default_role_id UUID;
BEGIN
  -- Get default role ID for 'user'
  SELECT id INTO v_default_role_id FROM public.roles WHERE name = 'user';

  -- Insert profile for newly registered user
  INSERT INTO public.profiles (id, full_name, role_id, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    v_default_role_id,
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists to ensure idempotency
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger on auth.users table
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
