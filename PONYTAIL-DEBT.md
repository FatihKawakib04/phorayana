# PONYTAIL DEBT LEDGER

Daftar utang teknis (technical debt) dan penyederhanaan sengaja yang ditandai dengan komentar `ponytail:` di dalam repositori Phorayana.

| Berkas & Baris | Deskripsi Penyederhanaan / Batasan (Ceiling) | Rencana Peningkatan (Upgrade Path / Trigger) | Status / Tag |
| :--- | :--- | :--- | :--- |
| [app/app.vue:L2](file:///d:/Users/FATIH/Documents/File%20Fatih%20Kawakib%20Kartono/Portfolio/WPY/phorayana/app/app.vue#L2) | global SEO and PWA-readiness tags | - | `no-trigger` |
| [app/pages/god-kawakib.vue:L370](file:///d:/Users/FATIH/Documents/File%20Fatih%20Kawakib%20Kartono/Portfolio/WPY/phorayana/app/pages/god-kawakib.vue#L370) | naive offline queue size — assumes near-zero in dev | upgrade with real IDB read if needed | `[RESOLVED]` |
| [app/pages/index.vue:L383](file:///d:/Users/FATIH/Documents/File%20Fatih%20Kawakib%20Kartono/Portfolio/WPY/phorayana/app/pages/index.vue#L383) | direct client queries, fat page component. Ceiling: offline queries fail, index.vue is 560+ lines. | refactor logic to useSavedPlaces and build IndexedDB sync queue (Refactoring vs Offline-First Skala Prioritas) | `[RESOLVED]` |
| [supabase/migrations/20260717203033_init_schema.sql:L1](file:///d:/Users/FATIH/Documents/File%20Fatih%20Kawakib%20Kartono/Portfolio/WPY/phorayana/supabase/migrations/20260717203033_init_schema.sql#L1) | exact schema definitions from PRD Section 5 | - | `no-trigger` |
| [supabase/migrations/20260717203900_setup_rls_policies.sql:L1](file:///d:/Users/FATIH/Documents/File%20Fatih%20Kawakib%20Kartono/Portfolio/WPY/phorayana/supabase/migrations/20260717203900_setup_rls_policies.sql#L1) | RLS configuration for Phorayana tables | - | `no-trigger` |
| [supabase/migrations/20260720162500_protect_profiles.sql:L2](file:///d:/Users/FATIH/Documents/File%20Fatih%20Kawakib%20Kartono/Portfolio/WPY/phorayana/supabase/migrations/20260720162500_protect_profiles.sql#L2) | simple trigger to force role='user' on insert and prevent unauthorized changes on update | - | `no-trigger` |
| [supabase/migrations/20260720165000_add_history_columns_to_trips.sql:L2](file:///d:/Users/FATIH/Documents/File%20Fatih%20Kawakib%20Kartono/Portfolio/WPY/phorayana/supabase/migrations/20260720165000_add_history_columns_to_trips.sql#L2) | simple numeric and jsonb columns to track distance and route path | - | `no-trigger` |

---
**Ringkasan**: 7 penanda terdata (5 berstatus `no-trigger`, 2 telah diselesaikan: `[RESOLVED]`).
