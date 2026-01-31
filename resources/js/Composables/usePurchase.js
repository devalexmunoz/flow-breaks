import { ref } from 'vue'
import { useFlow } from '@/Composables/useFlow'
import * as fcl from '@onflow/fcl'
import buyBreakSpotTransaction from '../../../flow/cadence/transactions/BuyBreakSpot.cdc?raw'

export function usePurchase() {
  const { user } = useFlow()

  const isLoading = ref(false)
  const error = ref(null)
  const transactionId = ref(null)

  const buySpot = async (breakId, hostAddress, price) => {
    if (!user.value.loggedIn) {
      error.value = 'Please connect your wallet first'
      return
    }

    isLoading.value = true
    error.value = null
    transactionId.value = null

    try {
      const txId = await fcl.mutate({
        cadence: buyBreakSpotTransaction,
        args: (arg, t) => [
          arg(breakId, t.UInt64),
          arg(hostAddress, t.Address),
          arg(Number(price).toFixed(2), t.UFix64),
        ],
        limit: 9999,
      })

      transactionId.value = txId
      console.log(`Purchase initiated: ${txId}`)

      await fcl.tx(txId).onceSealed()
    } catch (err) {
      console.error('Purchase failed', err)
      error.value = err.message || 'Transaction failed'
    } finally {
      isLoading.value = false
    }
  }

  return {
    buySpot,
    isLoading,
    error,
    transactionId,
  }
}
