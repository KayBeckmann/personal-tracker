// src/main.ts
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router' // Importiere den Router
import './style.css'

const app = createApp(App)

app.use(createPinia())
app.use(router) // Verwende den Router
app.mount('#app')