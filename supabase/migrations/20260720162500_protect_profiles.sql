-- Migration: Protect profiles.role from client-side privilege escalation
-- ponytail: simple trigger to force role='user' on insert and prevent unauthorized changes on update

CREATE OR REPLACE FUNCTION public.protect_profile_role()
RETURNS TRIGGER AS $$
BEGIN
  -- 1. On INSERT: Force role to 'user' if triggered by a client user
  -- (auth.uid() is not null for anon/authenticated API requests)
  IF TG_OP = 'INSERT' THEN
    IF auth.uid() IS NOT NULL THEN
      NEW.role := 'user';
    END IF;
  END IF;

  -- 2. On UPDATE: Prevent role modification unless the old role was already 'god'
  IF TG_OP = 'UPDATE' THEN
    IF auth.uid() IS NOT NULL AND NEW.role IS DISTINCT FROM OLD.role THEN
      IF OLD.role IS DISTINCT FROM 'god' THEN
        NEW.role := OLD.role;
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists to ensure idempotency
DROP TRIGGER IF EXISTS trg_protect_profile_role ON public.profiles;

-- Create the trigger
CREATE TRIGGER trg_protect_profile_role
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.protect_profile_role();
