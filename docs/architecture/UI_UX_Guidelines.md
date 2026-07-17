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
- **No Blurry Drop Shadows**: Do not use standard CSS box shadows with blur radii. Rely instead on solid, hard-edged offset shadows to define elevation.
- **No Gradients**: Rely purely on flat background fills (`bg-phorayana-base` and `bg-phorayana-surface`).
- **High-Contrast Typography**: Off-white primary text (`text-phorayana-text-primary`) and muted secondary text (`text-phorayana-text-secondary`).

---

## 3. Shape Behavior (Neobrutalism & Tactile Interaction)

To create a tactile, physical feel for a PWA undervarying mobile lighting conditions, Phorayana incorporates a structured Neobrutalist aesthetic for shapes and interactive states:

### Layout Borders & Shadows
- **Thick Borders**: Utilize thick solid borders on container panels, cards, inputs, and buttons (typically `border-2 border-black`).
- **Hard Offset Shadows**: Implement flat, solid, high-contrast black shadows to elevate surfaces instead of blurry shadows:
  - Standard Elevation: `shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]`
- **Large Rounded Corners**: Use distinct rounded corners (`rounded-xl` or `rounded-2xl`) on inputs, cards, and buttons to balance the heavy borders.

### Interactive Tactile Click States (Buttons & Clickable Cards)
- On `:hover` or `:focus`, buttons can slightly translate or highlight.
- On `:active` (the moment of clicking/pressing down), elements should translate down and to the right while reducing the offset shadow to simulate a physical, tactile click:
  - Standard Press state: `active:translate-x-1 active:translate-y-1 active:shadow-none` or `active:translate-x-[2px] active:translate-y-[2px] active:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]`
  - Ensure `transition-all duration-150` is applied to smooth this tactile feedback.

