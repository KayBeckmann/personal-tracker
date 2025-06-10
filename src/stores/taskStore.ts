// src/stores/taskStore.ts
import { defineStore } from 'pinia';
import { db, type Task } from '@/services/db';
import { liveQuery, type Subscription } from 'dexie';
import { ref, onMounted, onUnmounted, computed } from 'vue';

export const useTaskStore = defineStore('tasks', () => {
  const tasks = ref<Task[]>([]);
  const isLoading = ref(false);
  const error = ref<string | null>(null);
  const dataVersion = ref(0); // Reactivity trigger

  let liveTasksQuerySubscription: Subscription | null = null;

  const forceRecompute = () => {
    dataVersion.value++;
  };

  const fetchTasks = () => {
    isLoading.value = true;
    error.value = null;
    // Um memory leaks zu vermeiden, vorheriges Abo kündigen
    if (liveTasksQuerySubscription) {
      liveTasksQuerySubscription.unsubscribe();
    }
    const observable = liveQuery(() => db.tasks.orderBy('createdAt').reverse().toArray());
    liveTasksQuerySubscription = observable.subscribe({
      next: (result) => {
        tasks.value = result;
        forceRecompute(); // Trigger reactivity when liveQuery updates
        isLoading.value = false;
      },
      error: (err) => {
        console.error('Dexie liveQuery error:', err);
        error.value = 'Failed to load tasks from database.';
        isLoading.value = false;
      },
    });
  };

  const addTask = async (task: Omit<Task, 'id' | 'createdAt' | 'completed'>) => {
    try {
      await db.tasks.add({
        ...task,
        completed: false,
        createdAt: new Date(),
      });
      // fetchTasks(); // Nicht nötig bei liveQuery, wird automatisch aktualisiert
    } catch (e) {
      console.error('Failed to add task:', e);
      error.value = 'Failed to add task.';
    }
  };

  const updateTask = async (task: Task) => {
    if (task.id === undefined) {
      error.value = 'Task ID is undefined, cannot update.';
      return;
    }
    try {
      await db.tasks.update(task.id, task);
      // fetchTasks();
    } catch (e) {
      console.error('Failed to update task:', e);
      error.value = 'Failed to update task.';
    }
  };

  const deleteTask = async (id: number) => {
    try {
      await db.tasks.delete(id);
      // fetchTasks();
    } catch (e) {
      console.error('Failed to delete task:', e);
      error.value = 'Failed to delete task.';
    }
  };

  const toggleTaskCompletion = async (id: number) => {
    const task = tasks.value.find((t: Task) => t.id === id);
    if (task) {
      await updateTask({ ...task, completed: !task.completed });
    }
  };

  // Computed Properties für das Dashboard
  const highPriorityTasksCount = computed(() => {
    const _ = dataVersion.value; // Depend on the reactivity trigger
    return tasks.value.filter((task: Task) => task.priority === 'high' && !task.completed).length;
  });

  const nextDueTask = computed(() => {
    const _ = dataVersion.value; // Depend on the reactivity trigger
    const upcomingTasks = tasks.value
      .filter((task: Task) => !task.completed && task.dueDate)
      .sort((a: Task, b: Task) => new Date(a.dueDate!).getTime() - new Date(b.dueDate!).getTime());
    return upcomingTasks.length > 0 ? upcomingTasks[0] : null;
  });

  onMounted(() => {
    fetchTasks();
  });

  onUnmounted(() => {
    if (liveTasksQuerySubscription) {
      liveTasksQuerySubscription.unsubscribe();
    }
  });

  return {
    tasks,
    isLoading,
    error,
    addTask,
    updateTask,
    deleteTask,
    toggleTaskCompletion,
    highPriorityTasksCount,
    nextDueTask,
    fetchTasks // expose fetchTasks falls manuelles Refreshen gebraucht wird
  };
});