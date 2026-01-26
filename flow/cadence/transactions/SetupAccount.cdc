import Breaks from "Breaks"

transaction {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue, UnpublishCapability) &Account) {
        
        if signer.storage.borrow<&Breaks.Collection>(from: Breaks.BreakCollectionStoragePath) != nil {
            return
        }

        let collection <- Breaks.createEmptyCollection()
        signer.storage.save(<-collection, to: Breaks.BreakCollectionStoragePath)

        signer.capabilities.unpublish(Breaks.BreakCollectionPublicPath)

        let collectionCap = signer.capabilities.storage.issue<&Breaks.Collection>(Breaks.BreakCollectionStoragePath)
        
        signer.capabilities.publish(collectionCap, at: Breaks.BreakCollectionPublicPath)
        
        log("Breaks Collection created and setup successfully.")
    }
}