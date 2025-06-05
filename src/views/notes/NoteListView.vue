<template>
  <div class="note-list-view">
    <h1>Meine Notizen</h1>

    <div class="filters-container">
      <div class="form-group">
        <label for="search-term">Suche:</label>
        <input type="text" id="search-term" :value="noteStore.searchTerm" @input="updateSearchTermHandler" placeholder="Titel oder Inhalt durchsuchen..." />
      </div>
      <div class="form-group">
        <label>Nach Tags filtern:</label>
        <div v-if="availableTags.length > 0" class="tag-filter-options">
          <div v-for="tag in availableTags" :key="tag" class="tag-checkbox">
            <input type="checkbox" :id="`tag-filter-${tag}`" :value="tag" :checked="noteStore.selectedTags.includes(tag)" @change="toggleTagFilterHandler(tag)" />
            <label :for="`tag-filter-${tag}`" class="tag-filter-label">{{ tag }}</label>
          </div>
        </div>
        <p v-else class="no-tags-message">Keine Tags für Filterung vorhanden.</p>
        <button @click="clearFiltersHandler" class="btn-clear-filters" v-if="noteStore.selectedTags.length > 0 || noteStore.searchTerm">
          Filter zurücksetzen
        </button>
      </div>
    </div>

    <router-link :to="{ name: 'NoteCreate' }" class="btn btn-primary btn-create-note">
      Neue Notiz erstellen
    </router-link>

    <div v-if="noteStore.isLoading" class="loading-indicator">
      <p>Notizen werden geladen...</p>
      <div class="spinner"></div>
    </div>
    <div v-if="noteStore.error" class="error-message">
      Fehler beim Laden der Notizen: {{ noteStore.error }}
    </div>

    <div v-if="!noteStore.isLoading && filteredNotesToDisplay.length === 0 && !noteStore.error" class="info-message">
      Keine Notizen gefunden, die den aktuellen Filterkriterien entsprechen.
      <span v-if="noteStore.notes.length > 0">Versuche, die Filter anzupassen.</span>
      <span v-else>Erstelle deine erste Notiz!</span>
    </div>

    <div class="notes-grid" v-if="filteredNotesToDisplay.length > 0">
      <div v-for="note in filteredNotesToDisplay" :key="note.id" class="note-card">
        <div class="note-card-body">
          <h3 class="note-title">
            <router-link :to="{ name: 'NoteView', params: { id: note.id } }">{{ note.title }}</router-link>
          </h3>
          <div class="note-tags-display" v-if="note.tags && note.tags.length > 0">
            <span v-for="tag in note.tags" :key="tag" class="tag-item-list">{{ tag }}</span>
          </div>
          <p class="note-date">
            <small>Erstellt: {{ formatDate(note.createdAt) }}</small>
          </p>
          <p class="note-date">
            <small>Zuletzt geändert: {{ formatDate(note.updatedAt) }}</small>
          </p>
        </div>
        <div class="note-card-footer">
          <router-link :to="{ name: 'NoteEdit', params: { id: note.id } }" class="btn btn-secondary btn-edit">
            Bearbeiten
          </router-link>
          <button @click="confirmDeleteNoteHandler(note.id!)" class="btn btn-danger btn-delete">
            Löschen
          </button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue';
import { useNoteStore } from '@/stores/noteStore';
// import { useRouter } from 'vue-router'; // Nicht direkt verwendet

const noteStore = useNoteStore();

onMounted(() => {
  // Store lädt Notizen via liveQuery, ein expliziter Aufruf ist i.d.R. nicht nötig.
  // Falls doch: noteStore.fetchNotes();
});

const filteredNotesToDisplay = computed(() => noteStore.filteredNotes);
const availableTags = computed(() => noteStore.allTags);

const formatDate = (dateValue: Date | string | number | undefined) => {
  if (!dateValue) return 'N/A';
  const date = new Date(dateValue);
  return date.toLocaleDateString('de-DE', {
    year: 'numeric', month: 'long', day: 'numeric',
    hour: '2-digit', minute: '2-digit'
  });
};

const confirmDeleteNoteHandler = async (id: number | undefined) => {
  if (id === undefined) {
    console.error('NoteListView: Delete called with undefined ID.');
    return;
  }
  console.log(`NoteListView: confirmDeleteNoteHandler aufgerufen für ID: ${id}`);
  if (window.confirm('Bist du sicher, dass du diese Notiz löschen möchtest?')) {
    console.log(`NoteListView: Löschbestätigung erhalten für ID: ${id}. Rufe Store auf...`);
    await noteStore.deleteNote(id);
    console.log(`NoteListView: noteStore.deleteNote(${id}) ausgeführt.`);
    // Ansicht sollte sich durch Reaktivität aktualisieren
  } else {
    console.log(`NoteListView: Löschvorgang für ID: ${id} abgebrochen.`);
  }
};

const updateSearchTermHandler = (event: Event) => {
  const target = event.target as HTMLInputElement;
  noteStore.setSearchTerm(target.value);
};

const toggleTagFilterHandler = (tag: string) => {
  const currentSelectedTags = [...noteStore.selectedTags];
  const index = currentSelectedTags.indexOf(tag);
  if (index > -1) {
    currentSelectedTags.splice(index, 1);
  } else {
    currentSelectedTags.push(tag);
  }
  noteStore.setSelectedTags(currentSelectedTags);
};

const clearFiltersHandler = () => {
  noteStore.setSearchTerm('');
  noteStore.setSelectedTags([]);
};
</script>

