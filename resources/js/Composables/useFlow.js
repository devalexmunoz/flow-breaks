import { ref, onMounted } from 'vue'
import * as fcl from '@onflow/fcl'
import '../Flow/config'

const user = ref({ loggedIn: false, addr: null })

export function useFlow() {
  onMounted(() => {
    fcl.currentUser.subscribe((currentUser) => {
      user.value = currentUser
    })
  })

  const login = () => fcl.authenticate()
  const logout = () => fcl.unauthenticate()

  const executeTransaction = async (cadenceCode, args = []) => {
    try {
      const transactionId = await fcl.mutate({
        cadence: cadenceCode,
        args: (arg, t) => args.map((a) => arg(a.value, t[a.type])),
        payer: fcl.authz,
        proposer: fcl.authz,
        authorizations: [fcl.authz],
        limit: 9999,
      })

      console.log(`Transaction Sent: ${transactionId}`)

      return await fcl.tx(transactionId).onceSealed()
    } catch (error) {
      console.error('Transaction Failed:', error)
      throw error
    }
  }

  return {
    user,
    login,
    logout,
    executeTransaction,
  }
}
