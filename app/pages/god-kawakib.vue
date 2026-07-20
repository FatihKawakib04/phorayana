<template>
  <div class="min-h-screen bg-phorayana-base text-phorayana-text-primary font-sans">
    <!-- Header -->
    <header class="sticky top-0 z-50 bg-phorayana-base/90 backdrop-blur border-b border-phorayana-border px-6 py-4 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <div class="w-8 h-8 bg-phorayana-primary flex items-center justify-center font-bold text-lg rounded-lg border-2 border-black">
          P
        </div>
        <div>
          <span class="text-xl font-bold tracking-wider uppercase">Phorayana</span>
          <span class="ml-2 text-xs bg-phorayana-primary/20 border border-phorayana-primary text-phorayana-primary font-bold px-2 py-0.5 rounded uppercase tracking-widest">God Mode</span>
        </div>
      </div>
      <div class="flex items-center gap-4">
        <span class="text-xs text-phorayana-text-secondary hidden sm:inline">
          Logged as: <strong class="text-phorayana-accent font-mono">{{ user?.email }}</strong>
        </span>
        <NuxtLink
          to="/"
          class="bg-phorayana-surface hover:bg-phorayana-border border-2 border-black text-phorayana-text-primary text-xs font-bold py-2 px-4 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] active:translate-x-1 active:translate-y-1 active:shadow-none transition-all duration-150 uppercase tracking-wider rounded-xl"
        >
          ← Dashboard
        </NuxtLink>
      </div>
    </header>

    <!-- Main Grid -->
    <main class="px-6 py-8 max-w-screen-2xl mx-auto">
      <!-- Loading State -->
      <div v-if="pending" class="flex flex-col items-center justify-center min-h-[60vh] gap-4">
        <div class="w-10 h-10 border-4 border-phorayana-primary border-t-transparent rounded-full animate-spin"></div>
        <p class="text-phorayana-text-secondary text-sm">Mengambil data platform…</p>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="p-6 bg-phorayana-alert/10 border-2 border-phorayana-alert rounded-xl text-phorayana-alert text-sm font-bold">
        ⚠ Gagal memuat data: {{ error.message }}
      </div>

      <!-- Dashboard Content -->
      <ClientOnly v-else>
        <!-- KPI Stat Cards Row -->
        <section class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <div
            v-for="stat in kpiStats"
            :key="stat.label"
            class="bg-phorayana-surface border-2 border-black rounded-2xl p-5 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]"
          >
            <p class="text-xs text-phorayana-text-secondary uppercase tracking-widest font-bold mb-1">{{ stat.label }}</p>
            <p class="text-3xl font-extrabold tracking-tight" :style="{ color: stat.color }">{{ stat.value }}</p>
            <p class="text-xs text-phorayana-text-secondary mt-1">{{ stat.sub }}</p>
          </div>
        </section>

        <!-- Row 1: Trend Line Chart + Scatter Plot -->
        <section class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
          <!-- Community Trend Line Chart -->
          <div class="bg-phorayana-surface border-2 border-black rounded-2xl p-6 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
            <div class="flex items-start justify-between mb-4">
              <div>
                <h2 class="text-sm font-bold uppercase tracking-widest text-phorayana-text-secondary">Community Trend</h2>
                <p class="text-lg font-bold text-phorayana-text-primary mt-0.5">Fluktuasi Durasi Perjalanan (7 Hari)</p>
              </div>
              <span class="text-xs bg-phorayana-primary/15 border border-phorayana-primary/40 text-phorayana-primary px-2 py-1 rounded font-mono font-bold">Live</span>
            </div>
            <!-- SVG Line Chart -->
            <div class="w-full overflow-x-auto">
              <svg viewBox="0 0 500 200" class="w-full" preserveAspectRatio="none" aria-label="Community trip duration trend chart">
                <!-- Grid lines -->
                <line v-for="y in [50,100,150]" :key="y" :x1="0" :y1="y" x2="500" :y2="y" stroke="#333333" stroke-width="1" stroke-dasharray="4 4"/>
                <!-- Gradient fill -->
                <defs>
                  <linearGradient id="trendFill" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stop-color="#d53734" stop-opacity="0.3"/>
                    <stop offset="100%" stop-color="#d53734" stop-opacity="0"/>
                  </linearGradient>
                </defs>
                <path :d="trendFillPath" fill="url(#trendFill)"/>
                <polyline :points="trendPoints" fill="none" stroke="#d53734" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round"/>
                <!-- Data point dots -->
                <circle v-for="(pt, i) in trendCoords" :key="i" :cx="pt.x" :cy="pt.y" r="4" fill="#d53734" stroke="#181818" stroke-width="2"/>
                <!-- X-axis labels -->
                <text v-for="(day, i) in trendLabels" :key="day" :x="trendCoords[i]?.x ?? 0" y="195" text-anchor="middle" font-size="10" fill="#a0a0a0">{{ day }}</text>
              </svg>
            </div>
            <!-- Legend -->
            <div class="flex items-center gap-2 mt-3 text-xs text-phorayana-text-secondary">
              <span class="inline-block w-4 h-0.5 bg-phorayana-primary"></span>
              Rata-rata durasi perjalanan (menit)
            </div>
          </div>

          <!-- Scatter Plot: Departure Time vs Duration -->
          <div class="bg-phorayana-surface border-2 border-black rounded-2xl p-6 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
            <div class="flex items-start justify-between mb-4">
              <div>
                <h2 class="text-sm font-bold uppercase tracking-widest text-phorayana-text-secondary">Scatter Plot</h2>
                <p class="text-lg font-bold text-phorayana-text-primary mt-0.5">Jam Berangkat vs Durasi</p>
              </div>
              <span class="text-xs bg-phorayana-accent/15 border border-phorayana-accent/40 text-phorayana-accent px-2 py-1 rounded font-mono font-bold">All Routes</span>
            </div>
            <div class="w-full overflow-x-auto">
              <svg viewBox="0 0 500 210" class="w-full" preserveAspectRatio="none" aria-label="Scatter plot: departure time vs trip duration">
                <!-- Grid lines -->
                <line v-for="y in [50,100,150]" :key="y" :x1="40" :y1="y" x2="500" :y2="y" stroke="#333333" stroke-width="1" stroke-dasharray="4 4"/>
                <!-- Y-axis labels -->
                <text x="35" y="54" text-anchor="end" font-size="9" fill="#a0a0a0">120m</text>
                <text x="35" y="104" text-anchor="end" font-size="9" fill="#a0a0a0">60m</text>
                <text x="35" y="154" text-anchor="end" font-size="9" fill="#a0a0a0">30m</text>
                <!-- Scatter dots -->
                <circle
                  v-for="(pt, i) in scatterPoints"
                  :key="i"
                  :cx="pt.x"
                  :cy="pt.y"
                  :r="pt.r"
                  :fill="pt.color"
                  fill-opacity="0.75"
                  stroke="#181818"
                  stroke-width="1"
                />
                <!-- X-axis labels -->
                <text x="80" y="205" text-anchor="middle" font-size="9" fill="#a0a0a0">06:00</text>
                <text x="190" y="205" text-anchor="middle" font-size="9" fill="#a0a0a0">08:00</text>
                <text x="300" y="205" text-anchor="middle" font-size="9" fill="#a0a0a0">12:00</text>
                <text x="410" y="205" text-anchor="middle" font-size="9" fill="#a0a0a0">17:00</text>
                <text x="490" y="205" text-anchor="middle" font-size="9" fill="#a0a0a0">21:00</text>
              </svg>
            </div>
            <div class="flex items-center gap-4 mt-3 text-xs text-phorayana-text-secondary">
              <span class="flex items-center gap-1"><span class="w-3 h-3 rounded-full inline-block bg-phorayana-primary"></span> Motor</span>
              <span class="flex items-center gap-1"><span class="w-3 h-3 rounded-full inline-block bg-phorayana-accent"></span> Mobil</span>
              <span class="flex items-center gap-1"><span class="w-3 h-3 rounded-full inline-block" style="background:#6c8ebf"></span> Angkot/Bus</span>
            </div>
          </div>
        </section>

        <!-- Row 2: Data Pipeline Health + System Activity Table -->
        <section class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <!-- Data Pipeline Health Panel -->
          <div class="bg-phorayana-surface border-2 border-black rounded-2xl p-6 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] flex flex-col gap-5">
            <div>
              <h2 class="text-sm font-bold uppercase tracking-widest text-phorayana-text-secondary">Pipeline Health</h2>
              <p class="text-lg font-bold text-phorayana-text-primary mt-0.5">Sync & Data Integrity</p>
            </div>

            <!-- Radial progress rings using SVG -->
            <div class="flex flex-col gap-4">
              <div v-for="metric in pipelineMetrics" :key="metric.label" class="flex items-center gap-4">
                <svg viewBox="0 0 40 40" class="w-12 h-12 flex-shrink-0" aria-hidden="true">
                  <circle cx="20" cy="20" r="15" fill="none" stroke="#333333" stroke-width="4"/>
                  <circle
                    cx="20" cy="20" r="15"
                    fill="none"
                    :stroke="metric.color"
                    stroke-width="4"
                    stroke-linecap="round"
                    stroke-dasharray="94.2"
                    :stroke-dashoffset="94.2 - (metric.pct / 100) * 94.2"
                    transform="rotate(-90 20 20)"
                  />
                  <text x="20" y="24" text-anchor="middle" font-size="9" font-weight="bold" :fill="metric.color">{{ metric.pct }}%</text>
                </svg>
                <div>
                  <p class="text-sm font-bold text-phorayana-text-primary">{{ metric.label }}</p>
                  <p class="text-xs text-phorayana-text-secondary">{{ metric.desc }}</p>
                </div>
              </div>
            </div>

            <!-- Offline queue indicator -->
            <div class="mt-auto pt-4 border-t border-phorayana-border">
              <p class="text-xs text-phorayana-text-secondary uppercase tracking-widest font-bold mb-1">Offline Queue Size</p>
              <div class="flex items-center gap-2">
                <div class="flex-1 h-2 bg-phorayana-border rounded-full overflow-hidden">
                  <div class="h-full bg-phorayana-accent rounded-full" :style="{ width: offlineQueuePct + '%' }"></div>
                </div>
                <span class="text-xs font-mono font-bold text-phorayana-accent">{{ offlineQueueSize }} pending</span>
              </div>
            </div>
          </div>

          <!-- System Activity Table (Anonymous) -->
          <div class="lg:col-span-2 bg-phorayana-surface border-2 border-black rounded-2xl p-6 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
            <div class="flex items-center justify-between mb-4">
              <div>
                <h2 class="text-sm font-bold uppercase tracking-widest text-phorayana-text-secondary">System Activity</h2>
                <p class="text-lg font-bold text-phorayana-text-primary mt-0.5">Log Perjalanan Terkini (Anonim)</p>
              </div>
              <span class="text-xs text-phorayana-text-secondary font-mono">{{ recentTrips.length }} entri</span>
            </div>

            <!-- Table -->
            <div class="overflow-x-auto">
              <table class="w-full text-xs">
                <thead>
                  <tr class="border-b border-phorayana-border">
                    <th class="text-left py-2 pr-3 text-phorayana-text-secondary uppercase tracking-wider font-bold">Waktu</th>
                    <th class="text-left py-2 pr-3 text-phorayana-text-secondary uppercase tracking-wider font-bold">Kendaraan</th>
                    <th class="text-left py-2 pr-3 text-phorayana-text-secondary uppercase tracking-wider font-bold">Durasi</th>
                    <th class="text-left py-2 pr-3 text-phorayana-text-secondary uppercase tracking-wider font-bold">Jarak</th>
                    <th class="text-left py-2 pr-3 text-phorayana-text-secondary uppercase tracking-wider font-bold">Cuaca</th>
                    <th class="text-left py-2 text-phorayana-text-secondary uppercase tracking-wider font-bold">Status</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="trip in recentTrips"
                    :key="trip.id"
                    class="border-b border-phorayana-border/50 hover:bg-phorayana-border/30 transition-colors"
                  >
                    <td class="py-2.5 pr-3 font-mono text-phorayana-text-secondary">{{ formatTime(trip.start_time) }}</td>
                    <td class="py-2.5 pr-3">
                      <span class="inline-block bg-phorayana-base border border-phorayana-border px-2 py-0.5 rounded font-mono capitalize">
                        {{ trip.vehicle_type }}
                      </span>
                    </td>
                    <td class="py-2.5 pr-3 font-bold" :class="trip.duration_minutes > 60 ? 'text-phorayana-alert' : 'text-phorayana-text-primary'">
                      {{ trip.duration_minutes != null ? trip.duration_minutes + 'm' : '—' }}
                    </td>
                    <td class="py-2.5 pr-3 text-phorayana-text-secondary">
                      {{ trip.distance_km != null ? trip.distance_km + ' km' : '—' }}
                    </td>
                    <td class="py-2.5 pr-3 text-phorayana-text-secondary max-w-[140px] truncate">
                      {{ trip.weather_condition || '—' }}
                    </td>
                    <td class="py-2.5">
                      <span
                        class="inline-block px-2 py-0.5 rounded text-xs font-bold uppercase tracking-wider"
                        :class="statusClass(trip.status)"
                      >
                        {{ trip.status }}
                      </span>
                    </td>
                  </tr>
                  <tr v-if="recentTrips.length === 0">
                    <td colspan="6" class="text-center py-8 text-phorayana-text-secondary">Belum ada data perjalanan.</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </section>

        <!-- Footer note -->
        <p class="text-center text-xs text-phorayana-text-secondary mt-8 pb-4">
          🔒 God Mode — data ditampilkan secara anonim tanpa informasi PII pengguna. Hanya developer yang memiliki akses ke halaman ini.
        </p>
      </ClientOnly>
    </main>
  </div>
