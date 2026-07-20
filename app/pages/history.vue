<template>
  <div class="min-h-screen bg-phorayana-base text-phorayana-text-primary p-6 md:p-12 flex flex-col justify-between">
    <!-- Header -->
    <header class="flex justify-between items-center border-b border-phorayana-border pb-6">
      <div class="flex items-center gap-2">
        <div class="w-8 h-8 bg-phorayana-primary flex items-center justify-center font-bold text-lg text-phorayana-text-primary rounded-lg border-2 border-black">
          P
        </div>
        <span class="text-xl font-bold tracking-wider uppercase">Phorayana</span>
      </div>

      <NuxtLink 
        to="/" 
        class="bg-phorayana-surface hover:bg-phorayana-border border-2 border-black text-phorayana-text-primary text-xs font-bold py-2 px-4 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] active:translate-x-1 active:translate-y-1 active:shadow-none transition-all duration-150 uppercase tracking-wider rounded-xl"
      >
        Kembali
      </NuxtLink>
    </header>

    <!-- Main Content -->
    <main class="my-auto py-8 max-w-4xl w-full mx-auto">
      <div class="mb-8">
        <span class="text-xs text-phorayana-accent uppercase font-bold tracking-widest block mb-1">
          Travel History
        </span>
        <h2 class="text-2xl font-bold tracking-tight">
          Riwayat Perjalanan Anda
        </h2>
        <p class="text-phorayana-text-secondary text-xs md:text-sm leading-relaxed mt-2">
          Daftar seluruh perjalanan komunal yang telah selesai direkam oleh Anda.
        </p>
      </div>

      <!-- Loading State -->
      <div v-if="isLoading" class="flex flex-col gap-4">
        <div 
          v-for="i in 3" 
          :key="i"
          class="bg-phorayana-surface border-2 border-black p-6 rounded-xl animate-pulse h-24"
        />
      </div>

      <!-- Empty State -->
      <div 
        v-else-if="trips.length === 0" 
        class="bg-phorayana-surface border-2 border-black p-12 text-center rounded-xl shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]"
      >
        <span class="text-xs text-phorayana-text-secondary block mb-2 font-mono">NO RECORDS FOUND</span>
        <p class="text-sm font-bold">Belum ada riwayat perjalanan.</p>
        <p class="text-xs text-phorayana-text-secondary mt-1">Mulailah perjalanan baru dari halaman utama.</p>
      </div>

      <!-- Trip List -->
      <div v-else class="space-y-4">
        <div 
          v-for="trip in trips" 
          :key="trip.id" 
          class="bg-phorayana-surface border-2 border-black p-6 rounded-xl shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] transition-all hover:translate-x-0.5 hover:translate-y-0.5 hover:shadow-none flex flex-col md:flex-row md:justify-between md:items-center gap-4"
        >
          <!-- Left info: Vehicle and Time -->
          <div class="flex items-start gap-4">
            <!-- Vehicle Badge -->
            <div class="bg-phorayana-base border-2 border-black px-3 py-2 text-center font-black text-xs uppercase tracking-wider rounded-lg min-w-[80px]">
              {{ trip.vehicle_type === 'angkot' ? 'Angkot/Bus' : trip.vehicle_type }}
            </div>
            
            <div class="flex flex-col justify-center">
              <span class="text-xs text-phorayana-text-secondary font-mono">
                {{ formatDateTime(trip.start_time) }}
              </span>
              <span class="text-sm font-bold mt-1">
                Perjalanan #{{ trip.id }}
              </span>
            </div>
          </div>

          <!-- Right info: Duration and Distance -->
          <div class="flex items-center gap-8 md:text-right">
            <!-- Duration -->
            <div class="flex flex-col">
              <span class="text-[10px] text-phorayana-text-secondary uppercase tracking-wider font-bold">Durasi</span>
              <span class="text-sm font-mono font-extrabold text-phorayana-accent">
                {{ trip.duration_minutes || '-' }} mnt
              </span>
            </div>

            <!-- Distance -->
            <div class="flex flex-col">
              <span class="text-[10px] text-phorayana-text-secondary uppercase tracking-wider font-bold">Jarak</span>
              <span class="text-sm font-mono font-extrabold text-phorayana-primary">
                {{ trip.distance_km ? `${Number(trip.distance_km).toFixed(2)} km` : '-' }}
              </span>
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
        Data Riwayat Tersinkronisasi
      </div>
    </footer>
  </div>
</template>

<script setup>
import { ref, computed, watch, watchEffect } from 'vue'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()

const trips = ref([])
const isLoading = ref(true)
const userId = computed(() => user.value?.id || user.value?.sub)

// Protect the page from unauthenticated access
watchEffect(() => {
  if (!user.value) {
    router.replace('/login')
  }
})

// Fetch trips from Supabase client
const fetchTripHistory = async () => {
  if (!userId.value) return
  isLoading.value = true
  try {
    const { data, error } = await supabase
      .from('trips')
      .select('*')
      .eq('user_id', userId.value)
      .eq('status', 'completed')
      .order('start_time', { ascending: false })

    if (error) throw error
    trips.value = data || []
  } catch (err) {
    console.error('Error fetching trip history:', err.message)
  } finally {
    isLoading.value = false
  }
}

// Watch userId hydration
watch(userId, (newId) => {
  if (newId) {
    fetchTripHistory()
  } else {
    trips.value = []
  }
}, { immediate: true })

// Helper to format ISO Date to local string: "DD MMM YYYY, HH:MM"
const formatDateTime = (isoString) => {
  if (!isoString) return '-'
  const date = new Date(isoString)
  return date.toLocaleString('id-ID', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  })
}
</script>
