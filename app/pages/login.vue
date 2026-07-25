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
        <!-- Dynamic Heading -->
        <h2 class="text-2xl font-bold text-phorayana-text-primary mb-2">
          <template v-if="isLogin">Masuk ke Phorayana</template>
          <template v-else-if="authStep === 'otp'">Verifikasi Kode OTP</template>
          <template v-else>Buat Akun Baru</template>
        </h2>

        <!-- Dynamic Subtitle -->
        <p class="text-xs text-phorayana-text-secondary mb-6">
          <template v-if="isLogin">Catat durasi perjalananmu dan bantu pengguna lain.</template>
          <template v-else-if="authStep === 'otp'">Masukkan 6-digit kode OTP yang kami kirimkan ke {{ email }}.</template>
          <template v-else>Mulai bergabung dengan ekosistem data perjalanan komunal.</template>
        </p>

        <!-- Error & Success Message Banners -->
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

        <!-- FORM STATE 1: LOGIN or REGISTER INPUT FORM -->
        <form v-if="isLogin || authStep === 'form'" @submit.prevent="handleAuth" class="space-y-4">
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
            {{ isLoading ? 'Memproses...' : (isLogin ? 'Masuk' : 'Daftar & Kirim OTP') }}
          </button>
        </form>

        <!-- FORM STATE 2: OTP 6-DIGIT VERIFICATION IN-CARD FORM (NO POPUP) -->
        <form v-else-if="!isLogin && authStep === 'otp'" @submit.prevent="handleVerifyOtp" class="space-y-4">
          <div>
            <label for="otpToken" class="block text-xs font-bold uppercase tracking-wider text-phorayana-text-secondary mb-1">
              Kode OTP (6-Digit Angka)
            </label>
            <input 
              ref="otpInputRef"
              v-model="otpToken" 
              type="text" 
              id="otpToken" 
              required
              maxlength="6"
              inputmode="numeric"
              autocomplete="one-time-code"
              placeholder="123456"
              @input="onOtpInput"
              @paste="onOtpPaste"
              class="w-full bg-phorayana-base border-2 border-black text-phorayana-text-primary p-3 text-center tracking-[0.5em] text-lg font-mono font-bold focus:outline-none focus:border-phorayana-primary rounded-xl transition-colors"
            />
          </div>

          <button 
            type="submit" 
            :disabled="isLoading || otpToken.length !== 6"
            class="w-full bg-phorayana-primary text-phorayana-text-primary border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:bg-[#b02f2d] active:translate-x-1 active:translate-y-1 active:shadow-none font-bold p-3 text-sm transition-all duration-150 uppercase tracking-wider disabled:opacity-50 disabled:cursor-not-allowed rounded-xl"
          >
            {{ isLoading ? 'Verifikasi Kode...' : 'Verifikasi OTP' }}
          </button>

          <!-- Resend OTP Button with 60s Countdown Timer -->
          <div class="flex items-center justify-between text-xs pt-2">
            <button 
              type="button" 
              @click="handleResendOtp"
              :disabled="isLoading || resendTimer > 0"
              class="text-phorayana-accent font-semibold hover:underline disabled:opacity-50 disabled:no-underline disabled:cursor-not-allowed transition-opacity"
            >
              {{ resendTimer > 0 ? `Kirim Ulang OTP (${resendTimer}s)` : 'Kirim Ulang OTP' }}
            </button>
            <button 
              type="button" 
              @click="backToForm"
              :disabled="isLoading"
              class="text-phorayana-text-secondary hover:text-phorayana-text-primary transition-colors"
            >
              Ubah Data Registrasi
            </button>
          </div>
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
import { ref, watchEffect, onUnmounted, nextTick } from 'vue'

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
const authStep = ref('form') // 'form' | 'otp'
const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const otpToken = ref('')
const otpInputRef = ref(null)

const isLoading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const resendTimer = ref(0)
let timerInterval = null

const startResendTimer = (seconds = 60) => {
  if (timerInterval) clearInterval(timerInterval)
  resendTimer.value = seconds
  timerInterval = setInterval(() => {
    if (resendTimer.value > 0) {
      resendTimer.value -= 1
    } else {
      clearInterval(timerInterval)
      timerInterval = null
    }
  }, 1000)
}

onUnmounted(() => {
  if (timerInterval) clearInterval(timerInterval)
})

const toggleMode = () => {
  isLogin.value = !isLogin.value
  authStep.value = 'form'
  errorMessage.value = ''
  successMessage.value = ''
  password.value = ''
  confirmPassword.value = ''
  otpToken.value = ''
}

const backToForm = () => {
  authStep.value = 'form'
  errorMessage.value = ''
  successMessage.value = ''
}

const onOtpInput = (e) => {
  const val = e.target.value || ''
  otpToken.value = val.replace(/\D/g, '').slice(0, 6)
}

const onOtpPaste = (e) => {
  const pasted = (e.clipboardData || window.clipboardData)?.getData('text') || ''
  otpToken.value = pasted.replace(/\D/g, '').slice(0, 6)
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
      // Handle Register Initial Step -> Send OTP
      if (password.value !== confirmPassword.value) {
        throw new Error('Konfirmasi password tidak cocok!')
      }

      const { error } = await supabase.auth.signUp({
        email: email.value,
        password: password.value
      })
      
      // Anti-User Enumeration & Resource Protection:
      // Show generic success message regardless of whether email existed or not
      successMessage.value = 'Jika email Anda belum terdaftar, kami telah mengirimkan kode 6-digit OTP ke email Anda.'
      authStep.value = 'otp'
      startResendTimer(60)

      await nextTick()
      if (otpInputRef.value) {
        otpInputRef.value.focus()
      }

      if (error) {
        console.warn('Sign up response warning/error:', error.message)
      }
    }
  } catch (error) {
    errorMessage.value = error.message || 'Terjadi kesalahan sistem'
  } finally {
    isLoading.value = false
  }
}

const handleVerifyOtp = async () => {
  if (otpToken.value.length !== 6) {
    errorMessage.value = 'Kode OTP harus terdiri dari 6 angka!'
    return
  }

  isLoading.value = true
  errorMessage.value = ''

  try {
    const { data, error } = await supabase.auth.verifyOtp({
      email: email.value,
      token: otpToken.value,
      type: 'signup'
    })

    if (error) throw error

    successMessage.value = 'Verifikasi OTP berhasil! Mengalihkan ke halaman utama...'
    setTimeout(() => {
      router.replace('/')
    }, 500)
  } catch (error) {
    // Non-destructive error recovery: Display error badge without wiping input state
    errorMessage.value = error.message || 'Kode OTP salah atau telah kedaluwarsa. Silakan periksa kembali.'
  } finally {
    isLoading.value = false
  }
}

const handleResendOtp = async () => {
  if (resendTimer.value > 0) return

  isLoading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    const { error } = await supabase.auth.signUp({
      email: email.value,
      password: password.value
    })
    
    successMessage.value = 'Kode OTP baru telah dikirimkan ke email Anda.'
    startResendTimer(60)
  } catch (error) {
    errorMessage.value = error.message || 'Gagal mengirim ulang kode OTP.'
  } finally {
    isLoading.value = false
  }
}
</script>
