# Product Requirements Document (PRD)

## Project: Phorayana
**Version:** 1.0 — Final  
**Status:** Approved / Architecture & Design Locked  
**Author:** Fatih Kawakib Kartono  
**Date:** 2026-07-17  
**Classification:** Hobby / Sandbox Project (Independent from KodeMaverick Core)

---

## 1. Executive Summary

**Phorayana** (from Greek *Phora* = movement/flow + Sanskrit *Ayana* = route/journey) is a **crowdsourced local traffic log platform** built on the principle of **"From User, For User."**

Unlike ordinary travel duration trackers, Phorayana is designed as a **Contextual Big Data micro-scale system**. It collects real-world travel duration data from a collective group of users, then enriches it with external contextual variables (weather and regional event calendars) to train the system into providing intelligent route congestion indicators for the user community.

**Core Philosophy:**
- Zero-typing input to eliminate user friction and abandonment.
- Offline-first architecture so the app works even without signal or data quota.
- Transparent aggregate data for the developer ("/god" mode) while keeping individual user data strictly isolated.
- Community-powered: the more users tap, the smarter the congestion predictions become.

---

## 2. Target Platform & Audience

| Attribute | Specification |
|-----------|---------------|
| **Platform** | Mobile-First Progressive Web App (PWA) |
| **Primary Device** | Smartphone (90% of interactions happen on-the-go) |
| **Primary User** | Daily commuters (students, interns, office workers) who need efficient route duration logging to optimize daily departure times |
| **Secondary User** | Developer / Admin (Fatih) monitoring aggregate data health |
| **Deployment** | Netlify Free Tier |

---

## 3. Core Functional Features

### 3.1. 1-Tap Check-In Widget (Zero-Typing UI)
The main homepage form that allows users to log trips without typing a single character.

**Scenario — Departure:**
- User opens the app on mobile.
- System reads default preferences (last vehicle used, saved places).
- User taps one large button: **"Mulai Perjalanan"**.
- System instantly records departure timestamp and origin GPS coordinates.
- UI state transitions to "Running" mode.

**Scenario — Arrival:**
- Upon reaching the destination, user taps the button now labeled: **"Saya Sudah Sampai"**.
- System records arrival timestamp, calculates duration in minutes, and triggers a serverless function to fetch current weather data automatically.
- State transitions to "Summary" view.

**UI Behavior:**
- Single macro button dominates the screen.
- Button color shifts dynamically:
  - Idle / Ready: *Phorayana Red* (`#d53734`)
  - Running: *Soft Terracotta* (`#d4896a`)
  - Arrival / Complete: *Phorayana Red* with confirmation pulse

---

### 3.2. Sticky Vehicle Form (Vehicle Class Generalization)
Provides a **Vehicle Class** selector: Motor, Mobil, Angkot/Bus, Kereta.

**Smart Behavior:**
- The form automatically pre-selects the last vehicle used by the user (sticky last-input state persisted in the database).
- Users can change the vehicle with a single tap before tapping "Mulai Perjalanan."
- This ensures zero friction for the 90% case where the user takes the same vehicle type every day.

---

### 3.3. Multi-Location & Instant GPS Capture
Flexibility to record trips based on destination type.

**Saved Places (Profile-Based):**
- Users can register frequently visited locations in their profile: Home, Campus, Cafe A, Internship Office, etc.
- These appear in a quick-access dropdown on the home screen.

**Instant GPS Capture (One-Off Locations):**
- For rarely visited places, users can enable "Gunakan Lokasi Saat Ini."
- The app captures real-time coordinates via the Browser Geolocation API.
- Coarse latitude/longitude data is still sent to the database to enrich communal route insights.

---

### 3.4. Offline-First Engine (Network Failure Resilience)
Guarantees the app remains lightweight and functional when the user runs out of data quota or loses signal mid-journey.

**Mechanism:**
- If `navigator.onLine` is `false` when the user taps the macro button, the app stores a JSON object locally in **IndexedDB** (via `idb-keyval` or `localForage`).
- The **Service Worker** (powered by `@vite-pwa/nuxt` / Workbox) listens for background sync events.
- As soon as the device reconnects to Wi-Fi or mobile data, the Service Worker automatically pushes the queued data to Supabase without requiring the user to reopen the app.
- Device performance remains light because IndexedDB is a native browser API.

**Offline Data Structure (IndexedDB):**
```json
{
  "action": "start_trip",
  "timestamp": "2026-07-17T07:15:00Z",
  "lat": -6.595,
  "lng": 106.806,
  "vehicle": "motor",
  "synced": false
}
```

---

### 3.5. Forgotten Checkout Handler (Timeout Logic)
Prevents garbage data from entering the system when a user forgets to tap "Sampai."

