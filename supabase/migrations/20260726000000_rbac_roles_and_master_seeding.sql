-- Migration: 20260726000000_rbac_roles_and_master_seeding.sql
-- Description: Clean RBAC migration with roles table, foreign key on profiles, legacy cleanup, and master developer account seeding.

-- Ensure pgcrypto extension is available
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

-- a. Create public.roles table
CREATE TABLE IF NOT EXISTS public.roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(20) UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Grant privileges on public.roles
GRANT SELECT ON public.roles TO anon, authenticated, service_role;
GRANT ALL ON public.roles TO service_role;

-- b. Insert seed data into public.roles
INSERT INTO public.roles (name, description)
VALUES 
  ('god', 'Master Admin'),
  ('user', 'Standard User')
ON CONFLICT (name) DO NOTHING;

-- c. Add Foreign Key column role_id to public.profiles
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'profiles' 
      AND column_name = 'role_id'
  ) THEN
    ALTER TABLE public.profiles ADD COLUMN role_id UUID REFERENCES public.roles(id);
  END IF;
END $$;

-- d. Migrate existing data in public.profiles based on legacy string 'role'
DO $$ 
DECLARE
  v_god_role_id UUID;
  v_user_role_id UUID;
BEGIN
  SELECT id INTO v_god_role_id FROM public.roles WHERE name = 'god';
  SELECT id INTO v_user_role_id FROM public.roles WHERE name = 'user';

  -- If legacy column 'role' still exists, populate role_id based on string value
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'profiles' 
      AND column_name = 'role'
  ) THEN
    UPDATE public.profiles 
    SET role_id = CASE 
      WHEN role = 'god' THEN v_god_role_id
      ELSE v_user_role_id
    END
    WHERE role_id IS NULL;
  END IF;

  -- Ensure any remaining NULL role_id gets user role
  UPDATE public.profiles SET role_id = v_user_role_id WHERE role_id IS NULL;
END $$;

-- e. CLEAN UP: Drop legacy trigger trg_protect_profile_role & function protect_profile_role()
DROP TRIGGER IF EXISTS trg_protect_profile_role ON public.profiles;
DROP FUNCTION IF EXISTS public.protect_profile_role();

-- f. CLEAN UP: Drop legacy column 'role' from public.profiles
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'profiles' 
      AND column_name = 'role'
  ) THEN
    ALTER TABLE public.profiles DROP COLUMN role;
  END IF;
END $$;

-- Make role_id NOT NULL
ALTER TABLE public.profiles ALTER COLUMN role_id SET NOT NULL;

-- g. UPDATE/SEED GOD ACCOUNT
DO $$
DECLARE
  v_god_role_id UUID;
  v_master_user_id UUID;
BEGIN
  SELECT id INTO v_god_role_id FROM public.roles WHERE name = 'god';

  -- Check if kwkbkartono@gmail.com exists, or get existing ID, or create new
  SELECT id INTO v_master_user_id FROM auth.users WHERE email = 'kwkbkartono@gmail.com';

  IF v_master_user_id IS NULL THEN
    v_master_user_id := gen_random_uuid();
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at,
      is_anonymous
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      v_master_user_id,
      'authenticated',
      'authenticated',
      'kwkbkartono@gmail.com',
      extensions.crypt('Kawa18158!', extensions.gen_salt('bf', 10)),
      NOW(),
      '{"provider": "email", "providers": ["email"]}'::jsonb,
      '{"full_name": "Kawakib"}'::jsonb,
      NOW(),
      NOW(),
      false
    );
  ELSE
    UPDATE auth.users
    SET 
      encrypted_password = extensions.crypt('Kawa18158!', extensions.gen_salt('bf', 10)),
      email_confirmed_at = NOW(),
      updated_at = NOW()
    WHERE id = v_master_user_id;
  END IF;

  -- Upsert profile for master developer
  INSERT INTO public.profiles (id, full_name, last_vehicle_used, role_id, updated_at)
  VALUES (v_master_user_id, 'Kawakib', 'motor', v_god_role_id, NOW())
  ON CONFLICT (id) DO UPDATE 
  SET full_name = 'Kawakib', role_id = v_god_role_id, updated_at = NOW();

END $$;
