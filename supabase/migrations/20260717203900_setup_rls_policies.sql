-- ponytail: RLS configuration for Phorayana tables
-- Profiles policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own profiles" ON public.profiles
  FOR ALL
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Saved Places policies
ALTER TABLE public.saved_places ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own saved places" ON public.saved_places
  FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Trips policies
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own trips" ON public.trips
  FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
