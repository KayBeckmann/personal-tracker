<template>
  <div class="habits-view">
    <h1>Habit Tracker</h1>

    <div class="card add-habit-form">
      <div class="card-header">
        <h3>Neue Gewohnheit hinzufügen</h3>
      </div>
      <form @submit.prevent="saveNewHabit">
        <div class="form-group">
          <label for="habit-name">Name der Gewohnheit</label>
          <input
            type="text"
            id="habit-name"
            class="form-control"
            v-model="newHabit.name"
            required
            placeholder="z.B. 30 Minuten lesen"
          />
        </div>
        <div class="form-group">
          <label for="habit-frequency">Häufigkeit</label>
          <select id="habit-frequency" class="form-control" v-model="newHabit.frequency">
            <option value="daily">Täglich</option>
            <option value="weekly">Wöchentlich</option>
            <option value="monthly">Monatlich</option>
          </select>
        </div>
        <button type="submit" class="btn btn-primary">Habit Speichern</button>
      </form>
    </div>

    <div v-if="isLoading" class="loading">Lade Gewohnheiten...</div>
    <div v-if="error" class="error-message">{{ error }}</div>

    <div v-if="!isLoading && habits.length" class="habit-list">
      <h2>Deine Gewohnheiten</h2>
      <div v-for="habit in habits" :key="habit.id" class="card habit-card">
        <div class="habit-info">
          <h3>{{ habit.name }}</h3>
          <p>
            Häufigkeit: {{ habit.frequency }} |
            Streak: <i class="fa-solid fa-fire"></i> {{ habit.streak }}
          </p>
        </div>
        <div class="habit-actions">
           <button
            @click="habitStore.toggleHabitCompletionForToday(habit.id!)"
            :class="['btn', habitStore.isHabitCompletedOnDate(habit.id!, todayDateString) ? 'btn-success' : 'btn-secondary']"
          >
            <i :class="['fa-solid', habitStore.isHabitCompletedOnDate(habit.id!, todayDateString) ? 'fa-check-square' : 'fa-square']"></i>
            Heute erledigt
          </button>
          <button @click="deleteHabit(habit.id!)" class="btn btn-danger btn-sm">
             <i class="fa-solid fa-trash"></i>
          </button>
        </div>
      </div>
    </div>
     <div v-else-if="!isLoading && !habits.length">
      <p>Noch keine Gewohnheiten erstellt. Füge jetzt deine erste hinzu!</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useHabitStore } from '@/stores/habitStore';
import { storeToRefs } from 'pinia';

const habitStore = useHabitStore();
// KORREKTUR: Nur State und Getter mit storeToRefs extrahieren.
const { habits, isLoading, error } = storeToRefs(habitStore);

// Funktionen und Actions werden direkt auf der Store-Instanz aufgerufen.
const todayDateString = computed(() => habitStore.getTodayDateString());

const newHabit = ref({
  name: '',
  frequency: 'daily' as 'daily' | 'weekly' | 'monthly',
});

const saveNewHabit = async () => {
  if (newHabit.value.name.trim() === '') return;
  
  // KORREKTUR: Action direkt auf der Store-Instanz aufrufen
  await habitStore.addHabit({
    name: newHabit.value.name,
    frequency: newHabit.value.frequency,
  });
  
  // Formular zurücksetzen
  newHabit.value.name = '';
  newHabit.value.frequency = 'daily';
};

const deleteHabit = async (id: number) => {
    if(confirm('Bist du sicher, dass du diese Gewohnheit und alle zugehörigen Einträge löschen möchtest?')) {
        // KORREKTUR: Action direkt auf der Store-Instanz aufrufen
        await habitStore.deleteHabit(id);
    }
}
</script>

<style scoped>
.habits-view {
  max-width: 800px;
  margin: auto;
}
.add-habit-form {
  margin-bottom: 2rem;
}
.habit-list .card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}
.habit-info {
  flex-grow: 1;
}
.habit-actions .btn {
  margin-left: 0.5rem;
}
.btn-success {
    background-color: var(--color-success);
    color: white;
}
.error-message {
    color: var(--color-danger);
    background-color: rgba(220, 53, 69, 0.1);
    border: 1px solid var(--color-danger);
    padding: 1rem;
    border-radius: var(--border-radius);
    margin-bottom: 1rem;
}
</style>