</template>

<script setup>
definePageMeta({
  middleware: ['god-auth']
})

const user = useSupabaseUser()
const supabase = useSupabaseClient()

// ─── Data Fetch ──────────────────────────────────────────────────────────────
// Fetch recent trips anonymously (no user email, no PII)
const { data: tripsData, pending, error } = await useAsyncData('god-trips', async () => {
  const { data, error } = await supabase
    .from('trips')
    .select('id, start_time, vehicle_type, duration_minutes, distance_km, weather_condition, status, regional_event')
    .order('start_time', { ascending: false })
    .limit(50)

  if (error) throw error
  return data ?? []
}, { server: false, lazy: true })

const recentTrips = computed(() => tripsData.value ?? [])

// ─── KPI Stats ───────────────────────────────────────────────────────────────
const kpiStats = computed(() => {
  const trips = recentTrips.value
  const completed = trips.filter(t => t.status === 'completed' || t.status === 'manual_fix')
  const avgDuration = completed.length
    ? Math.round(completed.reduce((s, t) => s + (t.duration_minutes ?? 0), 0) / completed.length)
    : 0
  const timeouts = trips.filter(t => t.status === 'timeout').length
  const syncRate = trips.length ? Math.round((completed.length / trips.length) * 100) : 0

  return [
    { label: 'Total Trips', value: trips.length, sub: 'All-time records', color: '#f5f5f5' },
    { label: 'Avg Duration', value: avgDuration + 'm', sub: 'Completed trips', color: '#d4896a' },
    { label: 'Sync Rate', value: syncRate + '%', sub: 'Completed / total', color: '#d53734' },
    { label: 'Timeouts', value: timeouts, sub: 'Unresolved trips', color: '#e74c3c' },
  ]
})

