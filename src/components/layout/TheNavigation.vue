<template>
  <nav class="main-nav">
    <router-link to="/" class="nav-item" active-class="active">
      <i class="fas fa-tachometer-alt"></i>
      <span class="nav-text">Dashboard</span>
    </router-link>
    <router-link to="/tasks" class="nav-item" active-class="active">
      <i class="fas fa-tasks"></i>
      <span class="nav-text">Aufgaben</span>
    </router-link>
    <router-link to="/notes" class="nav-item" active-class="active">
      <i class="fas fa-sticky-note"></i>
      <span class="nav-text">Notizen</span>
    </router-link>
    <router-link to="/habits" class="nav-item" active-class="active">
      <i class="fas fa-calendar-check"></i>
      <span class="nav-text">Gewohnheiten</span>
    </router-link>
    <router-link to="/budget" class="nav-item" active-class="active">
      <i class="fas fa-wallet"></i>
      <span class="nav-text">Haushalt</span>
    </router-link>
    <router-link to="/settings" class="nav-item" active-class="active">
      <i class="fas fa-cog"></i>
      <span class="nav-text">Einstellungen</span>
    </router-link>
  </nav>
</template>

<style scoped>
.main-nav {
  display: flex;
  justify-content: center;
  background-color: var(--color-background-soft);
  padding: 0.5rem 0;
  margin-bottom: 2rem;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  overflow-x: auto; /* Für sehr kleine Bildschirme */
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 0.75rem 1.5rem;
  color: var(--color-text-soft);
  text-decoration: none;
  transition: color 0.2s, background-color 0.2s;
  border-radius: 8px;
  margin: 0 0.25rem;
}

.nav-item i {
  font-size: 1.5rem;
  margin-bottom: 0.25rem;
}

.nav-item .nav-text {
  font-size: 0.8rem;
  font-weight: 500;
}

.nav-item:hover {
  background-color: var(--color-background-mute);
  color: var(--color-primary);
}

.nav-item.active {
  color: var(--color-primary-dark);
  font-weight: bold;
}

/* Responsive Design: Für Bildschirme kleiner als 768px */
@media (max-width: 768px) {
  .main-nav {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    justify-content: space-around;
    border-radius: 0;
    box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
    z-index: 1000;
    background-color: var(--color-background);
    padding: 0.5rem 0;
  }

  /* Text ausblenden auf mobilen Geräten */
  .nav-item .nav-text {
    display: none;
  }

  .nav-item i {
    font-size: 1.75rem; /* Icons etwas größer machen */
    margin-bottom: 0;
  }

  .nav-item {
    padding: 0.5rem;
  }
}
</style>