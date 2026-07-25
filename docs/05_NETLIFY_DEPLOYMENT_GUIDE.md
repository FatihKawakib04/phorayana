# Panduan Deployment & Catatan Rilis Netlify (Phorayana v1.0)

Dokumen ini mencatat konfigurasi deployment otomatis, identitas proyek Netlify, daftar Environment Variables, dan status rilis publik untuk platform **Phorayana v1.0**.

---

## 1. Identitas Proyek & Domain Live

| Parameter | Spesifikasi Produksi |
| :--- | :--- |
| **Project Name** | `phorayana` |
| **Site ID** | `8c8a4bbb-bdcf-4549-b598-b35844dfdbc3` |
| **Production Live URL** | [https://phorayana.netlify.app](https://phorayana.netlify.app) |
| **Team Slug** | `fatihkawakib04` |
| **Git Repository** | `FatihKawakib04/phorayana` (Branch: `main`) |
| **Framework & Build** | Nuxt 3 (TypeScript) — `npx nuxi build` |
| **Publish Directory** | `.output/public` |

---

## 2. Daftar Environment Variables (Netlify Production)

Variabel lingkungan berikut telah disuntikkan secara aman via MCP Netlify:

| Key | Scope | Nilai / Keterangan |
| :--- | :--- | :--- |
| `SUPABASE_URL` | `All` | `https://bagzjhigoulgbxejeayz.supabase.co` |
| `SUPABASE_KEY` | `All` | Key Publishable / Anon Supabase |
| `NODE_VERSION` | `All` | `"20"` |

---

## 3. Otorisasi Domain Supabase Auth

Domain produksi `https://phorayana.netlify.app` telah didaftarkan ke konfigurasi Supabase Auth (`bagzjhigoulgbxejeayz`):
- **Site URL**: `https://phorayana.netlify.app`
- **Redirect URLs**: `https://phorayana.netlify.app/confirm`, `https://phorayana.netlify.app/login`

---

## 4. Status Rilis Phorayana v1.0

- **Status Deployment**: **LIVE / PRODUCTION READY**
- **Fitur Utama Aktif**:
  1. **1-Tap Check-In Widget**: Zero-typing duration logger & *sticky vehicle*.
  2. **Email OTP Registration**: Pendaftaran 6-digit OTP (`verifyOtp`) dengan timer countdown 60s & *anti-user enumeration*.
  3. **Auto-Provisioning DB Profile**: Trigger PostgreSQL `on_auth_user_created` untuk garansi profil atomik.
  4. **RBAC Clean Security**: Skema relasional `public.roles` (`god` vs `user`).
  5. **Offline-First PWA**: Service Worker Workbox & IndexedDB background sync.
  6. **Contextual Big Data**: Pengayaan cuaca Open-Meteo & kalender event kedaerahan `calendar.ts`.
  7. **God Mode Analytics**: Dasbor pengembang anonim tanpa PII di `/god-kawakib`.
