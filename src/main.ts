// src/main.ts
import { createApp } from 'vue';
import { createPinia } from 'pinia';

import App from './App.vue';
import router from './router';
import './style.css';

// Importiere FontAwesome
import '@fortawesome/fontawesome-free/css/all.min.css'; // Diese Zeile aktivieren

const app = createApp(App);

app.use(createPinia());
app.use(router);

app.mount('#app');