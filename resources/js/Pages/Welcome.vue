<script setup>
  import { Head, Link } from '@inertiajs/vue3'
  import WalletConnect from '@/Components/WalletConnect.vue'
  import BreakCard from '@/Components/BreakCard.vue'

  defineProps({
    breaks: {
      type: Array,
      default: () => [],
    },
  })
</script>

<template>
  <Head title="Welcome" />

  <div class="min-h-screen font-sans text-gray-800 bg-gray-50 flex flex-col">
    <nav
      class="flex items-center justify-between px-6 py-4 bg-white border-b border-gray-200 shadow-sm sticky top-0 z-50"
    >
      <div class="flex items-center gap-2">
        <img src="../../img/logo.png" alt="FlowBreaks" class="h-14 w-auto" />
      </div>
      <div class="flex items-center gap-4">
        <Link
          href="/dashboard"
          class="text-sm font-medium text-gray-500 hover:text-gray-900 hidden sm:block"
        >
          Dashboard
        </Link>
        <Link
          href="/collection"
          class="text-sm font-medium text-gray-500 hover:text-gray-900 hidden sm:block"
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

    <main class="flex-grow flex flex-col items-center">
      <!-- Hero Section -->
      <section class="w-full max-w-7xl mx-auto px-6 py-16 md:py-24 text-center">
        <h1
          class="text-5xl md:text-6xl font-extrabold text-gray-900 mb-6 tracking-tight leading-tight"
        >
          On-Chain
          <span
            class="bg-clip-text text-transparent bg-gradient-to-r from-blue-600 to-brand-green"
            >Breaks</span
          >
          for TS
        </h1>
        <p
          class="text-xl text-gray-600 max-w-2xl mx-auto mb-10 leading-relaxed"
        >
          Buy a spot, get a randomized team, and receive every Moment pulled for
          that team. All automated and verified on-chain.
        </p>
      </section>

      <!-- Active Breaks Gallery -->
      <section class="w-full max-w-7xl mx-auto px-6 pb-20">
        <div class="flex items-center justify-between mb-8">
          <h2 class="text-2xl font-bold text-gray-900 flex items-center gap-2">
            <span class="w-2 h-8 bg-blue-600 rounded-sm"></span>
            Active Breaks
          </h2>
          <div class="text-sm text-gray-500 font-medium">
            {{ breaks.length }} Breaks Live
          </div>
        </div>

        <div
          v-if="breaks.length > 0"
          class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"
        >
          <BreakCard
            v-for="breakPool in breaks"
            :key="breakPool.id"
            :break-pool="breakPool"
          />
        </div>

        <div
          v-else
          class="text-center py-20 bg-white rounded-3xl border border-gray-100 shadow-sm"
        >
          <div class="text-6xl mb-4">🏀</div>
          <h3 class="text-xl font-bold text-gray-900 mb-2">No Active Breaks</h3>
          <p class="text-gray-500">Check back soon for new drops!</p>
        </div>
      </section>
    </main>

    <footer
      class="bg-white border-t border-gray-200 py-8 text-center text-gray-500 text-sm"
    >
      &copy; {{ new Date().getFullYear() }} FlowBreaks. All rights reserved.
    </footer>
  </div>
</template>
