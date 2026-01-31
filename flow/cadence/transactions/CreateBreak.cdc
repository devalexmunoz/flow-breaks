import Breaks from 0xBreaks
import FlowToken from 0xFlowToken

transaction(title: String, price: UFix64, totalSpots: UInt64) {
    
    let breakCollection: &Breaks.Collection

    prepare(signer: auth(BorrowValue, SaveValue, IssueStorageCapabilityController, PublishCapability) &Account) {
        
        // Ensure Break Collection exists
        if signer.storage.borrow<&Breaks.Collection>(from: Breaks.BreakCollectionStoragePath) == nil {
            let collection <- Breaks.createEmptyCollection()
            signer.storage.save(<-collection, to: Breaks.BreakCollectionStoragePath)
            
            let cap = signer.capabilities.storage.issue<&Breaks.Collection>(Breaks.BreakCollectionStoragePath)
            signer.capabilities.publish(cap, at: Breaks.BreakCollectionPublicPath)
        }

        self.breakCollection = signer.storage.borrow<&Breaks.Collection>(from: Breaks.BreakCollectionStoragePath)
            ?? panic("Could not borrow Break Collection")
    }

    execute {
        self.breakCollection.createBreak(price: price, totalSpots: totalSpots)
        log("Created new Break: ".concat(title))
    }
}