<style scoped>
.note-list-view {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}
.note-list-view h1 {
  margin-bottom: 1.5rem;
  text-align: center;
  color: var(--color-heading);
}

.filters-container {
  background-color: var(--color-background-soft, #f8f9fa);
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.form-group {
  margin-bottom: 1rem;
}
.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: var(--color-text-soft);
}
.form-group input[type="text"] {
  width: 100%;
  padding: 0.6rem 0.8rem;
  border: 1px solid var(--color-border, #ced4da);
  border-radius: 4px;
  box-sizing: border-box;
}

.tag-filter-options {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 0.5rem;
}
.tag-checkbox {
  display: flex;
  align-items: center;
}
.tag-checkbox input[type="checkbox"] {
  opacity: 0; /* Versteckt, da Label geklickt wird */
  width: 0;
  height: 0;
  position: absolute;
}
.tag-filter-label {
  padding: 0.4em 0.8em;
  border-radius: 4px;
  background-color: var(--color-background-mute, #e9ecef);
  color: var(--color-text, #495057);
  cursor: pointer;
  transition: background-color 0.2s, color 0.2s;
  border: 1px solid transparent;
}
.tag-checkbox input[type="checkbox"]:checked + .tag-filter-label {
  background-color: var(--color-primary, #007bff);
  color: white;
  border-color: var(--color-primary-dark, #0056b3);
}
.tag-filter-label:hover {
  background-color: var(--color-background-hover, #dee2e6);
}
.tag-checkbox input[type="checkbox"]:checked + .tag-filter-label:hover {
  background-color: var(--color-primary-dark, #0056b3);
}
.no-tags-message {
  font-style: italic;
  color: var(--color-text-soft);
}
.btn-clear-filters {
  margin-top: 0.75rem;
  padding: 0.4em 0.8em;
  font-size: 0.9em;
  background-color: var(--color-secondary, #6c757d);
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
.btn-clear-filters:hover {
  background-color: var(--color-secondary-dark, #5a6268);
}

.btn-create-note {
  display: inline-block;
  margin-bottom: 1.5rem;
  padding: 0.75rem 1.5rem;
}

.loading-indicator, .info-message {
  text-align: center;
  padding: 20px;
  margin-top: 1rem;
  border-radius: 4px;
}
.info-message {
  background-color: var(--color-info-background, #e0f7fa);
  color: var(--color-info-text, #00796b);
  border: 1px solid var(--color-info-border, #b2ebf2);
}
.error-message { /* bereits in NoteEditView, hier ggf. anpassen/vereinheitlichen */
  background-color: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
  padding: 0.75rem 1.25rem;
  border-radius: 0.25rem;
  margin-top: 1rem;
}


.notes-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}
.note-card {
  background-color: var(--color-background, #fff);
  border: 1px solid var(--color-border, #e0e0e0);
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  display: flex;
  flex-direction: column;
  transition: box-shadow 0.2s ease-in-out;
}
.note-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}
.note-card-body {
  padding: 1rem 1.25rem;
  flex-grow: 1;
}
.note-title a {
  text-decoration: none;
  color: var(--color-heading, #333);
  font-size: 1.25rem;
  font-weight: 600;
}
.note-title a:hover {
  color: var(--color-primary, #007bff);
}
.note-tags-display {
  margin: 0.5rem 0;
}
.tag-item-list {
  display: inline-block;
  background-color: var(--color-background-mute, #e9ecef);
  color: var(--color-text-soft, #555);
  padding: 0.25em 0.6em;
  border-radius: 0.2rem;
  margin-right: 5px;
  margin-bottom: 5px;
  font-size: 0.8em;
}
.note-date {
  font-size: 0.8rem;
  color: var(--color-text-light, #777);
  margin-bottom: 0.25rem;
}
.note-card-footer {
  padding: 0.75rem 1.25rem;
  background-color: var(--color-background-soft, #f8f9fa);
  border-top: 1px solid var(--color-border, #e0e0e0);
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}

.btn { /* Generische Button-Klasse, falls benötigt */
  padding: 0.5em 1em;
  border-radius: 4px;
  border: 1px solid transparent;
  cursor: pointer;
  text-decoration: none;
  display: inline-block;
  text-align: center;
  font-weight: 500;
}
.btn-primary {
  background-color: var(--color-primary, #007bff);
  color: white;
  border-color: var(--color-primary, #007bff);
}
.btn-primary:hover {
  background-color: var(--color-primary-dark, #0056b3);
  border-color: var(--color-primary-darker, #004085);
}
.btn-secondary {
  background-color: var(--color-secondary, #6c757d);
  color: white;
  border-color: var(--color-secondary, #6c757d);
}
.btn-secondary:hover {
  background-color: var(--color-secondary-dark, #5a6268);
  border-color: var(--color-secondary-darker, #545b62);
}
.btn-danger {
  background-color: var(--color-danger, #dc3545);
  color: white;
  border-color: var(--color-danger, #dc3545);
}
.btn-danger:hover {
  background-color: var(--color-danger-dark, #c82333);
  border-color: var(--color-danger-darker, #bd2130);
}

.spinner { /* Wiederverwendet von NoteEditView */
  display: inline-block;
  width: 1em;
  height: 1em;
  vertical-align: text-bottom;
  border: 0.15em solid currentColor;
  border-right-color: transparent;
  border-radius: 50%;
  animation: spinner-border 0.75s linear infinite;
}
@keyframes spinner-border {
  to { transform: rotate(360deg); }
}
</style>