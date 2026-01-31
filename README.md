# 🏀 Flow Breaks

**The future of NBA TopShot pack breaking—automated, transparent, and 100% on-chain.**

---

## 💡 The Concept (For Collectors)

NBA TopShot pack breaks are a staple of the community, but they have always relied on manual coordination and off-chain tools. **Flow Breaks** brings the entire experience onto the Flow blockchain.

### How to Play

1.  **Join a Break**
    Collectors purchase spots in an open break directly through the app using FLOW.
2.  **On-Chain Randomization**
    Once the break is full, the Host triggers the randomization. A Cadence script assigns NBA teams to participants with verifiable fairness—no external tools required.

3.  **Instant Distribution**
    The Host selects the moments pulled from the pack, and with one click, the smart contract handles the multi-recipient distribution instantly.

---

## 🏆 The Hackathon (For Judges)

This project focuses on solving the "Trust & Efficiency" gap in the digital hobby. We moved the manual "middleman" work into smart contract logic.

### The Technical Achievement: Integrated On-Chain Lifecycle

The core innovation of Flow Breaks is the integration of the **Randomization** and **Distribution** phases into a single, verifiable flow.

**Key Technical Features:**

- **Automated Multi-NFT Distribution:** We developed a Cadence transaction that allows a Host to distribute multiple TopShot Moments to different winners in a single atomic action.
- **Verifiable On-Chain Randomization:** We replaced traditional "roulette" wheels with a Cadence-native randomization script. This ensures that the team-to-user mapping is transparent and tamper-proof.
- **Hybrid State Sync:** A seamless integration between a Vue.js/Laravel stack and the Flow blockchain. The backend tracks break metadata, while the "Source of Truth" for ownership and fairness remains 100% on-chain

---

## 🛠️ Tech Stack

- **Frontend:** Vue 3 (Composition API), Tailwind CSS
- **Backend:** Laravel (PHP 8.x), Inertia.js
- **Blockchain:** Cadence, Flow Client Library (FCL)
- **Smart Contracts:** TopShot (Standard), Custom Breaks Contract

---

## ⚙️ Development Approach & Simulation

To demonstrate the power of Flow Breaks within the NBA TopShot ecosystem, we simulated the live environment on the Flow Emulator:

1.  **Contract Mocking:** We utilized the official TopShot contract structures to ensure our distribution scripts are mainnet-ready.
2.  **Multi-Account Testing:** We leveraged the Flow Dev Wallet to simulate a Host (Service Account) and multiple Buyers (Alice, Bob) to prove the end-to-end transfer of assets.
3.  **Metadata Injection:** We simulated TopShot "Moments" with realistic metadata (Player, Team, Tier) to demonstrate how a collector's "My Collection" page updates in real-time after a break is completed.

---

## 📄 Smart Contracts

Our logic interacts with the core TopShot infrastructure while utilizing custom scripts for the breaking logic.

### Key Logic Files

- `CreateBreak.cdc`: Initializes a new break and sets up the on-chain vault for spot payments.
- `RandomizeBreak.cdc`: Executes the team-to-address assignment logic.
- `distribute_m=oments.cdc`: The "heavy lifter" that moves multiple NFTs to multiple recipients based on the randomization results.

---

**Ready to break?** 🚀
Check out the **Host Dashboard** to create your first break or get a spot on an existing break.
