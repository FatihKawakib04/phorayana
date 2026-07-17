/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./app/components/**/*.{js,vue,ts}",
    "./app/layouts/**/*.vue",
    "./app/pages/**/*.vue",
    "./app/plugins/**/*.{js,ts}",
    "./app/app.vue",
    "./app/error.vue"
  ],
  theme: {
    extend: {
      colors: {
        phorayana: {
          base: '#181818',
          surface: '#222222',
          border: '#333333',
          primary: '#d53734',
          accent: '#d4896a',
          alert: '#e74c3c',
          'text-primary': '#f5f5f5',
          'text-secondary': '#a0a0a0',
        }
      }
    }
  },
  plugins: [],
}
