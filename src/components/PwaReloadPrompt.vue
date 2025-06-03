// src/components/PwaReloadPrompt.vue
<template>
  <div v-if="needRefresh" class="pwa-toast" role="alert">
    <div class="message">
      Eine neue Version ist verfügbar.
    </div>
    <button @click="updateServiceWorker()">
      Neu laden
    </button>
    <button @click="close">
      Schließen
    </button>
  </div>
</template>

<script setup lang="ts">
import { useRegisterSW } from 'virtual:pwa-register/vue';

const {
  offlineReady,
  needRefresh,
  updateServiceWorker,
} = useRegisterSW();

const close = async () => {
  offlineReady.value = false;
  needRefresh.value = false;
};

// Optional: Automatisch schließen nach einer Weile oder bei Offline-Bereitschaft
// watch(offlineReady, (isOfflineReady) => {
//   if (isOfflineReady) {
//     // Kann eine andere Nachricht anzeigen oder einfach die needRefresh Nachricht ausblenden
//     // setTimeout(close, 5000); // z.B.
//   }
// });
</script>

<style scoped>
.pwa-toast {
  position: fixed;
  right: 10px;
  bottom: 10px;
  margin: 16px;
  padding: 12px;
  border: 1px solid #8885;
  border-radius: 4px;
  z-index: 1000;
  text-align: left;
  box-shadow: 3px 4px 5px 0 #8885;
  background-color: white;
  color: #333;
  display: flex;
  align-items: center;
  gap: 10px;
}
.pwa-toast .message {
  margin-bottom: 0; /* Angepasst für Flexbox */
  flex-grow: 1;
}
.pwa-toast button {
  border: 1px solid #8885;
  outline: none;
  margin-left: 5px;
  border-radius: 2px;
  padding: 5px 10px;
  cursor: pointer;
}
</style>