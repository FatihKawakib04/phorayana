/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./components/**/*.{js,vue,ts}",
    "./layouts/**/*.vue",
    "./pages/**/*.vue",
    "./plugins/**/*.{js,ts}",
    "./app.vue",
    "./error.vue"
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
