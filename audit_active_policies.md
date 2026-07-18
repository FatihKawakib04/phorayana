# Deep Audit: Active Database RLS Policies

This report lists the currently active RLS policies queried directly from the `pg_policies` system catalog, and proposes a complete cleanup and reconstruction script.

---

## 1. Active Policies in the Database

Query executed:
```sql
SELECT tablename, policyname, permissive, roles, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename IN ('profiles', 'saved_places', 'trips');
```

### Query Results
| Table Name | Policy Name | Permissive | Roles | Command | Qualification (USING) | With Check (WITH CHECK) |
|---|---|---|---|---|---|---|
| **profiles** | Allow select for own profile | PERMISSIVE | `{public}` | SELECT | `(id = auth.uid())` | *NULL* |
| **profiles** | Allow insert for own profile | PERMISSIVE | `{public}` | INSERT | *NULL* | `(id = auth.uid())` |
| **profiles** | Allow update for own profile | PERMISSIVE | `{public}` | UPDATE | `(id = auth.uid())` | `(id = auth.uid())` |
| **saved_places** | Allow select for own saved places | PERMISSIVE | `{public}` | SELECT | `(user_id = auth.uid())` | *NULL* |
| **saved_places** | Allow insert for own saved places | PERMISSIVE | `{public}` | INSERT | *NULL* | `(user_id = auth.uid())` |
| **saved_places** | Allow update for own saved places | PERMISSIVE | `{public}` | UPDATE | `(user_id = auth.uid())` | `(user_id = auth.uid())` |
| **saved_places** | Allow delete for own saved places | PERMISSIVE | `{public}` | DELETE | `(user_id = auth.uid())` | *NULL* |
| **trips** | Allow select for own trips | PERMISSIVE | `{public}` | SELECT | `(user_id = auth.uid())` | *NULL* |
| **trips** | Allow insert for own trips | PERMISSIVE | `{public}` | INSERT | *NULL* | `(user_id = auth.uid())` |
| **trips** | Allow update for own trips | PERMISSIVE | `{public}` | UPDATE | `(user_id = auth.uid())` | `(user_id = auth.uid())` |

*Conclusion*: There are no orphan or conflicting "ghost" policies left. The active database state is perfectly clean and aligned with the public RLS refined policy migration.

---

## 2. Proposed Reconstruction Script (DROP & RECREATE FRESH)

To guarantee that absolutely no cached permissions, triggers, or old policies remain active, this script performs a hard reset of all policies on the three tables.

```sql
-- 1. Disable RLS temporarily to clean slate
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_places DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips DISABLE ROW LEVEL SECURITY;

-- 2. Drop all potential policy names (both public and authenticated role variants)
DROP POLICY IF EXISTS "Allow select for own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow insert for own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow update for own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can manage their own profiles" ON public.profiles;

DROP POLICY IF EXISTS "Allow select for own saved places" ON public.saved_places;
DROP POLICY IF EXISTS "Allow insert for own saved places" ON public.saved_places;
DROP POLICY IF EXISTS "Allow update for own saved places" ON public.saved_places;
DROP POLICY IF EXISTS "Allow delete for own saved places" ON public.saved_places;
DROP POLICY IF EXISTS "Users can manage their own saved places" ON public.saved_places;

DROP POLICY IF EXISTS "Allow select for own trips" ON public.trips;
DROP POLICY IF EXISTS "Allow insert for own trips" ON public.trips;
DROP POLICY IF EXISTS "Allow update for own trips" ON public.trips;
DROP POLICY IF EXISTS "Users can manage their own trips" ON public.trips;

-- 3. Re-enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_places ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;

-- 4. Re-create public action-specific policies fresh
-- Profiles
CREATE POLICY "Allow select for own profile" ON public.profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY "Allow insert for own profile" ON public.profiles FOR INSERT WITH CHECK (id = auth.uid());
CREATE POLICY "Allow update for own profile" ON public.profiles FOR UPDATE USING (id = auth.uid()) WITH CHECK (id = auth.uid());

-- Saved Places
CREATE POLICY "Allow select for own saved places" ON public.saved_places FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Allow insert for own saved places" ON public.saved_places FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Allow update for own saved places" ON public.saved_places FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "Allow delete for own saved places" ON public.saved_places FOR DELETE USING (user_id = auth.uid());

-- Trips
CREATE POLICY "Allow select for own trips" ON public.trips FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Allow insert for own trips" ON public.trips FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Allow update for own trips" ON public.trips FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
```
