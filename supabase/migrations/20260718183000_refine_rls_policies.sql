-- 1. Drop existing unified policies
DROP POLICY IF EXISTS "Users can manage their own profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can manage their own saved places" ON public.saved_places;
DROP POLICY IF EXISTS "Users can manage their own trips" ON public.trips;

-- 2. Define explicit policies for public.profiles
CREATE POLICY "Allow select for own profile" ON public.profiles FOR SELECT TO authenticated USING (id = auth.uid());
CREATE POLICY "Allow insert for own profile" ON public.profiles FOR INSERT TO authenticated WITH CHECK (id = auth.uid());
CREATE POLICY "Allow update for own profile" ON public.profiles FOR UPDATE TO authenticated USING (id = auth.uid()) WITH CHECK (id = auth.uid());

-- 3. Define explicit policies for public.saved_places
CREATE POLICY "Allow select for own saved places" ON public.saved_places FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "Allow insert for own saved places" ON public.saved_places FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "Allow update for own saved places" ON public.saved_places FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Allow delete for own saved places" ON public.saved_places FOR DELETE TO authenticated USING (user_id = auth.uid());

-- 4. Define explicit policies for public.trips
CREATE POLICY "Allow select for own trips" ON public.trips FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "Allow insert for own trips" ON public.trips FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "Allow update for own trips" ON public.trips FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