// ─── Trend Line Chart (last 7 days avg durations) ────────────────────────────
const trendLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']

const trendData = computed(() => {
  const trips = recentTrips.value.filter(t => t.duration_minutes != null && t.status !== 'timeout')
  const now = new Date()
  return trendLabels.map((_, i) => {
    const dayOffset = 6 - i
    const targetDate = new Date(now)
    targetDate.setDate(now.getDate() - dayOffset)
    const dayTrips = trips.filter(t => {
      const d = new Date(t.start_time)
      return d.getFullYear() === targetDate.getFullYear() &&
             d.getMonth() === targetDate.getMonth() &&
             d.getDate() === targetDate.getDate()
    })
    if (!dayTrips.length) return 0
    return Math.round(dayTrips.reduce((s, t) => s + t.duration_minutes, 0) / dayTrips.length)
  })
})

// SVG coordinate system: x 0-500, y 0-180 (inverted, max 120 min)
const trendCoords = computed(() => {
  const max = Math.max(...trendData.value, 1)
  return trendData.value.map((v, i) => ({
    x: 30 + (i / (trendLabels.length - 1)) * 440,
    y: 10 + (1 - v / Math.max(max, 120)) * 160
  }))
})

const trendPoints = computed(() =>
  trendCoords.value.map(p => `${p.x},${p.y}`).join(' ')
)

