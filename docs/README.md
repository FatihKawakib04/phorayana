# Phorayana Project Documentation

Welcome to the documentation folder for Phorayana. This directory houses all architectural, feature-specific, and database design documents for the project.

## Directory Structure

- **`architecture/`**: High-level designs, system blueprints, and the product requirements document (PRD).
  - [PRD_Phorayana_v1.0.md](./architecture/PRD_Phorayana_v1.0.md) — Product Requirements Document (PRD).
  - [01_CORE_MVP_INTEGRATION.md](./architecture/01_CORE_MVP_INTEGRATION.md) — MVP Core implementation walkthrough.
  - [02_TRACKING_ENGINE_UI_REFACTOR.md](./architecture/02_TRACKING_ENGINE_UI_REFACTOR.md) — Visual refactor & timeout safeland logic walkthrough.
  - [03_DEVELOPER_HANDOFF.md](./architecture/03_DEVELOPER_HANDOFF.md) — Developer maintenance handoff guide.
  - [04_RBAC_AND_EMAIL_OTP_SPEC.md](./architecture/04_RBAC_AND_EMAIL_OTP_SPEC.md) — Specification for RBAC roles refactoring, master identity, & Email OTP registration.
- **`features/`**: Detailed specifications, user flows, and wireframes for specific platform capabilities.
  - [01_EMAIL_OTP_AND_AUTH_FLOW.md](./features/01_EMAIL_OTP_AND_AUTH_FLOW.md) — Email OTP 6-digit registration & auth flow specification.
  - [02_ONE_TAP_CHECKIN_AND_OFFLINE_SYNC.md](./features/02_ONE_TAP_CHECKIN_AND_OFFLINE_SYNC.md) — 1-Tap widget state machine & offline PWA background sync.
  - [03_LOCATION_GPS_AND_SAVED_PLACES.md](./features/03_LOCATION_GPS_AND_SAVED_PLACES.md) — Instant GPS capture & Saved Places CRUD specification.
  - [04_TIMEOUT_AND_MANUAL_FIX_RECOVERY.md](./features/04_TIMEOUT_AND_MANUAL_FIX_RECOVERY.md) — Forgotten checkout auto-timeout & capped manual fix recovery form.
  - [05_CONTEXTUAL_BIG_DATA_ENGINE.md](./features/05_CONTEXTUAL_BIG_DATA_ENGINE.md) — Open-Meteo weather integration, event calendar matching, & congestion alerts.
  - [06_GOD_MODE_ANALYTICS_DASHBOARD.md](./features/06_GOD_MODE_ANALYTICS_DASHBOARD.md) — Developer God Mode (`/god-kawakib`), RBAC protection, & anonymous SVG charts.
- **`database/`**: Database design notes, schemas, Entity-Relationship diagrams, and migration details.
  - [01_DATABASE_SCHEMA_AND_RBAC.md](./database/01_DATABASE_SCHEMA_AND_RBAC.md) — Comprehensive PostgreSQL schema, ERD, RBAC roles definition, & RLS policies.
- **`deployment/`**: Release notes & cloud deployment specifications.
  - [05_NETLIFY_DEPLOYMENT_GUIDE.md](./05_NETLIFY_DEPLOYMENT_GUIDE.md) — Netlify production site configuration, Environment Variables, & release status.

