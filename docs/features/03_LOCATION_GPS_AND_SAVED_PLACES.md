# Spesifikasi Fitur: Multi-Location, Instant GPS Capture & Saved Places

Dokumen ini mendeskripsikan spesifikasi teknis dan alur penanganan lokasi pada aplikasi Phorayana, mencakup penangkapan koordinat Geolocation real-time dan manajemen lokasi langganan (Saved Places CRUD).

---

## 1. Modus Penangkapan Lokasi

### 1.1. Saved Places (Lokasi Terdaftar)
Pengguna dapat mendaftarkan lokasi yang sering dikunjungi (Rumah, Kampus, Kantor, Kafe) ke tabel `public.saved_places`.
- **Penggunaan di UI**: Lokasi ini muncul dalam pilihan *quick dropdown* pada formulir utama `app/pages/index.vue`.
- **Aturan RLS**: Pengguna hanya dapat membaca, menambah, dan menghapus lokasi miliknya sendiri (`user_id = auth.uid()`).

### 1.2. Instant GPS Capture (Lokasi Insidental)
Untuk lokasi sekali pakai yang tidak didaftarkan:
- Pengguna mengaktifkan opsi *"Gunakan Lokasi Saat Ini"*.
- Aplikasi memanggil **Browser Geolocation API** (`navigator.geolocation.getCurrentPosition`) dengan opsi `enableHighAccuracy: true`.
- Koordinat latitude dan longitude ditangkap secara otomatis saat pengguna menekan tombol "Mulai Jalan" atau "Saya Sudah Sampai".

---

## 2. Diagram Alur Penanganan Lokasi

```mermaid
sequenceDiagram
    participant User as Commuter
    participant UI as index.vue
    participant GPS as Geolocation API
    participant DB as Supabase DB

    alt Menggunakan Saved Place
        User->>UI: Pilih Lokasi dari Dropdown (Saved Place)
        UI->>UI: Bind start_place_id / end_place_id
    else Menggunakan Instant GPS
        User->>UI: Aktifkan "Gunakan Lokasi Saat Ini"
        UI->>GPS: Request Current Coordinates
        GPS-->>UI: Return Latitude & Longitude
        UI->>UI: Bind start_lat / start_lng
    end
    UI->>DB: Execute INSERT / UPDATE trip record
```
