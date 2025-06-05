// src/main.ts
import { createApp } from 'vue';
import { createPinia } from 'pinia';

import App from './App.vue';
import router from './router'; // Dein Router-Setup
import './style.css'; // Deine globalen Styles

// Importiere FontAwesome (wenn du es via npm installiert hast und global nutzen möchtest)
// z.B. mit @fortawesome/fontawesome-free
// import '@fortawesome/fontawesome-free/css/all.min.css';


const app = createApp(App);

app.use(createPinia()); // Pinia für State Management einbinden
app.use(router); // Vue Router einbinden

app.mount('#app'); // Die App an das DOM-Element mit der ID 'app' mounten