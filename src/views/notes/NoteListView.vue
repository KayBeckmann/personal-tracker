<template>
    <div class="note-list-view">
      <h1>Meine Notizen</h1>
  
      <div class="filters card">
        <div class="form-group">
          <label for="search-term">Suche:</label>
          <input type="text" id="search-term" :value="noteStore.searchTerm" @input="updateSearchTerm" placeholder="Titel oder Inhalt durchsuchen..." />
        </div>
        <div class="form-group">
          <label>Nach Tags filtern:</label>
          <div v-if="availableTags.length > 0" class="tag-filter-options">
            <div v-for="tag in availableTags" :key="tag" class="tag-checkbox">
              <input type="checkbox" :id="`tag-filter-${tag}`" :value="tag" :checked="noteStore.selectedTags.includes(tag)" @change="toggleTagFilter(tag)" />
              <label :for="`tag-filter-${tag}`" class="tag is-clickable">{{ tag }}</label>
            </div>
          </div>
          <p v-else>Keine Tags für Filterung vorhanden.</p>
           <button @click="clearFilters" class="btn btn-secondary btn-sm mt-2" v-if="noteStore.selectedTags.length > 0 || noteStore.searchTerm">
              Filter zurücksetzen
          </button>
        </div>
      </div>
  
      <router-link :to="{ name: 'NoteCreate' }" class="btn btn-primary my-3">
        <i class="fas fa-plus"></i> Neue Notiz erstellen
      </router-link>
  
      <div v-if="noteStore.isLoading" class="loading-indicator">
        <p>Notizen werden geladen...</p>
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>
      <div v-if="noteStore.error" class="alert alert-danger" role="alert">
        Fehler beim Laden der Notizen: {{ noteStore.error }}
      </div>
  
      <div v-if="!noteStore.isLoading && filteredNotes.length === 0 && !noteStore.error" class="alert alert-info">
        Keine Notizen gefunden, die den aktuellen Filterkriterien entsprechen.
        <span v-if="noteStore.notes.length > 0">Versuche, die Filter anzupassen.</span>
        <span v-else>Erstelle deine erste Notiz!</span>
      </div>
  
      <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4" v-if="filteredNotes.length > 0">
        <div v-for="note in filteredNotes" :key="note.id" class="col">
          <div class="card h-100 note-item">
            <div class="card-body">
              <h5 class="card-title">
                <router-link :to="{ name: 'NoteView', params: { id: note.id } }">{{ note.title }}</router-link>
              </h5>
              <div class="note-tags mb-2">
                <span v-for="tag in note.tags" :key="tag" class="tag">{{ tag }}</span>
              </div>
              <p class="card-text created-date">
                <small class="text-muted">Erstellt: {{ formatDate(note.createdAt) }}</small>
              </p>
              <p class="card-text updated-date">
                <small class="text-muted">Zuletzt geändert: {{ formatDate(note.updatedAt) }}</small>
              </p>
            </div>
            <div class="card-footer note-actions">
              <router-link :to="{ name: 'NoteEdit', params: { id: note.id } }" class="btn btn-sm btn-outline-secondary me-2">
                <i class="fas fa-edit"></i> Bearbeiten
              </router-link>
              <button @click="confirmDeleteNote(note.id!)" class="btn btn-sm btn-outline-danger">
                <i class="fas fa-trash"></i> Löschen
              </button>
            </div>
          </div>
        </div>
      </div>
  
    </div>
  </template>
  
  <script setup lang="ts">
  import { computed, onMounted } from 'vue';
  import { useNoteStore } from '@/stores/noteStore';
  import { useRouter } from 'vue-router'; // Import useRouter for navigation if needed, though not used in this version
  
  const noteStore = useNoteStore();
  // const router = useRouter(); // Uncomment if you need router.push() for other actions
  
  onMounted(() => {
    // Der Store lädt die Notizen bereits beim Initialisieren durch den liveQuery.
    // Ein expliziter fetchNotes() Aufruf hier ist ggf. nicht nötig,
    // es sei denn, man möchte sicherstellen, dass die Daten aktuell sind,
    // falls die Komponente re-mounted wird und der Live-Query unterbrochen war.
    // Da der LiveQuery im Store onMounted/onUnmounted behandelt, sollte es passen.
    // Falls nicht, hier einkommentieren:
    // if (noteStore.notes.length === 0) { // Nur laden, wenn leer, um unnötige Ladevorgänge zu vermeiden
    //   noteStore.fetchNotes();
    // }
  });
  
  const filteredNotes = computed(() => noteStore.filteredNotes);
  const availableTags = computed(() => noteStore.allTags);
  
  const formatDate = (dateValue: Date | string | number) => {
    if (!dateValue) return 'N/A';
    const date = new Date(dateValue);
    return date.toLocaleDateString('de-DE', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };
  
  const confirmDeleteNote = async (id: number) => {
    if (window.confirm('Bist du sicher, dass du diese Notiz löschen möchtest?')) {
      await noteStore.deleteNote(id);
      // Die Ansicht aktualisiert sich dank der Reaktivität des Stores und liveQuery
    }
  };
  
  const updateSearchTerm = (event: Event) => {
    const target = event.target as HTMLInputElement;
    noteStore.setSearchTerm(target.value);
  };
  
  const toggleTagFilter = (tag: string) => {
    const currentSelectedTags = [...noteStore.selectedTags];
    const index = currentSelectedTags.indexOf(tag);
    if (index > -1) {
      currentSelectedTags.splice(index, 1);
    } else {
      currentSelectedTags.push(tag);
    }
    noteStore.setSelectedTags(currentSelectedTags);
  };
  
  const clearFilters = () => {
    noteStore.setSearchTerm('');
    noteStore.setSelectedTags([]);
  };
  
  </script>
  
  <style scoped>
  .note-list-view {
    padding: 20px;
    max-width: 1200px; /* Etwas breiter für Kartenansicht */
    margin: 0 auto;
  }
  
  .filters.card {
    background-color: #f8f9fa;
    padding: 20px;
    margin-bottom: 20px;
    border-radius: 0.5rem;
  }
  
  .form-group {
    margin-bottom: 1rem;
  }
  
  .form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: bold;
  }
  
  .form-group input[type="text"] {
    width: 100%;
    padding: 0.5rem;
    border: 1px solid #ced4da;
    border-radius: 0.25rem;
  }
  
  .tag-filter-options {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
  }
  
  .tag-checkbox {
    display: flex;
    align-items: center;
  }
  
  .tag-checkbox input[type="checkbox"] {
    margin-right: 5px;
    visibility: hidden; /* Hide actual checkbox */
    width: 0;
    height: 0;
  }
  
  .tag-checkbox label.tag { /* Style the label like a tag */
    padding: 0.3em 0.75em;
    border-radius: 0.25rem;
    background-color: #e9ecef;
    color: #495057;
    cursor: pointer;
    transition: background-color 0.2s ease-in-out, color 0.2s ease-in-out;
    border: 1px solid #ced4da;
  }
  
  .tag-checkbox input[type="checkbox"]:checked + label.tag {
    background-color: #007bff;
    color: white;
    border-color: #007bff;
  }
  
  .tag-checkbox label.tag:hover {
    background-color: #dee2e6;
  }
  .tag-checkbox input[type="checkbox"]:checked + label.tag:hover {
    background-color: #0056b3;
  }
  
  
  .btn-primary {
    background-color: #0d6efd;
    border-color: #0d6efd;
  }
  .btn-primary:hover {
    background-color: #0b5ed7;
    border-color: #0a58ca;
  }
  .btn-secondary {
      background-color: #6c757d;
      border-color: #6c757d;
      color: white;
  }
  
  .loading-indicator {
    text-align: center;
    padding: 20px;
    font-size: 1.2em;
  }
  
  .note-item {
    transition: box-shadow 0.3s ease-in-out;
  }
  .note-item:hover {
    box-shadow: 0 .5rem 1rem rgba(0,0,0,.15);
  }
  
  .card-title a {
    text-decoration: none;
    color: inherit;
  }
  .card-title a:hover {
    color: #0056b3;
  }
  
  .note-tags .tag {
    display: inline-block;
    background-color: #f0f0f0;
    color: #555;
    padding: 0.25em 0.6em;
    border-radius: 0.2rem;
    margin-right: 5px;
    margin-bottom: 5px;
    font-size: 0.85em;
  }
  
  .created-date, .updated-date {
    font-size: 0.8rem;
    margin-bottom: 0.25rem;
  }
  
  .card-footer.note-actions {
    background-color: transparent; /* Remove default footer background */
    border-top: none; /* Remove default footer border */
    padding-top: 0;
    display: flex;
    justify-content: flex-end;
  }
  
  /* FontAwesome Icons - stelle sicher, dass du FontAwesome in deinem Projekt hast */
  /* Wenn nicht, kannst du Text-Labels oder andere Icons verwenden */
  /* @import url('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css'); */
  /* Alternativ, wenn du es global importiert hast, ist dieser Import nicht nötig. */
  
  /* Bootstrap Klassen wie spinner-border, alert, card, row, col, g-4 werden hier genutzt.
     Stelle sicher, dass Bootstrap CSS in deinem Projekt verfügbar ist,
     oder ersetze die Klassen durch eigenes CSS.
     Ich gehe davon aus, da dein Projekt `style.css` importiert und Vite PWA Plugins nutzt.
  */
  </style>