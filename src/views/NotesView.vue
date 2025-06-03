// src/views/NotesView.vue
<template>
  <div class="notes-view">
    <h1>Notizen</h1>
    <p>Platzhalter für die Notizliste und -verwaltung.</p>
    </div>
</template>

<script setup lang="ts">
// import CreateNoteForm from '@/components/notes/CreateNoteForm.vue';
// import NoteList from '@/components/notes/NoteList.vue';
// import { useNoteStore } from '@/stores/noteStore';
// import { onMounted } from 'vue';

// const noteStore = useNoteStore();
// onMounted(() => {
//   if (!noteStore.isLoading && noteStore.notes.length === 0) {
//     noteStore.fetchNotes();
//   }
// });
</script>

<style scoped>
.notes-view {
  padding: 20px;
}
.notes-view h1 {
    margin-bottom: 20px;
    color: #333;
}
</style>