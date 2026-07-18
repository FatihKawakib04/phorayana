-- Drop old authenticated-specific policies
DROP POLICY IF EXISTS "Allow select for own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow insert for own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow update for own profile" ON public.profiles;

DROP POLICY IF EXISTS "Allow select for own saved places" ON public.saved_places;
DROP POLICY IF EXISTS "Allow insert for own saved places" ON public.saved_places;
DROP POLICY IF EXISTS "Allow update for own saved places" ON public.saved_places;
DROP POLICY IF EXISTS "Allow delete for own saved places" ON public.saved_places;

DROP POLICY IF EXISTS "Allow select for own trips" ON public.trips;
DROP POLICY IF EXISTS "Allow insert for own trips" ON public.trips;
DROP POLICY IF EXISTS "Allow update for own trips" ON public.trips;

-- Create public (default role) policies, letting auth.uid() handle authentication filtering safely
-- 1. Profiles
CREATE POLICY "Allow select for own profile" ON public.profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY "Allow insert for own profile" ON public.profiles FOR INSERT WITH CHECK (id = auth.uid());
CREATE POLICY "Allow update for own profile" ON public.profiles FOR UPDATE USING (id = auth.uid()) WITH CHECK (id = auth.uid());

-- 2. Saved Places
CREATE POLICY "Allow select for own saved places" ON public.saved_places FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Allow insert for own saved places" ON public.saved_places FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Allow update for own saved places" ON public.saved_places FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Allow delete for own saved places" ON public.saved_places FOR DELETE USING (user_id = auth.uid());

-- 3. Trips
CREATE POLICY "Allow select for own trips" ON public.trips FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Allow insert for own trips" ON public.trips FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Allow update for own trips" ON public.trips FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
