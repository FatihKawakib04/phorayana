# Dokumentasi Arsitektur & Teknis: Tracking Engine & UI Refactor (Phorayana)

Dokumen ini menjelaskan implementasi teknis untuk modul **Tracking Engine**, penguatan filter jitter, ketahanan offline (antiloss), sistem lupa check-out (timeout), form perbaikan manual, serta refaktorisasi UI menjadi dropdown kustom berbasis Warm Asphalt Matte.

---

## 1. RINGKASAN EKSEKUSI

Pada sesi pengembangan ini, kami berhasil menyelesaikan implementasi end-to-end untuk fitur pelacakan perjalanan (trip tracking) komunal pada aplikasi Phorayana:
*   **Tracking Engine Core**: Pelacakan GPS real-time menggunakan `navigator.geolocation.watchPosition` dengan filter akurasi jitter (< 30 meter) dan filter jarak pergeseran (Haversine Formula > 10 meter).
*   **Sticky Vehicle**: Integrasi database profiles untuk menyimpan jenis kendaraan default terakhir yang dipilih pengguna secara persisten.
*   **Custom Dropdown UI**: Penggantian dropdown native select bawaan HTML dengan struktur UI kustom (Button + Panel Div) untuk mencegah kebocoran warna default OS/browser (seperti ring biru indigo) dan mempertahankan keselarasan tema Matte Asphalt.
*   **Timeout Safeguard & Manual Fix**: Proteksi otomatis jika pelacakan perjalanan aktif melebihi 3 jam. Aplikasi akan menghentikan GPS tracker lokal, mengunci antarmuka, dan menampilkan form perbaikan durasi log perjalanan (maksimal 120 menit) dengan status `manual_fix`.
*   **Offline Fallback Sync**: Antrean check-out dan perbaikan manual secara lokal menggunakan LocalStorage (`wpy_offline_sync_queue`) saat koneksi terputus, dilengkapi dengan sinkronisasi otomatis ketika koneksi kembali online.

---

## 2. DETAIL IMPLEMENTASI TEKNIS

### A. Skema State Reaktif Baru (`app/pages/index.vue`)
Berikut adalah reactive state tambahan yang diperkenalkan pada component untuk mengelola siklus hidup perjalanan dan antarmuka kustom:
*   `isTracking` (ref<boolean>): Menandakan apakah trip pelacakan GPS sedang berjalan aktif.
*   `elapsedTime` (ref<number>): Menyimpan waktu berjalan dalam detik sejak perjalanan dimulai.
*   `activeTripId` (ref<string|null>): Menyimpan UUID trip yang sedang berjalan di database.
*   `activeTripStartTime` (ref<string|null>): Menyimpan stempel waktu ISO awal perjalanan dimulai.
*   `isTimeout` (ref<boolean>): Bernilai `true` jika perjalanan terdeteksi berjalan > 3 jam.
*   `manualDurationMinutes` (ref<number|null>): State input untuk durasi perbaikan manual (1–120 menit).
*   `routePath` (ref<array>): Array koordinat titik GPS `{ lat, lng, t }` yang lolos filter jitter & jarak.
*   `isStartPlaceDropdownOpen` & `isEndPlaceDropdownOpen` (ref<boolean>): Mengendalikan visibilitas panel menu opsi dropdown kustom untuk titik keberangkatan dan tujuan.
*   `startPlaceLabel` & `endPlaceLabel` (computed): Mengembalikan label teks lokasi terpilih atau teks default "Gunakan Lokasi Saat Ini (Instant GPS)".

### B. Database Handshake (Tabel `trips` dan `profiles`)
Operasi integrasi data Supabase berjalan pada alur berikut:
1.  **Sticky Vehicle Preference**:
    *   Saat halaman diinisialisasi (`initDashboard()`), data `profiles.last_vehicle_used` dibaca untuk menetapkan nilai default `selectedVehicle`.
    *   Jika pengguna mengubah jenis kendaraan sebelum mulai, query `UPDATE profiles SET last_vehicle_used = ...` dipicu secara reaktif.