const trendFillPath = computed(() => {
  const pts = trendCoords.value
  if (!pts.length) return ''
  const line = pts.map((p, i) => `${i === 0 ? 'M' : 'L'}${p.x},${p.y}`).join(' ')
  return `${line} L${pts[pts.length - 1].x},185 L${pts[0].x},185 Z`
})

// ─── Scatter Plot: departure hour (x) vs duration (y) ────────────────────────
const vehicleColors = { motor: '#d53734', mobil: '#d4896a', angkot: '#6c8ebf', kereta: '#7a6cbf', bus: '#6c8ebf' }

const scatterPoints = computed(() => {
  return recentTrips.value
    .filter(t => t.duration_minutes != null && t.start_time)
    .slice(0, 80)
    .map(t => {
      const hour = new Date(t.start_time).getHours() + new Date(t.start_time).getMinutes() / 60
      // x: map 5-22h to 50-490
      const x = 50 + ((hour - 5) / 17) * 440
      // y: map 0-120 min to 170-10 (inverted)
      const dur = Math.min(t.duration_minutes, 120)
      const y = 170 - (dur / 120) * 160
      const baseColor = vehicleColors[t.vehicle_type] ?? '#a0a0a0'
      return { x, y, r: 5, color: baseColor }
    })
})

// ─── Pipeline Health Metrics ─────────────────────────────────────────────────
const pipelineMetrics = computed(() => {
  const trips = recentTrips.value
  const total = trips.length || 1
  const completed = trips.filter(t => t.status === 'completed' || t.status === 'manual_fix').length
  const withWeather = trips.filter(t => t.weather_condition).length
  const withEvent = trips.filter(t => t.regional_event).length

  return [
    { label: 'Offline Sync Success', pct: Math.round((completed / total) * 100), desc: 'Trips synced vs total', color: '#d53734' },
    { label: 'Weather Enrichment', pct: Math.round((withWeather / total) * 100), desc: 'Trips with weather data', color: '#d4896a' },
    { label: 'Event Context', pct: Math.round((withEvent / total) * 100), desc: 'Trips on regional events', color: '#6c8ebf' },
  ]
})

// ponytail: naive offline queue size — assumes near-zero in dev; upgrade with real IDB read if needed
const offlineQueueSize = ref(0)
const offlineQueuePct = computed(() => Math.min((offlineQueueSize.value / 10) * 100, 100))

onMounted(async () => {
  // Try to read the real offline queue from IndexedDB
  try {
    const { get } = await import('idb-keyval')
    const q = await get('wpy_offline_sync_queue')
    offlineQueueSize.value = Array.isArray(q) ? q.length : 0
  } catch {
    offlineQueueSize.value = 0
  }
})

// ─── Helpers ─────────────────────────────────────────────────────────────────
const formatTime = (iso) => {
  if (!iso) return '—'
  const d = new Date(iso)
  return d.toLocaleString('id-ID', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' })
}

const statusClass = (status) => ({
  completed: 'bg-green-900/40 text-green-400 border border-green-800',
  running: 'bg-yellow-900/40 text-yellow-400 border border-yellow-800',
  timeout: 'bg-red-900/40 text-red-400 border border-red-800 animate-pulse',
  manual_fix: 'bg-blue-900/40 text-blue-400 border border-blue-800',
}[status] ?? 'bg-phorayana-border text-phorayana-text-secondary')
</script>
