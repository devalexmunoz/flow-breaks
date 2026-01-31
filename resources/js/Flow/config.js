import { config } from '@onflow/fcl'

config({
  'flow.network': import.meta.env.VITE_FLOW_NETWORK,
  'accessNode.api': import.meta.env.VITE_FLOW_ACCESS_NODE_URL,
  'discovery.wallet': import.meta.env.VITE_FLOW_DISCOVERY_WALLET,

  '0xBreaks': import.meta.env.VITE_FLOW_ADMIN_ACCOUNT_ADDRESS,

  '0xFlowToken': '0x0ae53cb6e3f42a79',
  '0xFungibleToken': '0xee82856bf20e2aa6',

  'app.detail.title': 'Breaks App',
})