**Auto-Timeout:**
- If a trip remains in `running` status beyond a reasonable threshold (default: **3 hours**) without extreme GPS movement, the backend Nitro function automatically locks the trip status to `timeout`.

**Manual Fix (Next-Day Recovery):**
- When the user opens the app the next day and a `timeout` trip is detected, the "Mulai Jalan" button is locked.
- A restricted correction form appears:  
  *"Kamu lupa mengakhiri perjalanan kemarin. Masukkan durasi riil perjalananmu (Maksimal 120 menit):"*
- The input is strictly capped (e.g., max 120 minutes) to preserve the integrity of the big data ecosystem.

---

### 3.6. Platform Brain: Contextual Big Data Engine
The server-side intelligence layer that goes beyond static time logs.

**Input Variables:**
1. **Historical trip data** from all users (anonymized).
2. **Real-time weather** (auto-fetched from **Open-Meteo API** upon checkout).
3. **Regional event calendar** (public holidays, city anniversaries, local festivals — e.g., HUT Bogor, HUT Jakarta, Cap Go Meh, etc.) via scraping or calendar API.

**Feature Engineering:**
- The system assigns a **congestion weight** to specific routes based on aggregated community data.
- If multiple users record bloated durations on Jl. Pajajaran at 07:30 on Tuesdays, the route's weight increases.
- If the current date coincides with a regional event near the route, the system adds an event multiplier to the congestion prediction.

**Output:**
- Predictive alerts on the user dashboard:  
  *"Rute ini terdeteksi melambat 2.5x lipat pada hari Selasa jam 07:00–07:30 berdasarkan 12 riwayat perjalanan terakhir di komunitas."*

---

### 3.7. God Mode (`/god-kawakib`)
A disguised admin route for the developer to monitor the entire ecosystem transparently.

**URL:** `/god-kawakib`  
*(Deliberately avoids the predictable `/admin` pattern to reduce brute-force probing.)*

**Access Control:**
- **Nuxt Route Middleware:** `middleware/god-auth.ts` checks the authenticated session. Non-Fatih users are redirected to `/`.
- **Supabase RLS:** Aggregate tables enforce `auth.uid() = 'fatih-uuid'` for read access.

**Metrics Rendered:**
- Community Trend Line Chart: fluctuation of congestion times across Bogor's main routes.
- System Activity Table: latest incoming trips (anonymized, no PII).
- Scatter Plot: departure time vs. duration.
- Route Heatmap: density of slow traffic by area and time block.
- Data Pipeline Health: sync success rate, offline queue size, API latency.

---

## 4. Tech Stack & Architecture

### 4.1. Core Stack (100% Free Tier)

| Layer | Technology | Role |
|-------|-----------|------|
| **Framework** | Nuxt 3 (TypeScript) | Full-stack Vue framework; SSG for static pages, SSR/Edge Functions for dynamic API routes |
| **Hosting** | Netlify | Serverless deployment with generous free tier |
| **Database & Auth** | Supabase | PostgreSQL + Auth (Email, Google, GitHub, Discord OAuth) + Row Level Security |
| **Styling** | Tailwind CSS + Radix Vue / Nuxt UI | Soft minimalism, generous whitespace, matte-doff aesthetic |
| **PWA Engine** | `@vite-pwa/nuxt` (Workbox) | Service Worker registration, background sync, offline caching |
| **Local Storage** | `idb-keyval` or `localForage` | Lightweight IndexedDB wrapper for offline trip queuing |
| **Data Viz** | `vue-chartjs` or `apexcharts` | Charts for `/god-kawakib` dashboard |
| **Weather API** | Open-Meteo API | Free, no API key required for basic weather data |

### 4.2. Authentication Methods (Omni-Channel)
To minimize registration friction, Phorayana supports:
- Email + Password
- Google OAuth (One-Tap)
- GitHub Auth
- Discord Auth

All credentials are hashed server-side by Supabase Auth. The developer cannot view raw passwords.

---

## 5. Database Schema (Supabase PostgreSQL)

### 5.1. `profiles`
Stores user preferences and role flags.

```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  updated_at TIMESTAMP WITH TIME ZONE,
  full_name TEXT,
  last_vehicle_used TEXT DEFAULT 'motor',
  role TEXT DEFAULT 'user'  -- 'god' reserved for Fatih
);
```

### 5.2. `saved_places`
Stores user-defined frequent locations.

```sql
CREATE TABLE saved_places (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  place_name TEXT NOT NULL,  -- e.g., 'Home', 'Kampus IPB', 'Cafe A'
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
```

### 5.3. `trips` (Core Data Log)
Stores every journey recorded by users.

