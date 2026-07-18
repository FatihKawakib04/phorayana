<template>
  <div class="min-h-screen bg-phorayana-base text-phorayana-text-primary p-6 md:p-12 flex flex-col justify-between">
    <!-- Top Navigation Bar -->
    <header class="flex justify-between items-center border-b border-phorayana-border pb-6">
      <div class="flex items-center gap-2">
        <div class="w-8 h-8 bg-phorayana-primary flex items-center justify-center font-bold text-lg text-phorayana-text-primary rounded-lg border-2 border-black">
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
            
            <p class="text-phorayana-text-secondary text-xs md:text-sm max-w-xl leading-relaxed mb-6">
              Phorayana mencatat titik GPS dan waktu keberangkatan Anda. Data akan diperkaya dengan info cuaca dan kegiatan wilayah secara otomatis saat Anda sampai di tujuan.
            </p>

            <!-- Error Banner -->
            <div 
              v-if="errorMessage" 
              class="bg-phorayana-alert/15 border-2 border-black text-phorayana-alert p-3 mb-6 text-xs font-bold rounded-xl animate-pulse"
            >
              {{ errorMessage }}
            </div>
          </div>

          <!-- Central Viewport: The Macro Button -->
          <div class="flex flex-col items-center justify-center my-auto py-6">
            <button 
              @click="isTracking ? endTrip() : startTrip()"
              :disabled="isLoadingGeo || isLoggingOut || isLoadingPlaces"
              :class="[
                'w-64 h-64 md:w-72 md:h-72 flex flex-col items-center justify-center border-4 border-black text-center transition-all duration-150 rounded-2xl focus:outline-none select-none shadow-[6px_6px_0px_0px_rgba(0,0,0,1)] active:translate-x-1.5 active:translate-y-1.5 active:shadow-none disabled:opacity-50 disabled:cursor-not-allowed',
                isTracking 
                  ? 'bg-phorayana-accent hover:bg-[#be7b5f] text-phorayana-base' 
                  : 'bg-phorayana-primary hover:bg-[#b02f2d] text-phorayana-text-primary'
              ]"
            >
              <span class="text-[10px] uppercase tracking-widest font-extrabold opacity-80 mb-2">
                {{ isLoadingGeo ? 'Memproses' : (isTracking ? 'Sedang Berjalan' : '1-Tap Mulai') }}
              </span>
              <span class="text-xl md:text-2xl font-black uppercase tracking-wider px-4">
                {{ isLoadingGeo ? 'Mengakses GPS...' : (isTracking ? 'AKHIRI PERJALANAN' : 'MULAI PERJALANAN') }}
              </span>
              <span v-if="isTracking && !isLoadingGeo" class="text-2xl font-mono mt-3 font-bold">
                {{ formatTime(elapsedTime) }}
              </span>
              <span v-else-if="!isLoadingGeo" class="text-xs opacity-60 mt-2 font-mono">
                Tap untuk mencatat GPS awal
              </span>
            </button>
          </div>

          <!-- Quick Guidelines Notice -->
          <div class="mt-8 pt-4 border-t border-phorayana-border text-center lg:text-left">
            <span class="text-[10px] text-phorayana-text-secondary leading-normal">
              *ponytail: GPS koordinat diambil langsung via Browser Geolocation API dan disinkronisasikan ke Supabase PostgreSQL.
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
                v-for="vehicle in ['motor', 'mobil', 'angkot', 'kereta']" 
                :key="vehicle"
                @click="selectVehicle(vehicle)"
                :class="[
                  'p-3 text-center border-2 font-bold transition-all duration-150 select-none rounded-xl border-black uppercase tracking-wider',
                  selectedVehicle === vehicle 
                    ? 'bg-phorayana-primary text-phorayana-text-primary translate-x-0.5 translate-y-0.5 shadow-none' 
                    : 'bg-phorayana-base text-phorayana-text-secondary hover:text-phorayana-text-primary shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:-translate-x-0.5 hover:-translate-y-0.5 hover:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] active:translate-x-0.5 active:translate-y-0.5 active:shadow-none'
                ]"
              >
                {{ vehicle === 'angkot' ? 'Angkot/Bus' : vehicle }}
              </button>
            </div>
          </div>

          <!-- Saved Places Selection -->
          <div class="bg-phorayana-surface border-2 border-black p-6 rounded-2xl flex-grow shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] flex flex-col justify-between min-h-[320px]">
            <div>
              <h3 class="text-sm font-bold uppercase tracking-wider text-phorayana-text-primary border-b border-phorayana-border pb-2 mb-4">
                Lokasi Favorit
              </h3>
              <p class="text-xs text-phorayana-text-secondary mb-4 leading-normal">
                Pilih lokasi sebagai target titik keberangkatan atau tujuan perjalanan Anda.
              </p>
              
              <!-- Saved Places List -->
              <div class="space-y-2 max-h-[160px] overflow-y-auto pr-1">
                <div 
                  v-for="place in savedPlaces" 
                  :key="place.id"
                  @click="toggleSelectPlace(place.id)"
                  :class="[
                    'flex items-center justify-between p-3 bg-phorayana-base border-2 border-black text-xs cursor-pointer rounded-xl transition-all duration-150 select-none',
                    selectedDestinationId === place.id 
                      ? 'border-phorayana-accent bg-phorayana-accent/15 text-phorayana-accent translate-x-0.5 translate-y-0.5 shadow-none font-bold' 
                      : 'text-phorayana-text-secondary hover:text-phorayana-text-primary shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:-translate-x-0.5 hover:-translate-y-0.5 hover:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] active:translate-x-0.5 active:translate-y-0.5 active:shadow-none'
                  ]"
                >
                  <div class="flex flex-col">
                    <span>{{ place.place_name }}</span>
                    <span class="text-[9px] opacity-60 font-mono">
                      {{ place.latitude.toFixed(4) }}, {{ place.longitude.toFixed(4) }}
                    </span>
                  </div>
                  <div class="flex items-center gap-2">
                    <span v-if="selectedDestinationId === place.id" class="text-[9px] font-mono text-phorayana-accent">TERPILIH</span>
                    <button 
                      @click.stop="deleteSavedPlace(place.id)"
                      :disabled="isLoadingPlaces"
                      class="text-phorayana-alert hover:text-red-500 font-bold px-2 py-1 border border-black hover:border-red-500 rounded-lg text-[9px] bg-phorayana-surface active:translate-x-0.5 active:translate-y-0.5 transition-all disabled:opacity-50"
                    >
                      Hapus
                    </button>
                  </div>
                </div>
                
                <div v-if="savedPlaces.length === 0" class="text-center py-6 text-xs text-phorayana-text-secondary">
                  Belum ada lokasi favorit tersimpan.
                </div>
              </div>
            </div>

            <!-- Add Saved Place Form -->
            <div class="mt-6 pt-4 border-t border-phorayana-border">
              <label class="block text-[10px] font-bold uppercase tracking-wider text-phorayana-text-secondary mb-1">
                Simpan Lokasi Saat Ini (GPS)
              </label>
              <div class="flex gap-2">
                <input 
                  v-model="newPlaceName" 
                  type="text" 
                  placeholder="Nama lokasi (misal: Rumah)"
                  :disabled="isLoadingPlaces || isLoadingGeo"
                  @keyup.enter="addSavedPlace"
                  class="flex-grow bg-phorayana-base border-2 border-black text-phorayana-text-primary px-3 py-2 text-xs focus:outline-none focus:border-phorayana-primary rounded-xl transition-colors disabled:opacity-50"
                />
                <button 
                  @click="addSavedPlace" 
                  :disabled="isLoadingPlaces || isLoadingGeo || !newPlaceName.trim()"
                  class="bg-phorayana-primary text-phorayana-text-primary border-2 border-black shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:bg-[#b02f2d] active:translate-x-0.5 active:translate-y-0.5 active:shadow-none font-bold px-3 py-2 text-xs transition-all duration-150 uppercase tracking-wider disabled:opacity-50 rounded-xl"
                >
                  Tambah
                </button>
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
import { ref, computed, watch, watchEffect, onMounted, onUnmounted } from 'vue'

