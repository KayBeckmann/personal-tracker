<template>
  <div id="app-wrapper">
    <TheNavigation />
    <main class="content">
      <RouterView />
    </main>
  </div>
  <footer>
      <p>&copy; {{ new Date().getFullYear() }} Meine Produktivitäts-App</p>
      <PwaReloadPrompt />

      <div>
        Über einen 
        <a href="https://www.buymeacoffee.com/snuppedelua" target="_blank" rel="noopener noreferrer">Kaffee</a>
        würde ich mich freuen!
      </div>
    </footer>
</template>

<script setup lang="ts">
import TheNavigation from './components/layout/TheNavigation.vue';
import { RouterView } from 'vue-router';
</script>

<style scoped>
footer {
  bottom: 0;
  left: 0;
  width: 100%;
  padding: 10px;
  text-align: center;
  border-top: 1px solid #dee2e6;
}
#app-wrapper {
  display: flex;
  flex-direction: column;
  width: 100%;
}

.content {
  flex-grow: 1;
  padding-bottom: 80px; /* Platz für die mobile Navigation am unteren Rand */
}

@media (min-width: 769px) {
  .content {
    padding-bottom: 0; /* Kein zusätzlicher Abstand auf dem Desktop */
  }
}
</style>