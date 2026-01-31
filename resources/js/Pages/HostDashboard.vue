<script setup>
  import { Head, useForm, Link } from '@inertiajs/vue3'
  import * as fcl from '@onflow/fcl'
  import RandomizeBreakTx from '../../../flow/cadence/transactions/RandomizeBreak.cdc?raw'
  import WalletConnect from '@/Components/WalletConnect.vue'
  import { ref } from 'vue'
  import DistributeModal from '@/Components/DistributeModal.vue'

  defineProps({
    breaks: {
      type: Array,
      default: () => [],
    },
  })

  const showDistributeModal = ref(false)
  const selectedBreak = ref(null)

  // NBA Teams List (Alphabetical)
  const NBA_TEAMS = [
    'Atlanta Hawks',
    'Boston Celtics',
    'Brooklyn Nets',
    'Charlotte Hornets',
    'Chicago Bulls',
    'Cleveland Cavaliers',
    'Dallas Mavericks',
    'Denver Nuggets',
    'Detroit Pistons',
    'Golden State Warriors',
    'Houston Rockets',
    'Indiana Pacers',
    'LA Clippers',
    'Los Angeles Lakers',
    'Memphis Grizzlies',
    'Miami Heat',
    'Milwaukee Bucks',
    'Minnesota Timberwolves',
    'New Orleans Pelicans',
    'New York Knicks',
    'Oklahoma City Thunder',
    'Orlando Magic',
    'Philadelphia 76ers',
    'Phoenix Suns',
    'Portland Trail Blazers',
    'Sacramento Kings',
    'San Antonio Spurs',
    'Toronto Raptors',
    'Utah Jazz',
    'Washington Wizards',
  ]

  const form = useForm({
    status: null,
  })

  const isProcessing = ref(false)
  const processingId = ref(null)

  const statusLabel = (status) => {
    const map = {
      0: 'OPEN',
      1: 'FILLED',
      2: 'RANDOMIZED',
      3: 'COMPLETED',
    }
    return map[status] || 'UNKNOWN'
  }

  const statusClass = (status) => {
    const map = {
      0: 'bg-green-100 text-green-800',
      1: 'bg-yellow-100 text-yellow-800',
      2: 'bg-purple-100 text-purple-800',
      3: 'bg-gray-100 text-gray-800',
    }
    return map[status] || 'bg-gray-100 text-gray-800'
  }

  const handleRandomize = async (breakPool) => {
    if (
      !confirm(
        `Are you sure you want to randomize teams for "${breakPool.name}"?`
      )
    )
      return

    isProcessing.value = true
    processingId.value = breakPool.id

    try {
      const txId = await fcl.mutate({
        cadence: RandomizeBreakTx,
        args: (arg, t) => [
          arg(breakPool.on_chain_id, t.UInt64),
          arg(NBA_TEAMS, t.Array(t.String)),
        ],
        limit: 9999,
      })

      console.log('Randomize Transaction ID:', txId)

      fcl.tx(txId).subscribe(async (res) => {
        if (res.status === 4) {
          if (res.statusCode === 0) {
            // Success! Update Backend
            form.status = 2 // RANDOMIZED
            form.patch(`/breaks/${breakPool.id}`, {
              onSuccess: () => {
                isProcessing.value = false
                processingId.value = null
              },
              onError: (e) => {
                console.error('Backend update failed:', e)
                alert('Transaction succeeded but backend update failed.')
                isProcessing.value = false
                processingId.value = null
              },
            })
          } else {
            alert(`Transaction failed: ${res.errorMessage}`)
            isProcessing.value = false
            processingId.value = null
          }
        }
      })
    } catch (e) {
      console.error(e)
      alert(`Failed to initiate transaction: ${e.message}`)
      isProcessing.value = false
      processingId.value = null
    }
  }

  const openDistributeModal = (breakPool) => {
    selectedBreak.value = breakPool
    showDistributeModal.value = true
  }
</script>

