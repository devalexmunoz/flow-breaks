<script setup>
  import { Head, Link } from '@inertiajs/vue3'
  import * as fcl from '@onflow/fcl'
  import GetMomentsScript from '../../../flow/cadence/scripts/topshot/get_moments_metadata.cdc?raw'
  import WalletConnect from '@/Components/WalletConnect.vue'
  import { ref, onMounted } from 'vue'

  const moments = ref([])
  const isLoading = ref(true)
  const error = ref(null)
  const userAddr = ref(null)

  const fetchMoments = async () => {
    isLoading.value = true
    error.value = null
    moments.value = []

    try {
      const user = await fcl.currentUser.snapshot()
      if (!user.addr) {
        userAddr.value = null
        isLoading.value = false
        return
      }
      userAddr.value = user.addr

      const res = await fcl.query({
        cadence: GetMomentsScript,
        args: (arg, t) => [arg(user.addr, t.Address)],
      })

      moments.value = res
    } catch (e) {
      console.error(e)
      error.value = 'Failed to fetch collection: ' + e.message
    } finally {
      isLoading.value = false
    }
  }

  onMounted(() => {
    fcl.currentUser.subscribe((user) => {
      if (user.addr) {
        fetchMoments()
      } else {
        userAddr.value = null
        moments.value = []
        isLoading.value = false
      }
    })
  })
</script>

<template>
  <Head title="My Collection" />

  <div class="min-h-screen font-sans text-gray-800 bg-gray-50 flex flex-col">
    <!-- Navbar -->
    <nav
      class="flex items-center justify-between px-6 py-4 bg-white border-b border-gray-200 shadow-sm sticky top-0 z-50"
    >
      <Link href="/" class="flex items-center gap-2">
        <img src="../../img/logo.png" alt="FlowBreaks" class="h-12 w-auto" />
      </Link>
      <div class="flex items-center gap-4">
        <Link
          href="/dashboard"
          class="text-sm font-medium text-gray-500 hover:text-gray-900 hidden sm:block"
        >
          Dashboard
        </Link>
        <Link
          href="/collection"
          class="text-sm font-bold text-gray-900 border-b-2 border-brand-green"
        >
          My Collection
        </Link>
        <Link
          href="/create"
          class="hidden md:flex items-center gap-2 px-4 py-2 text-sm font-bold text-gray-700 hover:text-brand-green hover:bg-gray-50 rounded-lg transition-colors border border-transparent hover:border-brand-green/20"
        >
          <span>+ Create Break</span>
        </Link>
        <WalletConnect />
      </div>
    </nav>

    <main class="flex-grow p-6 w-full max-w-7xl mx-auto">
      <div class="mb-8 flex items-center justify-between">
        <h1 class="text-3xl font-bold text-gray-900">My Collection</h1>
        <div
          v-if="userAddr"
          class="text-sm font-mono text-gray-500 bg-white px-3 py-1 rounded-full border border-gray-200"
        >
          {{ userAddr }}
        </div>
      </div>

      <div
        v-if="!userAddr"
        class="flex flex-col items-center justify-center py-24 bg-white rounded-3xl border border-gray-100 shadow-sm text-center"
      >
        <div class="text-5xl mb-4">🔒</div>
        <h2 class="text-xl font-bold text-gray-900 mb-2">
          Wallet Not Connected
        </h2>
        <p class="text-gray-500 mb-6">
          Connect your wallet to view your moments.
        </p>
        <WalletConnect />
      </div>

      <div
        v-else-if="isLoading"
        class="flex flex-col items-center justify-center py-24"
      >
        <div
          class="w-12 h-12 border-4 border-blue-200 border-t-brand-green rounded-full animate-spin mb-4"
        ></div>
        <p class="text-gray-500 font-medium">Loading your moments...</p>
      </div>

      <div
        v-else-if="error"
        class="p-8 bg-red-50 text-red-600 rounded-2xl border border-red-100 text-center"
      >
        <p class="font-bold mb-2">Error Loading Collection</p>
        <p class="text-sm">{{ error }}</p>
        <button
          @click="fetchMoments"
          class="mt-4 text-sm font-bold underline hover:text-red-800"
        >
          Try Again
        </button>
      </div>

      <div
        v-else-if="moments.length === 0"
        class="flex flex-col items-center justify-center py-24 bg-white rounded-3xl border border-gray-100 shadow-sm text-center"
      >
        <div class="text-6xl mb-4">📦</div>
        <h2 class="text-xl font-bold text-gray-900 mb-2">Collection Empty</h2>
        <p class="text-gray-500">
          You haven't won any moments yet. Join a break!
        </p>
        <Link
          href="/"
          class="mt-6 px-6 py-2.5 bg-blue-600 text-white font-bold rounded-xl hover:bg-blue-700 shadow-lg shadow-blue-600/20 transition-all"
        >
          Browse Breaks
        </Link>
      </div>

      <div
        v-else
        class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"
      >
        <div
          v-for="moment in moments"
          :key="moment.id"
          class="bg-white border border-gray-200 hover:border-blue-300 hover:shadow-xl rounded-2xl p-5 transition-all duration-300 group relative overflow-hidden"
        >
          <!-- Decorative element removed for cleaner look -->

          <div class="relative z-10">
            <div class="flex justify-between items-start mb-4">
              <div
                class="text-xs font-bold text-blue-600 uppercase tracking-wider bg-blue-50 px-2 py-1 rounded"
              >
                {{ moment.team }}
              </div>
              <div class="text-[10px] font-mono text-gray-400">
                #{{ moment.serialNumber }}
              </div>
            </div>

            <h3
              class="font-black text-2xl text-gray-900 leading-none mb-2 group-hover:text-blue-600 transition-colors"
            >
              {{ moment.player }}
            </h3>
            <p class="text-sm text-gray-500 font-medium mb-4">
              {{ moment.set }}
            </p>

            <div
              class="pt-4 border-t border-gray-100 flex justify-between items-center"
            >
              <span class="text-[10px] text-gray-400 font-mono"
                >ID: {{ moment.id }}</span
              >
              <a
                :href="`https://testnet.flowscan.org/account/${userAddr}/collection/TopShot/${moment.id}`"
                target="_blank"
                class="text-xs font-bold text-brand-green hover:text-emerald-500 flex items-center gap-1"
              >
                View on FlowScan ↗
              </a>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>
