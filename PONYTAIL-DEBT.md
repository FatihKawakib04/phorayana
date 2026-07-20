# PONYTAIL DEBT LEDGER

Daftar utang teknis (technical debt) dan penyederhanaan sengaja yang ditandai dengan komentar `ponytail:` di dalam repositori Phorayana.

| Berkas & Baris | Deskripsi Penyederhanaan / Batasan (Ceiling) | Rencana Peningkatan (Upgrade Path / Trigger) | Status / Tag |
| :--- | :--- | :--- | :--- |
| [app/pages/index.vue:L234](file:///d:/Users/FATIH/Documents/File%20Fatih%20Kawakib%20Kartono/Portfolio/WPY/phorayana/app/pages/index.vue#L234) | **Direct client queries, fat page component.** Batasan: Query akan gagal saat offline; file index.vue berukuran > 560 baris. | Refactor logika CRUD ke custom composables (`useSavedPlaces`) dan bangun antrean offline IndexedDB sync. **(Refactoring vs Offline-First Skala Prioritas)** | `active` |
| [app/app.vue:L2](file:///d:/Users/FATIH/Documents/File%20Fatih%20Kawakib%20Kartono/Portfolio/WPY/phorayana/app/app.vue#L2) | Pemuatan SEO global dan tag PWA-readiness. | - | `no-trigger` |
| [app/pages/index.vue:L106](file:///d:/Users/FATIH/Documents/File%20Fatih%20Kawakib%20Kartono/Portfolio/WPY/phorayana/app/pages/index.vue#L106) | Pengambilan koordinat GPS secara sinkronus tanpa mekanisme pembatalan. | - | `no-trigger` |
| [20260717203033_init_schema.sql:L1](file:///d:/Users/FATIH/Documents/File%20Fatih%20Kawakib%20Kartono/Portfolio/WPY/phorayana/supabase/migrations/20260717203033_init_schema.sql#L1) | Skema tabel database statis sesuai PRD Bagian 5. | - | `no-trigger` |
| [20260717203900_setup_rls_policies.sql:L1](file:///d:/Users/FATIH/Documents/File%20Fatih%20Kawakib%20Kartono/Portfolio/WPY/phorayana/supabase/migrations/20260717203900_setup_rls_policies.sql#L1) | Konfigurasi RLS awal untuk tabel Phorayana. | - | `no-trigger` |
| [20260720162500_protect_profiles.sql:L2](file:///d:/Users/FATIH/Documents/File%20Fatih%20Kawakib%20Kartono/Portfolio/WPY/phorayana/supabase/migrations/20260720162500_protect_profiles.sql#L2) | Trigger database untuk menangani pencegahan eskalasi role 'god' pada tingkat RLS. | - | `no-trigger` |
| [20260720165000_add_history_columns_to_trips.sql:L2](file:///d:/Users/FATIH/Documents/File%20Fatih%20Kawakib%20Kartono/Portfolio/WPY/phorayana/supabase/migrations/20260720165000_add_history_columns_to_trips.sql#L2) | Kolom database minimalis (`distance_km` dan `route_path`) untuk riwayat. | - | `no-trigger` |

---
**Ringkasan**: 7 penanda ditemukan, 6 diantaranya berstatus `no-trigger`.
