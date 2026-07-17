<template>
  <div class="min-h-screen bg-phorayana-base text-phorayana-text-primary p-6 md:p-12 flex flex-col justify-between">
    <!-- Top Navigation Bar -->
    <header class="flex justify-between items-center border-b border-phorayana-border pb-6">
      <div class="flex items-center gap-2">
        <div class="w-8 h-8 bg-phorayana-primary flex items-center justify-center font-bold text-lg text-phorayana-text-primary rounded-none">
          P
        </div>
        <span class="text-xl font-bold tracking-wider uppercase">Phorayana</span>
      </div>

      <div class="flex items-center gap-4">
        <span class="hidden md:inline text-xs text-phorayana-text-secondary">
          Sesi aktif: <strong class="text-phorayana-text-primary font-mono">{{ user?.email }}</strong>
        </span>
        <button 
          @click="handleLogout" 
          :disabled="isLoggingOut"
          class="bg-phorayana-surface hover:bg-[#b02f2d] border-2 border-black text-phorayana-text-primary text-xs font-bold py-2 px-4 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] active:translate-x-1 active:translate-y-1 active:shadow-none transition-all duration-150 uppercase tracking-wider rounded-xl disabled:opacity-50"
        >
          {{ isLoggingOut ? 'Keluar...' : 'Keluar' }}
        </button>
      </div>
    </header>

    <!-- Main Content Area -->
    <main class="my-auto py-8">
      <div class="max-w-screen-2xl mx-auto grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        <!-- Left Panel: 1-Tap Check-In Widget (Takes 2 Columns on Desktop) -->
        <div class="lg:col-span-2 bg-phorayana-surface border-2 border-black p-8 md:p-12 flex flex-col justify-between min-h-[450px] rounded-2xl shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
          <div>
            <div class="flex items-center justify-between mb-6">
              <div>
                <span class="text-xs text-phorayana-accent uppercase font-bold tracking-widest block mb-1">
                  Macro Check-In
                </span>
                <h2 class="text-2xl font-bold tracking-tight">
                  Log Perjalanan Komunal
                </h2>
              </div>
              
              <!-- Active Trip Status Pill -->
              <div 
                v-if="isTracking" 
                class="flex items-center gap-2 bg-phorayana-accent/10 border border-phorayana-accent text-phorayana-accent px-3 py-1.5 text-xs font-mono font-semibold"
              >
                <span class="relative flex h-2 w-2">
                  <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-phorayana-accent opacity-75"></span>
                  <span class="relative inline-flex rounded-full h-2 w-2 bg-phorayana-accent"></span>
                </span>
                TRIP BERJALAN: {{ formatTime(elapsedTime) }}
              </div>
              <div 
                v-else 
                class="bg-phorayana-border text-phorayana-text-secondary px-3 py-1.5 text-xs font-mono font-semibold border border-phorayana-border"
              >
                SIAP DIALIRKAN
              </div>
            </div>
            
            <p class="text-phorayana-text-secondary text-xs md:text-sm max-w-xl leading-relaxed mb-8">
              Phorayana mencatat titik GPS dan waktu keberangkatan Anda. Data akan diperkaya dengan info cuaca dan kegiatan wilayah secara otomatis saat Anda sampai di tujuan.
            </p>
          </div>

          <!-- Central Viewport: The Macro Button -->
          <div class="flex flex-col items-center justify-center my-auto py-6">
            <button 
              @click="toggleTracking"
              :class="[
                'w-64 h-64 md:w-72 md:h-72 flex flex-col items-center justify-center border-4 border-black text-center transition-all duration-150 rounded-2xl focus:outline-none select-none shadow-[6px_6px_0px_0px_rgba(0,0,0,1)] active:translate-x-1.5 active:translate-y-1.5 active:shadow-none',
                isTracking 
                  ? 'bg-phorayana-accent hover:bg-[#be7b5f] text-phorayana-base' 
                  : 'bg-phorayana-primary hover:bg-[#b02f2d] text-phorayana-text-primary'
              ]"
            >
              <span class="text-[10px] uppercase tracking-widest font-extrabold opacity-80 mb-2">
                {{ isTracking ? 'Sedang Berjalan' : '1-Tap Mulai' }}
              </span>
              <span class="text-xl md:text-2xl font-black uppercase tracking-wider px-4">
                {{ isTracking ? 'AKHIRI PERJALANAN' : 'MULAI PERJALANAN' }}
              </span>
              <span v-if="isTracking" class="text-2xl font-mono mt-3 font-bold">
                {{ formatTime(elapsedTime) }}
              </span>
              <span v-else class="text-xs opacity-60 mt-2 font-mono">
                Tap untuk mencatat GPS awal
              </span>
            </button>
          </div>

          <!-- Quick Guidelines Notice -->
          <div class="mt-8 pt-4 border-t border-phorayana-border text-center lg:text-left">
            <span class="text-[10px] text-phorayana-text-secondary leading-normal">
              *ponytail: UI Slice only. Lokasi GPS dan penyimpanan ke Supabase akan dipasang pada iterasi logika backend berikutnya.
            </span>
          </div>
        </div>

        <!-- Right Panel: Side Controls (Sticky Vehicle & Saved Places) (Takes 1 Column) -->
        <div class="flex flex-col gap-6">
          
          <!-- Sticky Vehicle Selection -->
          <div class="bg-phorayana-surface border-2 border-black p-6 rounded-2xl shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
            <h3 class="text-sm font-bold uppercase tracking-wider text-phorayana-text-primary border-b border-phorayana-border pb-2 mb-4">
              Kendaraan Default
            </h3>
            <p class="text-xs text-phorayana-text-secondary mb-4 leading-normal">
              Kendaraan terakhir yang digunakan akan tersimpan otomatis (sticky).
            </p>
            <div class="grid grid-cols-2 gap-2 text-xs">
              <button 
                v-for="vehicle in ['Motor', 'Mobil', 'Angkot/Bus', 'Kereta']" 
                :key="vehicle"
                :class="[
                  'p-3 text-center border-2 font-bold transition-all duration-150 select-none rounded-xl border-black shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:-translate-x-0.5 hover:-translate-y-0.5 hover:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] active:translate-x-0.5 active:translate-y-0.5 active:shadow-none',
                  vehicle === 'Motor' 
                    ? 'bg-phorayana-primary/20 text-phorayana-primary' 
                    : 'bg-phorayana-base text-phorayana-text-secondary hover:text-phorayana-text-primary'
                ]"
              >
                {{ vehicle }}
              </button>
            </div>
          </div>

          <!-- Saved Places Selection -->
          <div class="bg-phorayana-surface border-2 border-black p-6 rounded-2xl flex-grow shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
            <h3 class="text-sm font-bold uppercase tracking-wider text-phorayana-text-primary border-b border-phorayana-border pb-2 mb-4">
              Lokasi Favorit
            </h3>
            <p class="text-xs text-phorayana-text-secondary mb-4 leading-normal">
              Pilih dari profil tempat tinggal, kampus, atau kantor magang Anda.
            </p>
            <div class="space-y-2">
              <div 
                v-for="place in ['Rumah (Bogor)', 'Kampus IPB', 'Kantor Magang (Jakarta)', 'Stasiun Bogor']" 
                :key="place"
                class="flex items-center justify-between p-3 bg-phorayana-base border-2 border-black text-xs text-phorayana-text-secondary hover:text-phorayana-text-primary cursor-pointer rounded-xl shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:-translate-x-0.5 hover:-translate-y-0.5 hover:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] active:translate-x-0.5 active:translate-y-0.5 active:shadow-none transition-all duration-150"
              >
                <span>{{ place }}</span>
                <span class="text-[10px] font-mono text-phorayana-accent">Gunakan</span>
              </div>
            </div>
          </div>
          
        </div>
        
      </div>
    </main>

    <!-- Footer -->
    <footer class="border-t border-phorayana-border pt-6 flex flex-col md:flex-row justify-between items-center gap-4 text-xs text-phorayana-text-secondary">
      <div>
        Sistem Phorayana PWA &copy; 2026. Warm Asphalt Matte Dashboard.
      </div>
      <div>
        Garis Lintang & Bujur Terkunci
      </div>
    </footer>
  </div>
</template>

<script setup>
import { ref, watchEffect, onUnmounted } from 'vue'

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

const isTracking = ref(false)
const elapsedTime = ref(0)
let timerInterval = null

const toggleTracking = () => {
  isTracking.value = !isTracking.value
  if (isTracking.value) {
    elapsedTime.value = 0
    timerInterval = setInterval(() => {
      elapsedTime.value++
    }, 1000)
  } else {
    if (timerInterval) clearInterval(timerInterval)
  }
}

const formatTime = (seconds) => {
  const h = Math.floor(seconds / 3600).toString().padStart(2, '0')
  const m = Math.floor((seconds % 3600) / 60).toString().padStart(2, '0')
  const s = (seconds % 60).toString().padStart(2, '0')
  return `${h}:${m}:${s}`
}

onUnmounted(() => {
  if (timerInterval) clearInterval(timerInterval)
})

const handleLogout = async () => {
  isLoggingOut.value = true
  try {
    if (timerInterval) clearInterval(timerInterval)
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
