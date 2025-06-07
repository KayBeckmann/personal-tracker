<template>
  <div id="app-wrapper">
    <TheNavigation />
    <main class="content">
      <RouterView />
    </main>
  </div>
</template>

<script setup lang="ts">
import TheNavigation from './components/layout/TheNavigation.vue';
import { RouterView } from 'vue-router';
</script>

<style scoped>
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