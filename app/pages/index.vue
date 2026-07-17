<template>
  <div class="min-h-screen bg-phorayana-base text-phorayana-text-primary p-6 md:p-12 flex flex-col justify-between">
    <!-- Header -->
    <header class="flex justify-between items-center border-b border-phorayana-border pb-6">
      <div class="flex items-center gap-2">
        <div class="w-8 h-8 bg-phorayana-primary flex items-center justify-center font-bold text-lg text-phorayana-text-primary rounded-none">
          P
        </div>
        <span class="text-xl font-bold tracking-wider uppercase">Phorayana</span>
      </div>

      <div class="flex items-center gap-4">
        <span class="hidden md:inline text-xs text-phorayana-text-secondary">
          Logged in as: <strong class="text-phorayana-text-primary font-mono">{{ user?.email }}</strong>
        </span>
        <button 
          @click="handleLogout" 
          :disabled="isLoggingOut"
          class="bg-phorayana-surface hover:bg-phorayana-primary border border-phorayana-border hover:border-phorayana-primary text-phorayana-text-primary text-xs font-bold py-2 px-4 transition-all duration-200 uppercase tracking-wider rounded-none disabled:opacity-50"
        >
          {{ isLoggingOut ? 'Logging Out...' : 'Keluar' }}
        </button>
      </div>
    </header>

    <!-- Main Content Grid -->
    <main class="my-auto py-12">
      <div class="max-w-screen-2xl mx-auto grid grid-cols-1 md:grid-cols-3 gap-6">
        <!-- Dashboard Welcome Hero -->
        <div class="md:col-span-2 bg-phorayana-surface border border-phorayana-border p-8 md:p-12 flex flex-col justify-center rounded-none">
          <span class="text-xs text-phorayana-primary uppercase font-bold tracking-widest mb-2">
            Commuter Portal
          </span>
          <h2 class="text-3xl md:text-5xl font-extrabold tracking-tight mb-4">
            Selamat Datang di Phorayana
          </h2>
          <p class="text-phorayana-text-secondary text-sm md:text-base leading-relaxed max-w-2xl mb-6">
            Ecosystem data komunal perjalanan Anda telah aktif. Phorayana mencatat rute, durasi riil perjalanan, cuaca, dan kalender acara secara otomatis untuk meramalkan kepadatan lalu lintas di wilayah Bogor dan sekitarnya.
          </p>
          <div class="flex flex-wrap gap-4">
            <!-- Disabled Placeholder CTA buttons to represent future flows -->
            <button 
              disabled 
              class="bg-phorayana-primary/50 text-phorayana-text-primary/70 border border-phorayana-primary/30 text-xs font-bold py-3 px-6 uppercase tracking-wider cursor-not-allowed rounded-none"
            >
              Mulai Perjalanan (Segera Hadir)
            </button>
            <button 
              disabled 
              class="bg-phorayana-surface text-phorayana-text-secondary/70 border border-phorayana-border text-xs font-bold py-3 px-6 uppercase tracking-wider cursor-not-allowed rounded-none"
            >
              Lihat Riwayat
            </button>
          </div>
        </div>

        <!-- Sidebar Info -->
        <div class="bg-phorayana-surface border border-phorayana-border p-8 flex flex-col justify-between rounded-none">
          <div>
            <h3 class="text-lg font-bold mb-4 border-b border-phorayana-border pb-2">
              Status Sistem
            </h3>
            <ul class="space-y-3 text-xs">
              <li class="flex justify-between">
                <span class="text-phorayana-text-secondary">Sesi Auth:</span>
                <span class="font-mono text-phorayana-accent font-semibold">Aktif</span>
              </li>
              <li class="flex justify-between">
                <span class="text-phorayana-text-secondary">Supabase DB:</span>
                <span class="font-mono text-phorayana-accent font-semibold">Tersambung</span>
              </li>
              <li class="flex justify-between">
                <span class="text-phorayana-text-secondary">PWA Service Worker:</span>
                <span class="font-mono text-phorayana-text-secondary">Belum Terpasang</span>
              </li>
              <li class="flex justify-between">
                <span class="text-phorayana-text-secondary">Data Lokal (IndexedDB):</span>
                <span class="font-mono text-phorayana-text-secondary">0 Antrean</span>
              </li>
            </ul>
          </div>
          <div class="mt-8 pt-4 border-t border-phorayana-border text-[10px] text-phorayana-text-secondary">
            Gunakan tombol "Keluar" di pojok kanan atas untuk memutus sesi dan kembali ke layar login.
          </div>
        </div>
      </div>
    </main>

    <!-- Footer -->
    <footer class="border-t border-phorayana-border pt-6 flex flex-col md:flex-row justify-between items-center gap-4 text-xs text-phorayana-text-secondary">
      <div>
        Running on Nuxt 4 + Supabase local environment.
      </div>
      <div>
        Dashboard Locked | v1.0 Dev Sandbox
      </div>
    </footer>
  </div>
</template>

<script setup>
import { ref, watchEffect } from 'vue'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()
const isLoggingOut = ref(false)

// Protect the page from unauthenticated access
watchEffect(() => {
  if (!user.value) {
    router.replace('/login')
  }
})

const handleLogout = async () => {
  isLoggingOut.value = true
  try {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
    router.replace('/login')
  } catch (error) {
    console.error('Logout error:', error.message)
  } finally {
    isLoggingOut.value = false
  }
}
</script>
