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
        <NuxtLink 
          to="/history" 
          class="bg-phorayana-surface hover:bg-phorayana-border border-2 border-black text-phorayana-text-primary text-xs font-bold py-2 px-4 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] active:translate-x-1 active:translate-y-1 active:shadow-none transition-all duration-150 uppercase tracking-wider rounded-xl"
        >
          Riwayat
        </NuxtLink>
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

            <!-- Success/Info Banner -->
            <div 
              v-if="infoMessage" 
              class="bg-phorayana-accent/15 border-2 border-black text-phorayana-accent p-3 mb-6 text-xs font-bold rounded-xl"
            >
              {{ infoMessage }}
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
                :disabled="isTracking"
                :class="[
                  'p-3 text-center border-2 font-bold transition-all duration-150 select-none rounded-xl border-black uppercase tracking-wider disabled:opacity-50 disabled:cursor-not-allowed',
                  selectedVehicle === vehicle 
                    ? 'bg-phorayana-primary text-phorayana-text-primary translate-x-0.5 translate-y-0.5 shadow-none' 
                    : 'bg-phorayana-base text-phorayana-text-secondary hover:text-phorayana-text-primary shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:-translate-x-0.5 hover:-translate-y-0.5 hover:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] active:translate-x-0.5 active:translate-y-0.5 active:shadow-none'
                ]"
              >
                {{ vehicle === 'angkot' ? 'Angkot/Bus' : vehicle }}
              </button>
            </div>
          </div>

          <!-- Route Location Dropdowns -->
          <div class="bg-phorayana-surface border-2 border-black p-6 rounded-2xl shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
            <h3 class="text-sm font-bold uppercase tracking-wider text-phorayana-text-primary border-b border-phorayana-border pb-2 mb-4">
              Pilihan Rute Perjalanan
            </h3>
            
            <div class="space-y-4">
              <!-- Dropdown Asal -->
              <div>
                <label for="start-place-select" class="block text-[10px] font-bold uppercase tracking-wider text-phorayana-text-secondary mb-1">
                  Titik Keberangkatan (Asal)
                </label>
                <select 
                  id="start-place-select"
                  v-model="startPlaceId"
                  :disabled="isTracking"
                  class="w-full bg-phorayana-base border-2 border-black text-phorayana-text-primary px-3 py-2 text-xs rounded-xl focus:outline-none focus:border-phorayana-primary disabled:opacity-50"
                >
                  <option :value="null">Gunakan Lokasi Saat Ini (Instant GPS)</option>
                  <option v-for="place in savedPlaces" :key="place.id" :value="place.id">
                    {{ place.place_name }}
                  </option>
                </select>
              </div>

              <!-- Dropdown Tujuan -->
              <div>
                <label for="end-place-select" class="block text-[10px] font-bold uppercase tracking-wider text-phorayana-text-secondary mb-1">
                  Titik Kedatangan (Tujuan)
                </label>
                <select 
                  id="end-place-select"
                  v-model="endPlaceId"
                  class="w-full bg-phorayana-base border-2 border-black text-phorayana-text-primary px-3 py-2 text-xs rounded-xl focus:outline-none focus:border-phorayana-primary"
                >
                  <option :value="null">Gunakan Lokasi Saat Ini (Instant GPS)</option>
                  <option v-for="place in savedPlaces" :key="place.id" :value="place.id">
                    {{ place.place_name }}
                  </option>
                </select>
              </div>
            </div>
          </div>

          <!-- Saved Places Selection -->
          <div class="bg-phorayana-surface border-2 border-black p-6 rounded-2xl flex-grow shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] flex flex-col justify-between min-h-[320px]">
            <div>
              <h3 class="text-sm font-bold uppercase tracking-wider text-phorayana-text-primary border-b border-phorayana-border pb-2 mb-4">
                Lokasi Favorit
              </h3>
              <p class="text-xs text-phorayana-text-secondary mb-4 leading-normal">
                Daftar lokasi favorit Anda. Ketuk nama lokasi untuk memilih sebagai tujuan.
              </p>
              
              <!-- Saved Places List -->
              <div class="space-y-2 max-h-[160px] overflow-y-auto pr-1">
                <div 
                  v-for="place in savedPlaces" 
                  :key="place.id"
                  @click="endPlaceId = (endPlaceId === place.id ? null : place.id)"
                  :class="[
                    'flex items-center justify-between p-3 bg-phorayana-base border-2 border-black text-xs cursor-pointer rounded-xl transition-all duration-150 select-none',
                    endPlaceId === place.id 
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
                    <span v-if="endPlaceId === place.id" class="text-[9px] font-mono text-phorayana-accent font-bold">TUJUAN</span>
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
// ponytail: direct client queries, fat page component. ceiling: offline queries fail, index.vue is 560+ lines. upgrade: refactor logic to useSavedPlaces and build IndexedDB sync queue (Refactoring vs Offline-First Skala Prioritas)
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
const activeTripStartTime = ref(null)
const isLoadingGeo = ref(false)
const errorMessage = ref('')
const infoMessage = ref('')
let timerInterval = null

