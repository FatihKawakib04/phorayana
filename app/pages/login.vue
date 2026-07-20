<template>
  <div class="min-h-screen flex flex-col md:grid md:grid-cols-2 bg-phorayana-base text-phorayana-text-primary">
    <!-- Branding Panel (Left on Desktop, Top on Mobile) -->
    <div class="flex flex-col justify-between p-8 md:p-16 border-b md:border-b-0 md:border-r border-phorayana-border">
      <div>
        <div class="flex items-center gap-2">
          <!-- Phorayana Logo (Simple Solid Square icon) -->
          <div class="w-8 h-8 bg-phorayana-primary flex items-center justify-center font-bold text-lg text-phorayana-text-primary rounded-lg border-2 border-black">
            P
          </div>
          <span class="text-xl font-bold tracking-wider uppercase">Phorayana</span>
        </div>
      </div>

      <div class="my-12 md:my-auto">
        <h1 class="text-3xl md:text-5xl font-extrabold leading-tight tracking-tight">
          From User, <br class="hidden md:inline" />For User.
        </h1>
        <p class="mt-4 text-phorayana-text-secondary max-w-md text-sm md:text-base leading-relaxed">
          Phorayana is a crowdsourced micro-scale travel duration logging platform. 
          Help your commuter community by recording route durations, enriched automatically with weather and local event context.
        </p>
      </div>

      <div class="text-xs text-phorayana-text-secondary">
        &copy; 2026 Phorayana. Locked for sandboxed development.
      </div>
    </div>

    <!-- Auth Form Panel (Right on Desktop, Bottom on Mobile) -->
    <div class="flex items-center justify-center p-6 md:p-16">
      <div class="w-full max-w-md bg-phorayana-surface border-2 border-black p-8 rounded-2xl shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
        <h2 class="text-2xl font-bold text-phorayana-text-primary mb-2">
          {{ isLogin ? 'Masuk ke Phorayana' : 'Buat Akun Baru' }}
        </h2>
        <p class="text-xs text-phorayana-text-secondary mb-6">
          {{ isLogin ? 'Catat durasi perjalananmu dan bantu pengguna lain.' : 'Mulai bergabung dengan ekosistem data perjalanan komunal.' }}
        </p>

        <!-- Error & Success Message Banner -->
        <div 
          v-if="errorMessage" 
          class="bg-phorayana-alert/15 border-2 border-black text-phorayana-alert p-3 mb-4 text-xs font-bold rounded-xl animate-pulse"
        >
          {{ errorMessage }}
        </div>
        <div 
          v-if="successMessage" 
          class="bg-phorayana-accent/15 border-2 border-black text-phorayana-accent p-3 mb-4 text-xs font-bold rounded-xl"
        >
          {{ successMessage }}
        </div>

        <form @submit.prevent="handleAuth" class="space-y-4">
          <div>
            <label for="email" class="block text-xs font-bold uppercase tracking-wider text-phorayana-text-secondary mb-1">
              Email Address
            </label>
            <input 
              v-model="email" 
              type="email" 
              id="email" 
              required
              placeholder="nama@email.com"
              class="w-full bg-phorayana-base border-2 border-black text-phorayana-text-primary p-3 text-sm focus:outline-none focus:border-phorayana-primary rounded-xl transition-colors"
            />
          </div>

          <div>
            <label for="password" class="block text-xs font-bold uppercase tracking-wider text-phorayana-text-secondary mb-1">
              Password
            </label>
            <input 
              v-model="password" 
              type="password" 
              id="password" 
              required
              placeholder="••••••••"
              class="w-full bg-phorayana-base border-2 border-black text-phorayana-text-primary p-3 text-sm focus:outline-none focus:border-phorayana-primary rounded-xl transition-colors"
            />
          </div>

          <div v-if="!isLogin">
            <label for="confirmPassword" class="block text-xs font-bold uppercase tracking-wider text-phorayana-text-secondary mb-1">
              Confirm Password
            </label>
            <input 
              v-model="confirmPassword" 
              type="password" 
              id="confirmPassword" 
              required
              placeholder="••••••••"
              class="w-full bg-phorayana-base border-2 border-black text-phorayana-text-primary p-3 text-sm focus:outline-none focus:border-phorayana-primary rounded-xl transition-colors"
            />
          </div>

          <button 
            type="submit" 
            :disabled="isLoading"
            class="w-full bg-phorayana-primary text-phorayana-text-primary border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:bg-[#b02f2d] active:translate-x-1 active:translate-y-1 active:shadow-none font-bold p-3 text-sm transition-all duration-150 uppercase tracking-wider disabled:opacity-50 disabled:cursor-not-allowed rounded-xl"
          >
            {{ isLoading ? 'Memproses...' : (isLogin ? 'Masuk' : 'Daftar') }}
          </button>
        </form>

        <div class="mt-6 pt-6 border-t border-phorayana-border text-center">
          <p class="text-xs text-phorayana-text-secondary">
            {{ isLogin ? 'Belum punya akun?' : 'Sudah memiliki akun?' }}
            <button 
              type="button" 
              @click="toggleMode"
              class="text-phorayana-primary hover:text-phorayana-accent font-semibold ml-1 focus:outline-none transition-colors"
            >
              {{ isLogin ? 'Daftar Sekarang' : 'Masuk di Sini' }}
            </button>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()

// Redirect to dashboard if user is already logged in
watchEffect(() => {
  if (user.value) {
    router.replace('/')
  }
})

const isLogin = ref(true)
const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const isLoading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

const toggleMode = () => {
  isLogin.value = !isLogin.value
  errorMessage.value = ''
  successMessage.value = ''
  password.value = ''
  confirmPassword.value = ''
}

const handleAuth = async () => {
  isLoading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    if (isLogin.value) {
      // Handle Login
      const { error } = await supabase.auth.signInWithPassword({
        email: email.value,
        password: password.value
      })
      if (error) throw error
      router.replace('/')
    } else {
      // Handle Register
      if (password.value !== confirmPassword.value) {
        throw new Error('Konfirmasi password tidak cocok!')
      }
      
      const config = useRuntimeConfig()
      const { error } = await supabase.auth.signUp({
        email: email.value,
        password: password.value,
        options: {
          emailRedirectTo: `${config.public.appUrl}/confirm`
        }
      })
      if (error) throw error
      successMessage.value = 'Registrasi berhasil! Silakan cek email Anda untuk konfirmasi atau langsung masuk jika auto-confirm aktif.'
      // Reset form fields
      email.value = ''
      password.value = ''
      confirmPassword.value = ''
      isLogin.value = true
    }
  } catch (error) {
    errorMessage.value = error.message || 'Terjadi kesalahan sistem'
  } finally {
    isLoading.value = false
  }
}
</script>
