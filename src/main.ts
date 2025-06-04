// src/main.ts
import { createApp } from 'vue';
import { createPinia } from 'pinia';

import App from './App.vue';
import router from './router'; // Dein Router-Setup
import './style.css'; // Deine globalen Styles

// Importiere Bootstrap CSS (wenn du es via npm installiert hast)
// import 'bootstrap/dist/css/bootstrap.min.css';
// Importiere Bootstrap JS Bundle (enthält Popper)
// import 'bootstrap/dist/js/bootstrap.bundle.min.js';


// Importiere FontAwesome (wenn du es via npm installiert hast und global nutzen möchtest)
// z.B. mit @fortawesome/fontawesome-free
// import '@fortawesome/fontawesome-free/css/all.min.css';


const app = createApp(App);

app.use(createPinia()); // Pinia für State Management einbinden
app.use(router); // Vue Router einbinden

app.mount('#app'); // Die App an das DOM-Element mit der ID 'app' mounten