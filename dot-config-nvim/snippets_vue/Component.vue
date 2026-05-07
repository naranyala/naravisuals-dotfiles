<script setup lang="ts">
import { ref } from 'vue'

defineProps<{
  title?: string
}>()

const emit = defineEmits<{
  close: []
}>()
</script>

<template>
  <div class="rounded-lg border bg-card text-card-foreground shadow-sm">
    <div class="flex flex-col space-y-1.5 p-6">
      <h3 class="text-2xl font-semibold leading-none tracking-tight">
        {{ title || 'Component' }}
      </h3>
    </div>
    <div class="p-6 pt-0">
      <slot />
    </div>
  </div>
</template>
