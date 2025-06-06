<template>
  <div class="daily-events-view">
    <header class="view-header">
      <h1>Tägliche Ereignisse</h1>
      <p>Zeichne die Ereignisse deines Tages auf, wie in einem Tagebuch.</p>
      <div class="controls">
        <input type="date" v-model="selectedDate" class="date-picker" />
        <button @click="setToday" class="btn-today">Heute</button>
      </div>
    </header>

    <main>
      <div class="add-event-card">
        <h2>Neues Ereignis für den {{ formattedSelectedDate }} hinzufügen</h2>
        <form @submit.prevent="handleAddEvent" class="add-event-form">
          <div class="form-row">
            <div class="form-group time-group">
              <label for="new-event-time">Uhrzeit</label>
              <input id="new-event-time" v-model="newEvent.time" type="time" required />
            </div>
            <div class="form-group title-group">
              <label for="new-event-title">Titel</label>
              <input id="new-event-title" v-model="newEvent.title" type="text" placeholder="Was ist passiert?" required />
            </div>
            <div class="form-group type-group">
              <label for="new-event-type">Kategorie</label>
              <input id="new-event-type" v-model="newEvent.type" type="text" placeholder="z.B. Arbeit, Freizeit" />
            </div>
          </div>
          <div class="form-group">
            <label for="new-event-description">Beschreibung (optional)</label>
            <textarea id="new-event-description" v-model="newEvent.description" placeholder="Füge mehr Details hinzu..."></textarea>
          </div>
          <button type="submit" class="btn-add">Ereignis hinzufügen</button>
        </form>
      </div>

      <div class="events-list">
        <h2>Ereignisse am {{ formattedSelectedDate }}</h2>
        <div v-if="store.isLoading" class="loading-message">Lade Ereignisse...</div>
        <div v-else-if="eventsForSelectedDate.length === 0" class="empty-message">
          Für diesen Tag wurden keine Ereignisse erfasst.
        </div>
        <ul v-else class="event-items">
          <li v-for="event in eventsForSelectedDate" :key="event.id" class="event-item">
            <div class="event-time">{{ formatTime(event.startTime) }}</div>
            <div class="event-details">
              <div class="event-header">
                <h3 class="event-title">{{ event.title }}</h3>
                <span v-if="event.type" class="event-type">{{ event.type }}</span>
              </div>
              <p v-if="event.description" class="event-description">{{ event.description }}</p>
            </div>
            <div class="event-actions">
              <button @click="deleteEvent(event.id!)" class="btn-delete">❌</button>
            </div>
          </li>
        </ul>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue';
import { useDailyEventStore } from '@/stores/dailyEventStore';
import type { DailyEvent } from '@/services/db';

const store = useDailyEventStore();

// Hilfsfunktion, um ein Datum in das<y_bin_46>-MM-DD Format zu bringen
const toISODateString = (date: Date) => date.toISOString().split('T')[0];

// NEUE Hilfsfunktion: Gibt die aktuelle Stunde als String im Format "HH:00" zurück
const getCurrentHourAsString = () => {
  const now = new Date();
  const hours = now.getHours().toString().padStart(2, '0');
  return `${hours}:00`;
};

const selectedDate = ref(toISODateString(new Date()));

const newEvent = reactive({
  title: '',
  description: '',
  type: '',
  time: getCurrentHourAsString(), // Angepasst: Setzt die aktuelle Stunde als Standard
});

// Ruft die gefilterten Events aus dem Store ab
const eventsForSelectedDate = computed(() => {
  return store.getEventsForDate(selectedDate.value);
});

// Formatiert das Datum für die Anzeige in der UI
const formattedSelectedDate = computed(() => {
  const date = new Date(selectedDate.value + 'T00:00:00'); // Safari-kompatibel
  return date.toLocaleDateString('de-DE', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
});

// Formatiert die Zeit für die Anzeige
const formatTime = (date: Date | string) => {
  const dateObj = typeof date === 'string' ? new Date(date) : date;
  return dateObj.toLocaleTimeString('de-DE', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  });
};

const setToday = () => {
  selectedDate.value = toISODateString(new Date());
};

