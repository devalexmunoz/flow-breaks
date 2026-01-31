<script setup>
  import { ref, watch } from 'vue'
  import * as fcl from '@onflow/fcl'
  import GetMomentsScript from '../../../flow/cadence/scripts/topshot/get_moments_metadata.cdc?raw'
  import DistributeMomentsTx from '../../../flow/cadence/transactions/admin/distribute_moments.cdc?raw'
  import { useForm } from '@inertiajs/vue3'

  const props = defineProps({
    show: Boolean,
    breakPool: Object,
  })

  const emit = defineEmits(['close', 'completed'])

  const isLoading = ref(false)
  const isDistributing = ref(false)
  const moments = ref([])
  const selectedMomentIds = ref([])
  const error = ref(null)

  const fetchMoments = async () => {
    if (!props.breakPool?.host_address) return

    isLoading.value = true
    moments.value = []
    error.value = null

    try {
      const user = await fcl.currentUser.snapshot()
      if (!user.addr) throw new Error('Wallet not connected')

      const res = await fcl.query({
        cadence: GetMomentsScript,
        args: (arg, t) => [arg(user.addr, t.Address)],
      })

      moments.value = res
    } catch (e) {
      console.error(e)
      error.value = 'Failed to fetch moments: ' + e.message
    } finally {
      isLoading.value = false
    }
  }

  watch(
    () => props.show,
    (newVal) => {
      if (newVal) {
        selectedMomentIds.value = []
        fetchMoments()
      }
    }
  )

  const toggleSelection = (id) => {
    const index = selectedMomentIds.value.indexOf(id)
    if (index === -1) {
      selectedMomentIds.value.push(id)
    } else {
      selectedMomentIds.value.splice(index, 1)
    }
  }

  const form = useForm({
    status: 3, // COMPLETED
  })

  const distribute = async () => {
    if (selectedMomentIds.value.length === 0) return
    if (
      !confirm(
        `Distribute ${selectedMomentIds.value.length} moments to break winners?`
      )
    )
      return

    isDistributing.value = true

    try {
      const txId = await fcl.mutate({
        cadence: DistributeMomentsTx,
        args: (arg, t) => [
          arg(props.breakPool.on_chain_id, t.UInt64),
          arg(selectedMomentIds.value.map(String), t.Array(t.UInt64)), // Note: Ensure IDs are propertly formatted
        ],
        limit: 9999,
      })

      console.log('Distribute Tx:', txId)

      fcl.tx(txId).subscribe((res) => {
        if (res.status === 4) {
          if (res.statusCode === 0) {
            // Success - Update Backend
            form.patch(`/breaks/${props.breakPool.id}`, {
              onSuccess: () => {
                isDistributing.value = false
                emit('completed')
                emit('close')
              },
            })
          } else {
            alert('Transaction Failed: ' + res.errorMessage)
            isDistributing.value = false
          }
        }
      })
    } catch (e) {
      console.error(e)
      alert('Error: ' + e.message)
      isDistributing.value = false
    }
  }
</script>

<template>
  <div
    v-if="show"
    class="fixed inset-0 z-50 flex items-center justify-center p-4"
  >
    <!-- Backdrop -->
    <div
      class="fixed inset-0 bg-black/50 backdrop-blur-sm transition-opacity"
      @click="$emit('close')"
    ></div>

    <!-- Modal -->
    <div
      class="bg-white rounded-2xl shadow-xl w-full max-w-2xl max-h-[90vh] flex flex-col z-10 overflow-hidden transform transition-all"
    >
      <!-- Header -->
      <div
        class="p-6 border-b border-gray-100 flex justify-between items-center bg-gray-50"
      >
        <div>
          <h3 class="text-lg font-bold text-gray-900">
            Select Moments to Distribute
          </h3>
          <p class="text-sm text-gray-500">Break: {{ breakPool?.name }}</p>
        </div>
        <button
          @click="$emit('close')"
          class="text-gray-400 hover:text-gray-600 transition-colors"
        >
          <svg
            class="w-6 h-6"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
        </button>
      </div>

      <!-- Body -->
      <div class="flex-grow overflow-y-auto p-6 bg-gray-50/50">
        <div
          v-if="isLoading"
          class="flex flex-col items-center justify-center py-12"
        >
          <div
            class="w-10 h-10 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin mb-4"
          ></div>
          <p class="text-gray-500 font-medium">Fetching your moments...</p>
        </div>

        <div
          v-else-if="error"
          class="p-4 bg-red-50 text-red-600 rounded-xl text-center"
        >
          {{ error }} <br />
          <button
            @click="fetchMoments"
            class="mt-2 text-sm underline hover:text-red-800"
          >
            Try Again
          </button>
        </div>

        <div
          v-else-if="moments.length === 0"
          class="text-center py-12 text-gray-500"
        >
          No moments found in your collection.
        </div>

        <div v-else class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div
            v-for="moment in moments"
            :key="moment.id"
            @click="toggleSelection(moment.id)"
            class="relative border rounded-xl p-4 cursor-pointer transition-all duration-200 group"
            :class="
              selectedMomentIds.includes(moment.id)
                ? 'bg-blue-50 border-blue-500 ring-1 ring-blue-500'
                : 'bg-white border-gray-200 hover:border-blue-300 hover:shadow-md'
            "
          >
            <!-- Checkbox -->
            <div class="absolute top-4 right-4">
              <div
                class="w-5 h-5 rounded border flex items-center justify-center transition-colors"
                :class="
                  selectedMomentIds.includes(moment.id)
                    ? 'bg-blue-600 border-blue-600'
                    : 'border-gray-300 bg-white'
                "
              >
                <svg
                  v-if="selectedMomentIds.includes(moment.id)"
                  class="w-3.5 h-3.5 text-white"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="3"
                    d="M5 13l4 4L19 7"
                  />
                </svg>
              </div>
            </div>

            <!-- Content -->
            <div class="pr-8">
              <div
                class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-1"
              >
                {{ moment.team }}
              </div>
              <h4 class="font-bold text-gray-900 text-lg leading-tight mb-1">
                {{ moment.player }}
              </h4>
              <div class="text-sm text-gray-600 font-medium">
                {{ moment.set }}
              </div>

              <div
                class="mt-3 flex items-center gap-2 text-xs font-mono text-gray-400"
              >
                <span class="bg-gray-100 px-1.5 py-0.5 rounded"
                  >#{{ moment.serialNumber }}</span
                >
                <span>ID: {{ moment.id }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div
        class="p-6 border-t border-gray-100 bg-white flex justify-between items-center"
      >
        <div class="text-sm font-medium text-gray-600">
          <span class="text-gray-900 font-bold">{{
            selectedMomentIds.length
          }}</span>
          moments selected
        </div>
        <button
          @click="distribute"
          :disabled="selectedMomentIds.length === 0 || isDistributing"
          class="px-6 py-2.5 bg-blue-600 text-white font-bold rounded-xl hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-md active:scale-95 flex items-center gap-2"
        >
          <span
            v-if="isDistributing"
            class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"
          ></span>
          {{ isDistributing ? 'Distributing...' : 'Distribute Selected' }}
        </button>
      </div>
    </div>
  </div>
</template>
