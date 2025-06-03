// src/views/TasksView.vue
<template>
  <div class="tasks-view">
    <h1>Task Management</h1>
    <CreateTaskForm />
    <TaskList />
  </div>
</template>

<script setup lang="ts">
import TaskList from '@/components/tasks/TaskList.vue';
import CreateTaskForm from '@/components/tasks/CreateTaskForm.vue';
// import { useTaskStore } from '@/stores/taskStore';
// import { onMounted } from 'vue';

// const taskStore = useTaskStore();
// onMounted(() => {
//   if (!taskStore.isLoading && taskStore.tasks.length === 0) {
//     taskStore.fetchTasks();
//   }
// });
</script>

<style scoped>
.tasks-view {
  padding: 20px;
}
.tasks-view h1 {
    margin-bottom: 20px;
    color: #333;
}
</style>