// Tracking Engine State
const routePath = ref([])
let watchId = null

// Saved Places & Route State
const savedPlaces = ref([])
const startPlaceId = ref(null)
const endPlaceId = ref(null)
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

    // 3. Fetch running trip session including start coordinates and route path
    const { data, error } = await supabase
      .from('trips')
      .select('id, start_time, vehicle_type, start_place_id, end_place_id, start_lat, start_lng, route_path')
      .eq('user_id', userId.value)
      .eq('status', 'running')
      .order('start_time', { ascending: false })
      .limit(1)
      .maybeSingle()

    if (data && !error) {
      // Only set from DB if not already hydrated from localStorage (which is newer)
      if (!activeTripId.value || activeTripId.value === data.id) {
        activeTripId.value = data.id
        selectedVehicle.value = data.vehicle_type
        startPlaceId.value = data.start_place_id
        endPlaceId.value = data.end_place_id
        isTracking.value = true
        activeTripStartTime.value = data.start_time
        
        if (routePath.value.length === 0) {
          routePath.value = data.route_path || []
          if (routePath.value.length === 0 && data.start_lat && data.start_lng) {
            routePath.value.push({
              lat: data.start_lat,
              lng: data.start_lng,
              t: data.start_time
            })
          }
        }
      }

      const startTime = new Date(data.start_time).getTime()
      const now = new Date().getTime()
      elapsedTime.value = Math.max(0, Math.floor((now - startTime) / 1000))

      if (timerInterval) clearInterval(timerInterval)
      timerInterval = setInterval(() => {
        elapsedTime.value++
      }, 1000)

      startGPSTracking()
    }
  } catch (err) {
    console.error('Failed to initialize dashboard session:', err.message)
  }
}

// Reset state variables to default values when user session is cleared (logout/expiration)
const resetState = () => {
  if (timerInterval) {
    clearInterval(timerInterval)
    timerInterval = null
  }
  if (watchId !== null) {
    navigator.geolocation.clearWatch(watchId)
    watchId = null
  }
  isTracking.value = false
  elapsedTime.value = 0
  selectedVehicle.value = 'motor'
  activeTripId.value = null
  activeTripStartTime.value = null
  isLoadingGeo.value = false
  errorMessage.value = ''
  infoMessage.value = ''
  savedPlaces.value = []
  startPlaceId.value = null
  endPlaceId.value = null
  newPlaceName.value = ''
  isLoadingPlaces.value = false
  routePath.value = []
  clearTrackingStorage()
}

