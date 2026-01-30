<script setup>
  import { useFlow } from '@/Composables/useFlow'

  const { user, login, logout } = useFlow()
</script>

<template>
  <div>
    <div v-if="user.loggedIn" class="flex items-center gap-3">
      <div
        class="px-4 py-2 font-mono text-sm text-blue-800 bg-blue-100 rounded-lg border border-blue-200"
      >
        <span class="mr-2">🟢</span>
        {{ user.addr }}
      </div>

      <button
        @click="logout"
        class="px-4 py-2 text-sm font-bold text-red-600 transition bg-white border border-red-200 rounded-lg hover:bg-red-50"
      >
        Disconnect
      </button>
    </div>

    <button
      v-else
      @click="login"
      class="px-6 py-2 font-bold text-white transition bg-gray-900 rounded-lg hover:bg-gray-700 shadow-md"
    >
      Connect Wallet
    </button>
  </div>
</template>
