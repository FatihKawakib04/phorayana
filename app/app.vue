<script setup lang="ts">
// ponytail: global SEO and PWA-readiness tags
useSeoMeta({
  title: 'Phorayana | Commuter Portal',
  description: 'Phorayana is a crowdsourced micro-scale travel duration logging platform.',
  ogTitle: 'Phorayana | Commuter Portal',
  ogDescription: 'Phorayana is a crowdsourced micro-scale travel duration logging platform.',
  ogType: 'website',
  ogImage: 'https://phorayana.netlify.app/og-image.png',
  twitterCard: 'summary_large_image',
  twitterTitle: 'Phorayana | Commuter Portal',
  twitterDescription: 'Phorayana is a crowdsourced micro-scale travel duration logging platform.',
  twitterImage: 'https://phorayana.netlify.app/og-image.png',
})

useHead({
  htmlAttrs: {
    lang: 'id' // Default to Indonesian context as per target user commuting in Bogor/Jakarta
  },
  meta: [
    { name: 'theme-color', content: '#1A1A1A' },
    { name: 'mobile-web-app-capable', content: 'yes' },
    { name: 'apple-mobile-web-app-capable', content: 'yes' },
    { name: 'apple-mobile-web-app-status-bar-style', content: 'black-translucent' }
  ]
})
</script>

<template>
  <div>
    <NuxtRouteAnnouncer />
    <NuxtPage />
  </div>
</template>
