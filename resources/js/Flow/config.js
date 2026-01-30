import { config } from '@onflow/fcl'

config({
  'flow.network': import.meta.env.VITE_FLOW_NETWORK,
  'accessNode.api': import.meta.env.VITE_FLOW_ACCESS_NODE_URL,
  'discovery.wallet': import.meta.env.VITE_FLOW_DISCOVERY_WALLET,

  '0xBreaks': import.meta.env.VITE_ADMIN_ADDRESS,

  'app.detail.title': 'Breaks App',
})
