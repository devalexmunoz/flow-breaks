<script setup>
  import { ref } from 'vue'
  import { Head, useForm, Link } from '@inertiajs/vue3' // Added Link
  import * as fcl from '@onflow/fcl'
  import CreateBreakTx from '../../../flow/cadence/transactions/CreateBreak.cdc?raw'
  import WalletConnect from '@/Components/WalletConnect.vue'

  const form = useForm({
    name: '',
    total_spots: 10,
    price: 10.0,
    on_chain_id: null,
    host_address: null,
  })

  const isProcessing = ref(false)
  const error = ref(null)
  // const transactionId = ref(null) // Hidden as per request

  const createBreak = async () => {
    isProcessing.value = true
    error.value = null
    // transactionId.value = null

    try {
      console.log('Starting Create Break Transaction...')
      console.log('Args:', form.name, form.price, form.total_spots)

      // 1. Trigger Flow Transaction
      const txId = await fcl.mutate({
        cadence: CreateBreakTx,
        args: (arg, t) => [
          arg(form.name, t.String),
          arg(form.price.toFixed(8), t.UFix64),
          arg(parseInt(form.total_spots), t.UInt64),
        ],
        limit: 9999,
      })

      // transactionId.value = txId
      console.log('Transaction ID:', txId)

      // Wait for seal
      const unsub = fcl.tx(txId).subscribe(async (res) => {
        if (res.status === 4) {
          // Sealed
          unsub()
          if (res.statusCode === 0) {
            // Transaction successful
            const event = res.events.find((e) =>
              e.type.includes('BreakCreated')
            )
            if (event) {
              const breakId = event.data.breakId
              const host = event.data.host

              form.on_chain_id = breakId
              form.host_address = host

              // 2. Save to Backend
              submitToBackend()
            }
          } else {
            error.value = 'Transaction failed on-chain: ' + res.errorMessage
            isProcessing.value = false
          }
        }
      })
    } catch (e) {
      console.error(e)
      error.value = 'Failed to initiate transaction: ' + e.message
      isProcessing.value = false
    }
  }

  const submitToBackend = () => {
    form.post('/breaks', {
      onSuccess: () => {
        isProcessing.value = false
        // Redirect handled by controller (Redirect::route('home'))
        // or Inertia automatically handles the response redirect
      },
      onError: (e) => {
        error.value = 'Saved on-chain but failed to save to database.'
        console.error(e)
        isProcessing.value = false
      },
    })
  }
</script>

<template>
  <Head title="Create New Break" />

  <div class="min-h-screen font-sans text-gray-800 bg-gray-50 flex flex-col">
    <!-- Navbar -->
    <nav
      class="flex items-center justify-between px-6 py-4 bg-white border-b border-gray-200 shadow-sm sticky top-0 z-50"
    >
      <Link
        href="/"
        class="text-2xl font-black tracking-tighter text-blue-600 flex items-center gap-2"
      >
        <span>FLOW<span class="text-gray-900">BREAKS</span></span>
      </Link>
      <WalletConnect />
    </nav>

    <main class="flex-grow flex flex-col items-center justify-center p-6">
      <div
        class="w-full max-w-lg bg-white rounded-xl shadow-lg border border-gray-100 p-8"
      >
        <h2
          class="text-2xl font-bold mb-6 font-display text-slate-800 text-center"
        >
          Create New Break
        </h2>

        <form @submit.prevent="createBreak" class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1"
              >Break Name</label
            >
            <input
              v-model="form.name"
              type="text"
              required
              class="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 py-3 px-4 bg-gray-50"
              placeholder="e.g. 2024 NBA TopShot Series 1"
            />
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1"
                >Total Spots</label
              >
              <input
                v-model="form.total_spots"
                type="number"
                required
                min="1"
                class="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 py-3 px-4 bg-gray-50"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1"
                >Price (FLOW)</label
              >
              <input
                v-model="form.price"
                type="number"
                required
                min="0"
                step="0.01"
                class="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 py-3 px-4 bg-gray-50"
              />
            </div>
          </div>

          <!-- Error Message -->
          <div
            v-if="error"
            class="text-red-600 text-sm p-3 bg-red-50 rounded-lg border border-red-100"
          >
            {{ error }}
          </div>

          <!-- Action Button -->
          <button
            type="submit"
            :disabled="isProcessing"
            class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3.5 px-4 rounded-xl transition-all shadow-md hover:shadow-lg disabled:opacity-70 disabled:cursor-not-allowed flex justify-center items-center gap-2"
          >
            <span
              v-if="isProcessing"
              class="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"
            ></span>
            <span v-if="isProcessing">Creating Break...</span>
            <span v-else>🚀 Launch Break</span>
          </button>
        </form>
      </div>
    </main>
  </div>
</template>