2.  **Mulai Perjalanan (`startTrip()`)**:
    *   Akses posisi awal GPS diambil via `getCurrentPosition`.
    *   Melakukan `INSERT INTO trips` dengan parameter `status = 'running'`, `vehicle_type`, `start_place_id`, `start_lat`, dan `start_lng`.
    *   UUID yang dikembalikan disimpan ke `activeTripId` dan local storage.
3.  **Check-out Normal / Timeout (`endTrip()` / `submitManualFix()`)**:
    *   Menghitung total jarak terakumulasi (`distance_km`) menggunakan formula Haversine.
    *   Melakukan query cuaca ke Open-Meteo API berdasarkan koordinat akhir.
    *   Melakukan `UPDATE trips` untuk memperbarui `status = 'completed'` atau `status = 'manual_fix'`, `end_lat`, `end_lng`, `duration_minutes`, `weather_temperature`, `weather_condition_code`, dan array `route_path`.

### C. Arsitektur Custom Dropdown UI (Button + Panel Div)
Native select HTML diganti dengan pola komponen kustom di mana element select orisinil ditiadakan:
*   **Struktur HTML**: Menggunakan element `<button>` sebagai trigger yang di dalamnya menampilkan teks label terhitung (`startPlaceLabel`) dan ikon chevron SVG.
*   **Panel Dropdown**: Element `div` absolut terposisi `z-50` yang muncul jika dropdown terbuka. List di dalamnya dirender menggunakan perulangan `v-for="place in savedPlaces"`.
*   **Manajemen Focus & Highlight**: Styling diatur penuh menggunakan utility Tailwind (`bg-phorayana-surface` `#222222`, text `#f5f5f5`, hover item `#333333` dan teks aksen `#d4896a`). Hal ini menghilangkan leak warna biru indigo sistem operasi.
*   **Click-Outside Listener**: Event listener window ditambahkan saat `onMounted` untuk memantau klik. Jika target klik berada di luar container `.place-dropdown-container`, panel dropdown akan ditutup secara paksa.

### D. Logika Timeout Safeguard & Proteksi SSR
*   **Durasi Deteksi**: Batas durasi yang diizinkan untuk trip berstatus `running` adalah 3 jam (10.800 detik).
*   **Skenario Pemulihan**: Saat rehidrasi lokal (`initActiveTripSession`) atau sinkronisasi dashboard (`initDashboard`), selisih waktu `start_time` dengan waktu saat ini dihitung. Jika melebihi batas, status tracker dinonaktifkan (`isTracking = false`) dan dialihkan ke mode interupsi timeout (`isTimeout = true`).
*   **Proteksi SSR**: Penggunaan `setInterval`, `clearInterval`, event listener window, dan API `navigator.geolocation` dibungkus dengan pengecekan `import.meta.client` (atau `process.client` di Nuxt) agar tidak memicu error *node environment* saat server-side rendering.

### E. Alur Kerja Fallback Offline Sync
*   **Offline Queue**: Jika operasi check-out atau penyimpanan perbaikan manual gagal akibat putus jaringan (deteksi via `!navigator.onLine` atau kegagalan API fetch), payload transaksi dimasukkan ke antrean LocalStorage `wpy_offline_sync_queue`.
*   **Automated Sync**: Event listener `online` didaftarkan ke objek `window`. Begitu koneksi terpulihkan, fungsi `syncOfflineQueue()` akan mengeksekusi iterasi antrean, mengirimkan query update Supabase satu per satu, dan mengosongkan antrean jika berhasil.

---

## 3. HASIL VERIFIKASI & TESTING

Pengujian fungsionalitas dan ketahanan visual telah dilakukan secara menyeluruh:
1.  **Simulasi Timeout di Database**:
    Menjalankan query SQL untuk memajukan waktu perjalanan aktif 4 jam ke belakang:
    ```sql
    UPDATE trips SET start_time = NOW() - INTERVAL '4 hours' WHERE status = 'running';
    ```
2.  **Verifikasi Antarmuka Browser QA**:
    *   Memastikan halaman memicu tampilan interupsi **"Lupa Check-Out Terdeteksi"** seketika setelah halaman direload.
    *   Memasukkan durasi perbaikan manual `45` menit, menekan simpan, dan memverifikasi data ter-update ke database dengan status `manual_fix`.
    *   Memastikan antarmuka berhasil bersih dari outline merah bawaan dan warna biru pilihan sistem operasi.
