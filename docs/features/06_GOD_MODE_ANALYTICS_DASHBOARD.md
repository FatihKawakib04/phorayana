# Spesifikasi Fitur: God Mode Analytics Dashboard (`/god-kawakib`)

Dokumen ini mendeskripsikan fitur pemantauan ekosistem khusus pengembang (*God Mode*) yang menyajikan analitik data komunal secara transparan tanpa mengorbankan privasi pengguna.

---

## 1. Pengamanan Rute & Akses Middleware (`god-auth.ts`)

- **Disguised Admin URL**: Rute `/god-kawakib` sengaja tidak menggunakan pola umum `/admin` untuk mengurangi risiko brute-force.
- **Proteksi Middleware**: Middleware `app/middleware/god-auth.ts` memeriksa token JWT secara sinkron (`supabase.auth.getUser()`) dan melakukan JOIN relasi ke `public.roles` via `profiles.role_id`.
- **Otorisasi**: Hanya pengguna dengan `roles.name = 'god'` yang diizinkan mengakses halaman. Pengguna biasa (*role* `'user'`) atau pengguna tanpa autentikasi otomatis di-redirect ke halaman utama (`/`).

---

## 2. Metrik & Visualisasi Data Anonim (Tanpa PII)

Untuk menjaga privasi komunitas, seluruh grafik analitik mengagregasikan data tanpa menampilkan informasi identitas pribadi (PII seperti nama atau email):

- **Community Trend Line Chart**: Fluktuasi durasi dan kemacetan rute utama.
- **Scatter Plot**: Hubungan jam keberangkatan vs durasi perjalanan.
- **Route Heatmap**: Kerapatan lalulintas lambat berdasarkan blok waktu.
- **Data Pipeline Health**: Tingkat keberhasilan sinkronisasi offline, ukuran antrean IndexedDB, dan latensi API.
- **Client-Only Rendering**: Seluruh visualisasi grafik SVG dibungkus dengan komponen `<ClientOnly>` untuk mencegah kesalahan hidrasi (*hydration mismatch*) pada SSR Nuxt 3.
