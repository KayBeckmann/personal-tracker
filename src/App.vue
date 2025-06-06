// src/App.vue
<template>
  <div id="app-container">
    <header>
      <nav>
        <router-link to="/">Dashboard</router-link>
        <router-link to="/tasks">Tasks</router-link>
        <router-link to="/notes">Notes</router-link>
        <router-link to="/habits">Habits</router-link>
        <router-link to="/events">Daily Events</router-link>
        <router-link to="/budget">Budget</router-link> </nav>
    </header>
    <main>
      <router-view v-slot="{ Component }">
        <keep-alive>
          <component :is="Component" />
        </keep-alive>
      </router-view>
    </main>
    <footer>
      <p>&copy; {{ new Date().getFullYear() }} Meine Produktivitäts-App</p>
      <PwaReloadPrompt />

      <div>
        Über einen 
        <a href="https://www.buymeacoffee.com/snuppedelua" target="_blank" rel="noopener noreferrer">Kaffee</a>
        würde ich mich freuen!
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import PwaReloadPrompt from '@/components/PwaReloadPrompt.vue'; // Erstellen wir gleich
</script>

<style>
/* Globale Styles oder spezifische für App.vue */
#app-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}

header {
  background-color: #4DBA87; /* Vue Grün */
  padding: 15px 20px;
  color: white;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

nav {
  display: flex;
  gap: 15px;
  justify-content: center; /* Zentriert die Navigationslinks */
}

nav a {
  font-weight: bold;
  color: #fff; /* Weiß für bessere Lesbarkeit auf dunklem Hintergrund */
  text-decoration: none;
  padding: 8px 12px;
  border-radius: 4px;
  transition: background-color 0.3s ease;
}

nav a.router-link-exact-active {
  background-color: #368a67; /* Dunkleres Grün für aktiven Link */
}

nav a:hover {
  background-color: #42aa7b;
}

main {
  flex-grow: 1;
  padding: 20px;
  background-color: #f4f7f6; /* Heller Hintergrund für den Content-Bereich */
}

footer {
  text-align: center;
  padding: 15px;
  background-color: #333;
  color: #fff;
  font-size: 0.9em;
}
</style>