const supabase = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()

// Compute userId supporting both full user object (.id) and JWT payload session (.sub)
const userId = computed(() => user.value?.id || user.value?.sub)


const isLoggingOut = ref(false)
const isTracking = ref(false)
const elapsedTime = ref(0)
const selectedVehicle = ref('motor')
const activeTripId = ref(null)
const isLoadingGeo = ref(false)
const errorMessage = ref('')
let timerInterval = null

// Saved Places CRUD State
const savedPlaces = ref([])
const selectedDestinationId = ref(null)
const newPlaceName = ref('')
const isLoadingPlaces = ref(false)

// Protect the page from unauthenticated access
watchEffect(() => {
  if (!user.value) {
    router.replace('/login')
  }
})

// Initialize session data when user is loaded
const initDashboard = async () => {
  if (!userId.value) return
  try {
    // 1. Fetch user profile for sticky default vehicle
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('last_vehicle_used')
      .eq('id', userId.value)
      .maybeSingle()

    if (profile && !profileError) {
      selectedVehicle.value = profile.last_vehicle_used || 'motor'
    }

    // 2. Fetch saved places list
    const { data: places, error: placesError } = await supabase
      .from('saved_places')
      .select('*')
      .eq('user_id', userId.value)
      .order('created_at', { ascending: true })

    if (places && !placesError) {
      savedPlaces.value = places
    }

    // 3. Fetch running trip session
    const { data, error } = await supabase
      .from('trips')
      .select('id, start_time, vehicle_type, start_place_id')
      .eq('user_id', userId.value)
      .eq('status', 'running')
      .order('start_time', { ascending: false })
      .limit(1)
      .maybeSingle()

    if (data && !error) {
      activeTripId.value = data.id
      selectedVehicle.value = data.vehicle_type
      selectedDestinationId.value = data.start_place_id
      isTracking.value = true

      const startTime = new Date(data.start_time).getTime()
      const now = new Date().getTime()
      elapsedTime.value = Math.max(0, Math.floor((now - startTime) / 1000))

      if (timerInterval) clearInterval(timerInterval)
      timerInterval = setInterval(() => {
        elapsedTime.value++
      }, 1000)
    }
  } catch (err) {
    console.error('Failed to initialize dashboard session:', err.message)
  }
}

