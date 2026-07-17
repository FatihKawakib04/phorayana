# Phorayana UI/UX Implementation Guidelines

This document establishes the UI/UX rendering guidelines and responsive design strategy for Phorayana.

## 1. Responsive Layout Strategy

### Core Philosophy
Phorayana is designed as a **Mobile-First Progressive Web App (PWA)**, but it must deliver a fully immersive experience on Desktop/larger viewports.
- **Do NOT** trap the desktop user interface inside a centered mobile-sized container mockup (such as a device frame or fixed 400px column) on larger monitors.
- **Do** expand the layout responsively using CSS Grid or Flexbox to leverage the additional screen estate.

### Desktop Behavior (Full-Width Immersive)
- For screen sizes `md` (768px) and above, restructure the content columns or widgets (e.g., placing the Check-In Widget, Recent Log Table, and Community Analytics side-by-side).
- Use `max-w-screen-2xl` and `mx-auto` only on the outermost wrapper container to limit maximum expansion on ultrawide monitors and prevent horizontal text stretch.

### Tailwind CSS Strategy
- Write default Tailwind classes targeting mobile screens first.
- Leverage responsive prefixes (`sm:`, `md:`, `lg:`, `xl:`) to alter dimensions, padding, grid columns, and visibility on wider viewports.

---

## 2. Aesthetics & Matte Design System

All elements must adhere to the **Warm Asphalt Matte** system. 

### Core Restrictions
- **No Glossy Effects**: Avoid overlays, blurs, or gradients mimicking glassmorphism.
- **No Drop Shadows**: Use solid borders (`border-phorayana-border`) to separate cards or elevated panels.
- **No Gradients**: Rely purely on flat background fills (`bg-phorayana-base` and `bg-phorayana-surface`).
- **High-Contrast Typography**: Off-white primary text (`text-phorayana-text-primary`) and muted secondary text (`text-phorayana-text-secondary`).
