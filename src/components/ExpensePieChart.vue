<template>
  <Pie :data="chartData" :options="chartOptions" />
</template>

<script lang="ts" setup>
import { Pie } from 'vue-chartjs';
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  CategoryScale,
  type ChartData,
  type ChartOptions
} from 'chart.js';
import { computed, type PropType } from 'vue';

ChartJS.register(Title, Tooltip, Legend, ArcElement, CategoryScale);

const props = defineProps({
  data: {
    type: Object as PropType<ChartData<'pie'>>,
    required: true
  }
});

const chartData = computed(() => props.data);

const chartOptions: ChartOptions<'pie'> = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'top',
    },
    title: {
      display: true,
      text: 'Expenses by Category'
    }
  }
};
</script>