// Watch user to initialize dashboard once session is populated
watch(userId, (newId) => {
  if (newId) {
    initDashboard()
  }
}, { immediate: true })

// Geolocation helper wrapped in Promise
const getGPSCoordinates = () => {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error('Geolocation tidak didukung oleh browser Anda.'))
      return
    }
    navigator.geolocation.getCurrentPosition(
      (position) => {
        resolve({
          lat: position.coords.latitude,
          lng: position.coords.longitude
        })
      },
      (error) => {
        let msg = 'Gagal mendapatkan lokasi GPS.'
        if (error.code === 1) msg = 'Akses GPS ditolak. Silakan aktifkan izin lokasi.'
        else if (error.code === 2) msg = 'Posisi GPS tidak tersedia.'
        else if (error.code === 3) msg = 'Waktu tunggu GPS habis.'
        reject(new Error(msg))
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 0
      }
    )
  })
}

// Select default vehicle and update profiles
const selectVehicle = async (vehicle) => {
  selectedVehicle.value = vehicle
  if (!user.value) return

  try {
    const { error } = await supabase
      .from('profiles')
      .upsert({
        id: userId.value,
        last_vehicle_used: vehicle,
        updated_at: new Date().toISOString()
      })
    if (error) throw error
  } catch (err) {
    console.error('Failed to save default vehicle:', err.message)
  }
}

// Toggle active saved place destination selection
const toggleSelectPlace = (placeId) => {
  if (selectedDestinationId.value === placeId) {
    selectedDestinationId.value = null
  } else {
    selectedDestinationId.value = placeId
  }
}

// Add a saved place using current GPS coordinates
const addSavedPlace = async () => {
  if (!newPlaceName.value.trim() || !user.value) return
  isLoadingPlaces.value = true
  errorMessage.value = ''

  try {
    const coords = await getGPSCoordinates()
    const { data, error } = await supabase
      .from('saved_places')
      .insert({
        user_id: userId.value,
        place_name: newPlaceName.value.trim(),
        latitude: coords.lat,
        longitude: coords.lng
      })
      .select()
      .single()

    if (error) throw error

    savedPlaces.value.push(data)
    newPlaceName.value = ''
  } catch (err) {
    errorMessage.value = err.message || 'Gagal menambahkan lokasi.'
    console.error(err)
  } finally {
    isLoadingPlaces.value = false
  }
}

// Delete a saved place
const deleteSavedPlace = async (id) => {
  if (!user.value) return
  isLoadingPlaces.value = true
  errorMessage.value = ''

  try {
    const { error } = await supabase
      .from('saved_places')
      .delete()
      .eq('id', id)
      .eq('user_id', userId.value)

    if (error) throw error

    savedPlaces.value = savedPlaces.value.filter(place => place.id !== id)
    if (selectedDestinationId.value === id) {
      selectedDestinationId.value = null
    }
  } catch (err) {
    errorMessage.value = err.message || 'Gagal menghapus lokasi.'
    console.error(err)
  } finally {
    isLoadingPlaces.value = false
  }
}

// Start trip logic
const startTrip = async () => {
  if (!user.value) return
  isLoadingGeo.value = true
  errorMessage.value = ''

  try {
    const coords = await getGPSCoordinates()
    const { data, error } = await supabase
      .from('trips')
      .insert({
        user_id: userId.value,
        vehicle_type: selectedVehicle.value,
        start_time: new Date().toISOString(),
        start_lat: coords.lat,
        start_lng: coords.lng,
        start_place_id: selectedDestinationId.value,
        status: 'running'
      })
      .select('id')
      .single()

    if (error) throw error

    activeTripId.value = data.id
    isTracking.value = true
    elapsedTime.value = 0
    timerInterval = setInterval(() => {
      elapsedTime.value++
    }, 1000)
  } catch (err) {
    errorMessage.value = err.message || 'Gagal memulai perjalanan.'
    console.error(err)
  } finally {
    isLoadingGeo.value = false
  }
}

// End trip logic
const endTrip = async () => {
  if (!activeTripId.value) return
  isLoadingGeo.value = true
  errorMessage.value = ''

  try {
    const coords = await getGPSCoordinates()
    const { error } = await supabase
      .from('trips')
      .update({
        end_time: new Date().toISOString(),
        end_lat: coords.lat,
        end_lng: coords.lng,
        end_place_id: selectedDestinationId.value,
        status: 'completed',
        duration_minutes: Math.ceil(elapsedTime.value / 60)
      })
      .eq('id', activeTripId.value)

    if (error) throw error

    isTracking.value = false
    activeTripId.value = null
    selectedDestinationId.value = null
    if (timerInterval) clearInterval(timerInterval)
  } catch (err) {
    errorMessage.value = err.message || 'Gagal mengakhiri perjalanan.'
    console.error(err)
  } finally {
    isLoadingGeo.value = false
  }
}

// Format seconds to HH:MM:SS
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
