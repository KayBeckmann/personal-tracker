import type { Habit } from '../services/db';

export interface HabitForDisplay extends Habit {
  completedToday: boolean;
  isDue: boolean;
}