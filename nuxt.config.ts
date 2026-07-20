// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: [
    '@nuxtjs/tailwindcss',
    '@nuxtjs/supabase',
    '@vite-pwa/nuxt'
  ],
  css: [
    '~/assets/css/tailwind.css'
  ],
  tailwindcss: {
    cssPath: '~/assets/css/tailwind.css',
    configPath: 'tailwind.config.js'
  },
  supabase: {
    redirectOptions: {
      login: '/login',
      callback: '/confirm',
      exclude: []
    }
  },
  pwa: {
    registerType: 'autoUpdate',
    manifest: {
      name: 'Phorayana',
      short_name: 'Phorayana',
      description: 'Phorayana crowdsourced commute duration logger',
      theme_color: '#181818',
      background_color: '#181818',
      icons: [
        {
          src: 'icon.png',
          sizes: '192x192',
          type: 'image/png'
        },
        {
          src: 'icon.png',
          sizes: '512x512',
          type: 'image/png'
        }
      ]
    },
    workbox: {
      navigateFallback: '/',
      runtimeCaching: [
        {
          urlPattern: /^https:\/\/bagzjhigoulgbxejeayz\.supabase\.co\/rest\/v1\/trips.*/,
          handler: 'NetworkOnly',
          method: 'POST',
          options: {
            backgroundSync: {
              name: 'phorayana-offline-trips',
              options: {
                maxRetentionTime: 24 * 60
              }
            }
          }
        },
        {
          urlPattern: /^https:\/\/bagzjhigoulgbxejeayz\.supabase\.co\/rest\/v1\/trips.*/,
          handler: 'NetworkOnly',
          method: 'PATCH',
          options: {
            backgroundSync: {
              name: 'phorayana-offline-trips',
              options: {
                maxRetentionTime: 24 * 60
              }
            }
          }
        }
      ]
    },
    devOptions: {
      enabled: true,
      type: 'module'
    }
  },
  devServer: {
    host: '0.0.0.0'
  }
})



