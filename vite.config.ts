// vite.config.ts
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { VitePWA, type VitePWAOptions } from 'vite-plugin-pwa'
import path from 'path' // Importiere path

const pwaOptions: Partial<VitePWAOptions> = {
  registerType: 'autoUpdate', // oder 'prompt' für manuelle Updates durch den User
  injectRegister: 'auto', // 'auto', 'script', 'inline' oder null
  devOptions: {
    enabled: true, // Ermöglicht PWA-Funktionen im Dev-Modus
    type: 'module',
  },
  manifest: {
    name: 'Meine Produktivitäts-App',
    short_name: 'ProduktivApp',
    description: 'Eine App zur Verwaltung von Tasks, Notizen, Habits und Tagesereignissen.',
    theme_color: '#4DBA87', // Beispiel Vue Grün
    background_color: '#ffffff',
    display: 'standalone',
    scope: '/',
    start_url: '/',
    icons: [
      {
        src: 'icons/icon-72x72.png',
        sizes: '72x72',
        type: 'image/png',
        purpose: 'maskable any'
      },
      {
        src: 'icons/icon-96x96.png',
        sizes: '96x96',
        type: 'image/png',
        purpose: 'maskable any'
      },
      {
        src: 'icons/icon-128x128.png',
        sizes: '128x128',
        type: 'image/png',
        purpose: 'maskable any'
      },
      {
        src: 'icons/icon-144x144.png',
        sizes: '144x144',
        type: 'image/png',
        purpose: 'maskable any'
      },
      {
        src: 'icons/icon-152x152.png',
        sizes: '152x152',
        type: 'image/png',
        purpose: 'maskable any'
      },
      {
        src: 'icons/icon-192x192.png',
        sizes: '192x192',
        type: 'image/png',
        purpose: 'maskable any'
      },
      {
        src: 'icons/icon-384x384.png',
        sizes: '384x384',
        type: 'image/png',
        purpose: 'maskable any'
      },
      {
        src: 'icons/icon-512x512.png',
        sizes: '512x512',
        type: 'image/png',
        purpose: 'maskable any'
      },
    ],
  },
  workbox: {
    globPatterns: ['**/*.{js,css,html,ico,png,svg,json,vue,txt,woff2}'],
    // KORREKTUR: Diese Zeile sorgt dafür, dass alle Navigationsanfragen,
    // die auf keinen anderen Cache treffen, auf die index.html zurückfallen.
    navigateFallback: 'index.html',
    // Runtime Caching für API-Anfragen (falls du welche hast)
    // runtimeCaching: [
    //   {
    //     urlPattern: /^https:\/\/api\.example\.com\/.*/i,
    //     handler: 'NetworkFirst',
    //     options: {
    //       cacheName: 'api-cache',
    //       expiration: {
    //         maxEntries: 10,
    //         maxAgeSeconds: 60 * 60 * 24 * 365 // <== 365 Tage
    //       },
    //       cacheableResponse: {
    //         statuses: [0, 200]
    //       }
    //     }
    //   }
    // ]
  }
}

export default defineConfig({
  plugins: [
    vue(),
    VitePWA(pwaOptions)
  ],
  resolve: {
    alias: {
     '@': path.resolve(__dirname, './src'),
    },
  },
})