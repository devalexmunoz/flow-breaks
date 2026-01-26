import FlowToken from "FlowToken"
import FungibleToken from "FungibleToken"
import Breaks from "Breaks"

transaction(breakId: UInt64, hostAddress: Address, amount: UFix64) {

    let paymentVault: @FlowToken.Vault
    let buyerAddress: Address

   prepare(signer: auth(BorrowValue) &Account) {
        self.buyerAddress = signer.address

        let vaultRef = signer.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(
            from: /storage/flowTokenVault
        ) ?? panic("Could not borrow FlowTokenVault.")

        self.paymentVault <- vaultRef.withdraw(amount: amount) as! @FlowToken.Vault
    }

    execute {
        let hostCollection = getAccount(hostAddress)
            .capabilities.borrow<&{Breaks.BreakCollectionPublic}>(Breaks.BreakCollectionPublicPath)
            ?? panic("Could not borrow BreakCollectionPublic.")

        let breakPool = hostCollection.borrowBreak(breakId: breakId)

        breakPool.buySpot(payment: <-self.paymentVault, buyer: self.buyerAddress)

        log("Spot Purchased!")
    }
}