// Watch user to initialize dashboard once session is populated, or reset it upon logout
watch(userId, (newId) => {
  if (newId) {
    initDashboard()
  } else {
    resetState()
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

// Calculate distance between two coordinates in kilometers using Haversine formula
const calculateHaversineDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371 // Earth radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180
  const dLon = (lon2 - lon1) * Math.PI / 180
  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon / 2) * Math.sin(dLon / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  return R * c
}

// Calculate total distance of the path in kilometers
const calculateTotalDistance = (path) => {
  if (!path || path.length < 2) return 0
  let total = 0
  for (let i = 0; i < path.length - 1; i++) {
    total += calculateHaversineDistance(
      path[i].lat, path[i].lng,
      path[i+1].lat, path[i+1].lng
    )
  }
  return total
}

// LocalStorage Mirroring: Clear stored session
const clearTrackingStorage = () => {
  if (import.meta.client) {
    localStorage.removeItem('wpy_active_trip_id')
    localStorage.removeItem('wpy_active_route_path')
    localStorage.removeItem('wpy_start_place_id')
    localStorage.removeItem('wpy_end_place_id')
  }
}

// LocalStorage Mirroring: Rehydrate stored session on mount
const initActiveTripSession = () => {
  if (!import.meta.client) return
  const storedTripId = localStorage.getItem('wpy_active_trip_id')
  const storedRoutePath = localStorage.getItem('wpy_active_route_path')
  const storedStartPlaceId = localStorage.getItem('wpy_start_place_id')
  const storedEndPlaceId = localStorage.getItem('wpy_end_place_id')
  
  if (storedTripId && storedRoutePath) {
    try {
      activeTripId.value = storedTripId
      routePath.value = JSON.parse(storedRoutePath)
      isTracking.value = true
      startPlaceId.value = storedStartPlaceId ? Number(storedStartPlaceId) : null
      endPlaceId.value = storedEndPlaceId ? Number(storedEndPlaceId) : null
      startGPSTracking()
    } catch (e) {
      console.error('Error rehydrating stored route path:', e)
    }
  }
}

// Sync queued offline check-outs to Supabase when connection is back
const syncOfflineQueue = async () => {
  if (!import.meta.client || !navigator.onLine) return
  const queueStr = localStorage.getItem('wpy_offline_sync_queue')
  if (!queueStr) return

  try {
    const queue = JSON.parse(queueStr)
    if (queue.length === 0) return

    const remainingQueue = []
    for (const item of queue) {
      const { tripId, payload } = item
      const { error } = await supabase
        .from('trips')
        .update(payload)
        .eq('id', tripId)
      
      if (error) {
        console.error(`Failed to sync trip #${tripId} from offline queue:`, error.message)
        remainingQueue.push(item)
      }
    }

    if (remainingQueue.length > 0) {
      localStorage.setItem('wpy_offline_sync_queue', JSON.stringify(remainingQueue))
    } else {
      localStorage.removeItem('wpy_offline_sync_queue')
      infoMessage.value = 'Seluruh data perjalanan offline berhasil disinkronisasikan!'
      setTimeout(() => { infoMessage.value = '' }, 5000)
    }
  } catch (e) {
    console.error('Error syncing offline queue:', e)
  }
}

// Start watching GPS position to log breadcrumbs/path
const startGPSTracking = () => {
  if (watchId !== null) return
  if (!navigator.geolocation) return

  watchId = navigator.geolocation.watchPosition(
    (position) => {
      // 1. Filter GPS Jitter: Ignore if accuracy is low (accuracy > 30 meters)
      if (position.coords.accuracy > 30) {
        console.warn('GPS accuracy low (jitter filter):', position.coords.accuracy)
        return
      }

      const lat = position.coords.latitude
      const lng = position.coords.longitude
      const t = new Date().toISOString()
      const newCoord = { lat, lng, t }
      
      // Filter: only record if moved more than 10 meters (0.01 km)
      if (routePath.value.length > 0) {
        const last = routePath.value[routePath.value.length - 1]
        const dist = calculateHaversineDistance(last.lat, last.lng, lat, lng)
        if (dist < 0.01) {
          return
        }
      }
      routePath.value.push(newCoord)

      // 2. LocalStorage Mirroring (Antiloss)
      if (import.meta.client) {
        localStorage.setItem('wpy_active_route_path', JSON.stringify(routePath.value))
        if (activeTripId.value) {
          localStorage.setItem('wpy_active_trip_id', activeTripId.value)
          if (startPlaceId.value) localStorage.setItem('wpy_start_place_id', String(startPlaceId.value))
          if (endPlaceId.value) localStorage.setItem('wpy_end_place_id', String(endPlaceId.value))
        }
      }
    },
    (err) => {
      console.error('watchPosition error:', err)
    },
    {
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 0
    }
  )
}

// Select default vehicle and update profiles
const selectVehicle = async (vehicle) => {
  if (isTracking.value) return // JIJAK ter-lock saat tracking
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
    const startTimeStr = new Date().toISOString()
    const { data, error } = await supabase
      .from('trips')
      .insert({
        user_id: userId.value,
        vehicle_type: selectedVehicle.value,
        start_time: startTimeStr,
        start_lat: coords.lat,
        start_lng: coords.lng,
        start_place_id: startPlaceId.value,
        status: 'running'
      })
      .select('id')
      .single()

    if (error) throw error

    activeTripId.value = data.id
    isTracking.value = true
    elapsedTime.value = 0
    activeTripStartTime.value = startTimeStr
    routePath.value = [{ lat: coords.lat, lng: coords.lng, t: startTimeStr }]
    
    // LocalStorage Mirroring (Antiloss) on trip start
    if (import.meta.client) {
      localStorage.setItem('wpy_active_trip_id', data.id)
      localStorage.setItem('wpy_active_route_path', JSON.stringify(routePath.value))
      if (startPlaceId.value) localStorage.setItem('wpy_start_place_id', String(startPlaceId.value))
      if (endPlaceId.value) localStorage.setItem('wpy_end_place_id', String(endPlaceId.value))
    }

    timerInterval = setInterval(() => {
      elapsedTime.value++
    }, 1000)

    startGPSTracking()
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
  infoMessage.value = ''

  try {
    // 1. Hentikan watchPosition dan bersihkan interval timer
    if (watchId !== null) {
      navigator.geolocation.clearWatch(watchId)
      watchId = null
    }
    if (timerInterval) {
      clearInterval(timerInterval)
      timerInterval = null
    }

    // 2. Ambil koordinat GPS akhir
    const coords = await getGPSCoordinates()
    const endTimeStr = new Date().toISOString()
    
    // Masukkan koordinat akhir ke dalam routePath
    routePath.value.push({
      lat: coords.lat,
      lng: coords.lng,
      t: endTimeStr
    })

    // Update LocalStorage Mirroring sebelum push ke DB
    if (import.meta.client) {
      localStorage.setItem('wpy_active_route_path', JSON.stringify(routePath.value))
    }

    // 3. Kalkulasi Metrik Akhir
    const finalDistance = calculateTotalDistance(routePath.value)
    const startTime = activeTripStartTime.value ? new Date(activeTripStartTime.value).getTime() : (new Date().getTime() - elapsedTime.value * 1000)
    const now = new Date().getTime()
    const durationMinutes = Math.max(1, Math.ceil((now - startTime) / 60000))

    // 4. Integrasi Cuaca (Open-Meteo API)
    let weatherText = 'Cerah'
    try {
      const weatherRes = await fetch(`https://api.open-meteo.com/v1/forecast?latitude=${coords.lat}&longitude=${coords.lng}&current=temperature_2m,weather_code`)
      if (weatherRes.ok) {
        const weatherData = await weatherRes.json()
        const code = weatherData.current?.weather_code
        const temp = weatherData.current?.temperature_2m
        let condition = 'Cerah'
        if (code >= 1 && code <= 3) condition = 'Berawan Sebagian'
        else if (code === 45 || code === 48) condition = 'Kabut'
        else if (code >= 51 && code <= 67) condition = 'Gerimis/Hujan Ringan'
        else if (code >= 71 && code <= 86) condition = 'Salju'
        else if (code >= 95) condition = 'Badai Petir'
        weatherText = `${condition}, ${temp}°C`
      }
    } catch (err) {
      console.warn('Failed to fetch weather from Open-Meteo:', err)
      weatherText = 'Tidak diketahui'
    }

    // 5. Database Sync & Fallback Offline
    const updatePayload = {
      end_time: endTimeStr,
      end_lat: coords.lat,
      end_lng: coords.lng,
      end_place_id: endPlaceId.value,
      status: 'completed',
      duration_minutes: durationMinutes,
      distance_km: Number(finalDistance.toFixed(2)),
      route_path: routePath.value,
      weather_condition: weatherText
    }

    let syncSuccess = false
    if (navigator.onLine) {
      try {
        const { error } = await supabase
          .from('trips')
          .update(updatePayload)
          .eq('id', activeTripId.value)
        
        if (error) throw error
        syncSuccess = true
      } catch (dbErr) {
        console.warn('Database write failed, fallback to offline queue:', dbErr.message)
      }
    }

    if (!syncSuccess) {
      // Masukkan ke antrean offline
      if (import.meta.client) {
        const queueStr = localStorage.getItem('wpy_offline_sync_queue')
        const queue = queueStr ? JSON.parse(queueStr) : []
        queue.push({
          tripId: activeTripId.value,
          payload: updatePayload
        })
        localStorage.setItem('wpy_offline_sync_queue', JSON.stringify(queue))
        infoMessage.value = 'Perjalanan disimpan secara lokal karena masalah jaringan. Data akan disinkronisasikan otomatis saat online kembali.'
      }
    } else {
      infoMessage.value = 'Perjalanan berhasil disinkronisasikan ke server!'
      setTimeout(() => { infoMessage.value = '' }, 5000)
    }

    // Pembersihan state perjalanan aktif (baik sukses maupun masuk antrean offline)
    isTracking.value = false
    activeTripId.value = null
    activeTripStartTime.value = null
    selectedDestinationId.value = null
    routePath.value = []
    clearTrackingStorage()

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

onMounted(() => {
  initActiveTripSession()
  syncOfflineQueue()
  
  if (import.meta.client) {
    window.addEventListener('online', syncOfflineQueue)
  }
})

onUnmounted(() => {
  if (timerInterval) clearInterval(timerInterval)
  if (watchId !== null) {
    navigator.geolocation.clearWatch(watchId)
  }
  if (import.meta.client) {
    window.removeEventListener('online', syncOfflineQueue)
  }
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