```sql
CREATE TABLE trips (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  vehicle_type TEXT NOT NULL,  -- 'motor', 'mobil', 'angkot', 'kereta', etc.

  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE,  -- NULL if running / timeout

  -- GPS coordinates (supports both saved places & instant capture)
  start_lat DOUBLE PRECISION NOT NULL,
  start_lng DOUBLE PRECISION NOT NULL,
  end_lat DOUBLE PRECISION,
  end_lng DOUBLE PRECISION,

  start_place_id BIGINT REFERENCES saved_places(id),
  end_place_id BIGINT REFERENCES saved_places(id),

  duration_minutes INTEGER,  -- Auto-calculated on checkout
  weather_condition TEXT,    -- Auto-fetched from Open-Meteo
  regional_event TEXT,       -- Auto-fetched from calendar API

  status TEXT DEFAULT 'running' 
    CHECK (status IN ('running', 'completed', 'timeout', 'manual_fix')),

  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
```

---

## 6. Design System & Color Palette

Phorayana adopts a **Warm Asphalt Matte** aesthetic — flat, doff, free from glossy effects, heavy blur, or thick drop shadows. Comfortable for long viewing under varying mobile lighting conditions.

| Token | Hex | Usage |
|-------|-----|-------|
| **Base Background** | `#181818` | Warm Asphalt — main app background |
| **Card Surfaces** | `#222222` | Elevated cards, panels |
| **Borders / Dividers** | `#333333` | Subtle separation lines |
| **Primary CTA** | `#d53734` | **Phorayana Red** — "Mulai Jalan", Save, primary actions |
| **Secondary Accent** | `#d4896a` | **Soft Terracotta** — "Sampai Tujuan", Running badges, hover states |
| **High Severity Alert** | `#e74c3c` | **Signal Red** — Timeout warnings, critical notifications |
| **Text Primary** | `#f5f5f5` | Off-white headings |
| **Text Secondary** | `#a0a0a0` | Muted descriptions, timestamps |

**Typography:** Modern sans-serif (e.g., Inter or Geist), generous line-height, thin-to-medium weights for a clean, editorial feel.

---

## 7. Data Security & Privacy

### 7.1. Credential Protection
- All passwords are **hashed and encrypted** by Supabase Auth using industry-standard bcrypt.
- Even the developer cannot view or retrieve raw password strings.

### 7.2. Horizontal Data Isolation (RLS)
- `trips` and `saved_places` tables are protected by **Row Level Security** policies.
- Regular users can only `SELECT/INSERT/UPDATE/DELETE` rows where `user_id = auth.uid()`.
- Users cannot peek into each other's detailed travel histories.

### 7.3. Aggregate Transparency (Developer Access)
- Individual trip records remain private.
- Anonymized aggregate metrics (coordinates, time blocks, durations, weather) are exposed to the `/god-kawakib` dashboard for platform health monitoring and congestion research.
- No PII (names, emails) is displayed in the God Mode analytics views.

---

## 8. User Flow Summary

```
[Open App] 
  → [Auto-detect last vehicle] 
  → [Select Saved Place OR Instant GPS] 
  → [Tap "Mulai Jalan"] 
  → [Lock phone, commute]
  → [Arrive → Tap "Saya Sudah Sampai"] 
  → [System calculates duration + fetches weather] 
  → [View Summary Card]

[Offline Variant]
  → [Tap "Mulai Jalan" while offline] 
  → [Data queued in IndexedDB] 
  → [Reconnect to Wi-Fi] 
  → [Service Worker auto-syncs to Supabase silently]

[Forgot Checkout Variant]
  → [Trip auto-locks to 'timeout' after 3h] 
  → [Next day: button locked, Manual Fix form shown] 
  → [User inputs capped duration] 
  → [Data saved with 'manual_fix' status]
```

---

## 9. Success Metrics (Future)

| Metric | Target |
|--------|--------|
| **Input Friction** | < 2 taps to start a trip |
| **Offline Sync Reliability** | 100% of queued trips sync within 60s of reconnection |
| **Data Integrity** | < 1% of trips require manual fix |
| **Prediction Accuracy** | Congestion alerts correlate with > 70% of actual slow trips |
| **User Retention** | Active users still logging after 30 days |

---

## 10. Out of Scope (v1.0)

- Real-time GPS tracking during the trip (passive logging only).
- Native mobile app (iOS/Android). PWA only.
- Paid subscriptions or monetization.
- Integration with Google Maps / Waze routing APIs.
- Push notifications (browser notifications may be added in v1.1).

---

## 11. Appendix: Glossary

| Term | Definition |
|------|------------|
| **Phorayana** | Platform name; movement + route |
| **1-Tap Check-In** | Zero-typing trip logging via a single macro button |
| **Sticky Vehicle** | Auto-selection of the last used vehicle class |
| **God Mode** | Developer-only analytics route at `/god-kawakib` |
| **Contextual Big Data** | Enriching trip logs with weather & regional events |
| **Manual Fix** | Restricted form for users who forgot to checkout |

---

*Document locked. Ready for development handoff.*
