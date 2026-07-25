// Middleware: god-auth.ts
// Protects the /god-kawakib route — only users with role_id matching 'god' in public.roles may enter.
// Uses direct supabase.auth.getUser() for reliable session access in both SSR and client contexts.

export default defineNuxtRouteMiddleware(async () => {
  const supabase = useSupabaseClient()

  // Get the authenticated user directly from Supabase (works in both SSR and client)
  const { data: { user } } = await supabase.auth.getUser()

  // No session → kick to home
  if (!user) {
    return navigateTo('/')
  }

  // Fetch the user's profile with joined role name from public.roles
  const { data } = await (supabase
    .from('profiles')
    .select('role_id, roles(name)')
    .eq('id', user.id)
    .maybeSingle() as any)

  const roleName = data?.roles?.name || (Array.isArray(data?.roles) ? (data?.roles as any)[0]?.name : null)

  // Only the 'god' role passes; everyone else is redirected
  if (roleName !== 'god') {
    return navigateTo('/')
  }
})



