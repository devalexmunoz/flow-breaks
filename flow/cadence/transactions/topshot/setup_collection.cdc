import TopShot from "TopShot"

transaction {

    prepare(signer: auth(Storage, Capabilities) &Account) {
        // Return early if the account already has a collection
        if signer.storage.borrow<&TopShot.Collection>(from: /storage/MomentCollection) != nil {
            return
        }

        // Create a new empty collection
        let collection <- TopShot.createEmptyCollection(nftType: Type<@TopShot.NFT>())

        // save it to the account
        signer.storage.save(<-collection, to: /storage/MomentCollection)

        // create a public capability for the collection
        let cap = signer.capabilities.storage.issue<&TopShot.Collection>(/storage/MomentCollection)
        signer.capabilities.publish(cap, at: /public/MomentCollection)
    }
}