const handleAddEvent = async () => {
  if (!newEvent.title || !newEvent.time) {
    alert('Bitte gib eine Uhrzeit und einen Titel für das Ereignis an.');
    return;
  }

  // Kombiniere Datum und Zeit zu einem Date-Objekt
  const startTime = new Date(`${selectedDate.value}T${newEvent.time}`);

  const eventData: Omit<DailyEvent, 'id' | 'createdAt'> = {
    title: newEvent.title,
    description: newEvent.description,
    type: newEvent.type,
    startTime: startTime,
  };

  await store.addEvent(eventData);

  // Formular zurücksetzen, Uhrzeit auf die nächste volle Stunde setzen
  newEvent.title = '';
  newEvent.description = '';
  newEvent.type = '';
  newEvent.time = getCurrentHourAsString(); // Setzt die Zeit nach dem Hinzufügen erneut
};

const deleteEvent = async (id: number) => {
  if (confirm('Bist du sicher, dass du dieses Ereignis löschen möchtest?')) {
    await store.deleteEvent(id);
  }
};

onMounted(() => {
  store.fetchEvents();
});

</script>

<style scoped>
.daily-events-view {
  display: flex;
  flex-direction: column;
  gap: 2rem;
  text-align: left;
  width: 100%;
}

.view-header {
  border-bottom: 1px solid var(--color-border-soft);
  padding-bottom: 1.5rem;
}

.view-header h1 {
  margin-bottom: 0.25rem;
}

.view-header p {
  margin-top: 0;
  color: var(--color-text-light);
}

.controls {
  display: flex;
  gap: 1rem;
  align-items: center;
  margin-top: 1rem;
}

.date-picker {
  padding: 0.5rem;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  font-size: 1rem;
  background-color: var(--color-background);
  color: var(--color-text);
}

.btn-today {
  padding: 0.5rem 1rem;
  border-radius: 6px;
  border: 1px solid var(--color-primary);
  background-color: var(--color-primary-light);
  color: var(--color-primary-darker);
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
}

.btn-today:hover {
  background-color: #b9d5ff;
}

.add-event-card {
  background-color: var(--color-background);
  padding: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.add-event-card h2 {
  margin-top: 0;
  border-bottom: 1px solid var(--color-border-soft);
  padding-bottom: 0.75rem;
  margin-bottom: 1rem;
  font-size: 1.25rem;
}

.add-event-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.form-group label {
  font-size: 0.9rem;
  font-weight: 500;
  color: var(--color-text-soft);
}

.form-group input,
.form-group textarea {
  padding: 0.6rem;
  border: 1px solid var(--color-border);
  border-radius: 6px;
  font-size: 1rem;
  font-family: inherit;
}

.form-group.time-group { flex: 1 1 100px; }
.form-group.title-group { flex: 3 1 250px; }
.form-group.type-group { flex: 2 1 150px; }


.form-group textarea {
  min-height: 80px;
  resize: vertical;
}

.btn-add {
  align-self: flex-start;
  padding: 0.75rem 1.5rem;
  border-radius: 6px;
  border: none;
  background-color: var(--color-primary);
  color: white;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
}

.btn-add:hover {
  background-color: var(--color-primary-dark);
}

.events-list h2 {
    margin-top: 2rem;
    font-size: 1.25rem;
}

.loading-message, .empty-message {
  text-align: center;
  padding: 2rem;
  color: var(--color-text-light);
  background-color: var(--color-background);
  border-radius: 8px;
}

.event-items {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.event-item {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  padding: 1rem;
  background-color: var(--color-background);
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}

.event-time {
  font-weight: 600;
  font-size: 1.1rem;
  background-color: var(--color-background-soft);
  color: var(--color-primary-dark);
  padding: 0.5rem;
  border-radius: 6px;
  min-width: 50px;
  text-align: center;
}

.event-details {
  flex-grow: 1;
}

.event-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 0.5rem;
}

.event-title {
  margin: 0;
  font-size: 1.1rem;
}

.event-type {
    background-color: var(--color-background-mute);
    color: var(--color-text-soft);
    padding: 0.2rem 0.5rem;
    border-radius: 10px;
    font-size: 0.8rem;
    white-space: nowrap;
}

.event-description {
  margin: 0.5rem 0 0;
  color: var(--color-text-soft);
  white-space: pre-wrap; /* Bewahrt Zeilenumbrüche */
}

.event-actions {
  align-self: center;
}

.btn-delete {
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 50%;
  aspect-ratio: 1/1;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background-color 0.2s;
}

.btn-delete:hover {
    background-color: var(--color-danger-darker);
    color: white;
}
</style>