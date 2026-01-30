<script setup>
  import { Head } from '@inertiajs/vue3'
  import WalletConnect from '@/Components/WalletConnect.vue'
</script>

<template>
  <Head title="Welcome" />

  <div class="min-h-screen font-sans text-gray-800 bg-gray-50 flex flex-col">
    <nav
      class="flex items-center justify-between px-6 py-4 bg-white border-b border-gray-200 shadow-sm"
    >
      <h1 class="text-2xl font-black tracking-tighter text-blue-600">
        FLOW<span class="text-gray-900">BREAKS</span>
      </h1>
      <WalletConnect />
    </nav>

    <main
      class="flex-grow flex flex-col items-center justify-center p-6 text-center"
    >
      <h1 class="text-5xl font-extrabold text-gray-900 mb-6">
        On-Chain <span class="text-blue-600">Breaks</span> for TS
      </h1>
      <p class="text-xl text-gray-600 max-w-2xl mb-8">
        Buy a spot, get a randomized team, and receive every Moment pulled for
        that team. All automated and verified on-chain.
      </p>

      <div
        class="p-4 bg-blue-50 text-blue-700 rounded-lg border border-blue-100"
      >
        Connect your wallet to get started
      </div>
    </main>
  </div>
</template>