<template>
  <Head title="Host Dashboard" />

  <!-- Distribute Modal -->
  <DistributeModal
    :show="showDistributeModal"
    :break-pool="selectedBreak"
    @close="showDistributeModal = false"
    @completed="showDistributeModal = false"
  />

  <div class="min-h-screen font-sans text-gray-800 bg-gray-50 flex flex-col">
    <!-- Navbar -->
    <nav
      class="flex items-center justify-between px-6 py-4 bg-white border-b border-gray-200 shadow-sm sticky top-0 z-50"
    >
      <Link href="/" class="flex items-center gap-2">
        <img src="../../img/logo.png" alt="FlowBreaks" class="h-12 w-auto" />
        <span
          class="ml-2 px-2.5 py-0.5 text-[10px] font-bold tracking-wider bg-gray-900 text-white rounded-full uppercase shadow-sm border border-gray-700"
          >Host Zone</span
        >
      </Link>
      <div class="flex items-center gap-4">
        <Link
          href="/collection"
          class="text-sm font-medium text-gray-500 hover:text-gray-900 hidden sm:block"
        >
          My Collection
        </Link>
        <Link
          href="/create"
          class="text-sm font-bold text-gray-600 hover:text-blue-600"
        >
          Create Break
        </Link>
        <WalletConnect />
      </div>
    </nav>

    <main class="flex-grow p-6 w-full max-w-7xl mx-auto">
      <div class="mb-8 flex items-center justify-between">
        <h1 class="text-3xl font-bold text-gray-900">Dashboard</h1>
      </div>

      <div
        class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden"
      >
        <div class="overflow-x-auto">
          <table class="w-full text-left text-sm">
            <thead
              class="bg-gray-50 border-b border-gray-200 text-gray-500 uppercase tracking-wider font-semibold"
            >
              <tr>
                <th class="px-6 py-4">Status</th>
                <th class="px-6 py-4">Break Name</th>
                <th class="px-6 py-4">Price</th>
                <th class="px-6 py-4">Spots</th>
                <th class="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
              <tr
                v-for="breakPool in breaks"
                :key="breakPool.id"
                class="hover:bg-gray-50 transition-colors"
              >
                <!-- Status -->
                <td class="px-6 py-4 align-middle">
                  <span
                    class="px-2 py-1 rounded-full text-xs font-bold"
                    :class="statusClass(breakPool.status)"
                  >
                    {{ statusLabel(breakPool.status) }}
                  </span>
                </td>

                <!-- Name -->
                <td class="px-6 py-4 font-medium text-gray-900 align-middle">
                  {{ breakPool.name || breakPool.title }}
                  <div class="text-xs text-gray-400 font-mono mt-0.5">
                    ID: {{ breakPool.on_chain_id }}
                  </div>
                </td>

                <!-- Price -->
                <td class="px-6 py-4 text-gray-600 align-middle">
                  {{ parseFloat(breakPool.price).toFixed(2) }} FLOW
                </td>

                <!-- Spots -->
                <td class="px-6 py-4 align-middle">
                  <div class="flex items-center gap-2">
                    <div
                      class="w-24 bg-gray-200 rounded-full h-1.5 overflow-hidden"
                    >
                      <div
                        class="bg-blue-600 h-1.5 rounded-full"
                        :style="{
                          width: `${(breakPool.spots_count / breakPool.total_spots) * 100}%`,
                        }"
                      ></div>
                    </div>
                    <span class="text-xs font-medium"
                      >{{ breakPool.spots_count }} /
                      {{ breakPool.total_spots }}</span
                    >
                  </div>
                </td>

                <!-- Actions -->
                <td class="px-6 py-4 text-right align-middle">
                  <button
                    v-if="
                      breakPool.status === 0 &&
                      breakPool.spots_count >= breakPool.total_spots
                    "
                    @click="handleRandomize(breakPool)"
                    :disabled="isProcessing"
                    class="inline-flex items-center px-3 py-1.5 bg-purple-600 hover:bg-purple-700 text-white text-xs font-bold rounded-lg transition-colors shadow-sm disabled:opacity-50"
                  >
                    <span
                      v-if="isProcessing && processingId === breakPool.id"
                      class="mr-1 w-3 h-3 border-2 border-white/30 border-t-white rounded-full animate-spin"
                    ></span>
                    Randomize Teams 🎲
                  </button>
                  <span
                    v-else-if="breakPool.status === 1"
                    class="text-gray-400 text-xs italic"
                  >
                    Waiting for Fill...
                  </span>
                  <span
                    v-else-if="breakPool.status === 2"
                    class="text-purple-600 text-xs font-bold"
                  >
                    <button
                      @click="openDistributeModal(breakPool)"
                      class="inline-flex items-center px-3 py-1.5 bg-brand-green hover:bg-emerald-400 text-gray-900 text-xs font-bold rounded-lg transition-colors shadow-sm"
                    >
                      Distribute Moments 🎁
                    </button>
                  </span>
                  <span
                    v-else-if="breakPool.status === 3"
                    class="text-gray-500 text-xs font-bold flex items-center gap-1"
                  >
                    <span>Completed</span>
                    <svg
                      class="w-4 h-4 text-green-500"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M5 13l4 4L19 7"
                      />
                    </svg>
                  </span>
                </td>
              </tr>

              <tr v-if="breaks.length === 0">
                <td colspan="5" class="px-6 py-12 text-center text-gray-400">
                  No breaks found. Create one to get started!
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </main>
  </div>
</template>
