<script setup>
  import { computed } from 'vue'

  const props = defineProps({
    breakPool: {
      type: Object,
      required: true,
    },
  })

  const percentage = computed(() => {
    if (!props.breakPool.total_spots) return 0
    return Math.min(
      100,
      Math.round(
        (props.breakPool.spots_count / props.breakPool.total_spots) * 100
      )
    )
  })

  const isFilled = computed(() => {
    return props.breakPool.spots_count >= props.breakPool.total_spots
  })

  const cardClasses = computed(() => {
    return isFilled.value ? 'opacity-75 grayscale' : ''
  })
</script>

<template>
  <div
    class="relative group bg-white border border-gray-100 rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 overflow-hidden flex flex-col"
    :class="cardClasses"
  >
    <!-- Card Header / Image Placeholder -->
    <div class="h-48 bg-gray-100 relative overflow-hidden">
      <!-- Gradient Overlay -->
      <div
        class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent z-10"
      ></div>

      <!-- Placeholder Image simulating sports card -->
      <img
        :src="`https://ui-avatars.com/api/?name=${encodeURIComponent(breakPool.title)}&background=0D8ABC&color=fff&size=512&font-size=0.33`"
        alt="Break Image"
        class="w-full h-full object-cover transform group-hover:scale-105 transition-transform duration-500"
      />

      <!-- Price Tag -->
      <div class="absolute top-3 right-3 z-20">
        <div
          class="bg-white/90 backdrop-blur-sm shadow-sm px-3 py-1 rounded-full font-bold text-gray-900 border border-white/50"
        >
          ${{ Number(breakPool.price).toFixed(2) }}
        </div>
      </div>

      <!-- Status Badge -->
      <div class="absolute top-3 left-3 z-20">
        <span
          v-if="isFilled"
          class="px-2 py-0.5 rounded text-xs font-bold uppercase tracking-wider bg-gray-800 text-white"
        >
          Filled
        </span>
        <span
          v-else
          class="px-2 py-0.5 rounded text-xs font-bold uppercase tracking-wider bg-green-500 text-white shadow-lg shadow-green-500/30"
        >
          Live
        </span>
      </div>
    </div>

    <!-- Content -->
    <div class="p-5 flex-grow flex flex-col justify-between">
      <div>
        <h3
          class="font-bold text-lg text-gray-900 leading-tight mb-2 group-hover:text-blue-600 transition-colors"
        >
          {{ breakPool.title }}
        </h3>
        <p class="text-sm text-gray-500 mb-4">
          Hosted by
          <span class="font-mono text-xs bg-gray-100 px-1 rounded"
            >{{ breakPool.host_address.substring(0, 6) }}...{{
              breakPool.host_address.substring(
                breakPool.host_address.length - 4
              )
            }}</span
          >
        </p>
      </div>

      <!-- Progress Bar -->
      <div class="mt-4">
        <div class="flex justify-between items-end mb-1">
          <span class="text-xs font-semibold text-gray-700">Spots Taken</span>
          <span class="text-xs font-bold text-blue-600">
            {{ breakPool.spots_count }} / {{ breakPool.total_spots }}
          </span>
        </div>
        <div class="w-full bg-gray-100 rounded-full h-2.5 overflow-hidden">
          <div
            class="bg-blue-600 h-2.5 rounded-full transition-all duration-500 ease-out relative"
            :style="{ width: `${percentage}%` }"
          >
            <!-- Shimmer effect -->
            <div
              class="absolute top-0 left-0 bottom-0 right-0 bg-gradient-to-r from-transparent via-white/30 to-transparent w-full -translate-x-full animate-[shimmer_2s_infinite]"
            ></div>
          </div>
        </div>
      </div>

      <!-- Action Button -->
      <div class="mt-5">
        <button
          class="w-full py-2.5 rounded-xl font-bold text-sm transition-all duration-200"
          :class="
            isFilled
              ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
              : 'bg-gray-900 text-white hover:bg-blue-600 hover:shadow-lg hover:shadow-blue-600/30 active:scale-95'
          "
          :disabled="isFilled"
        >
          {{ isFilled ? 'Sold Out' : 'Join Break' }}
        </button>
      </div>
    </div>
  </div>
</template>
