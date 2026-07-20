// Middleware: god-auth.ts
// Protects the /god-kawakib route — only user with role='god' in profiles may enter.
// Uses direct supabase.auth.getUser() for reliable session access in both SSR and client contexts.

export default defineNuxtRouteMiddleware(async () => {
  const supabase = useSupabaseClient()

  // Get the authenticated user directly from Supabase (works in both SSR and client)
  const { data: { user } } = await supabase.auth.getUser()

  // No session → kick to home
  if (!user) {
    return navigateTo('/')
  }

  // Fetch the user's role from the profiles table
  const { data } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .maybeSingle()

  // Only the 'god' role passes; everyone else is redirected
  if (!data || data.role !== 'god') {
    return navigateTo('/')
  }
})
