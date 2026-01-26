import Breaks from "Breaks"

transaction(price: UFix64, totalSpots: UInt64) {

    prepare(signer: auth(Storage) &Account) {
        let collectionRef = signer.storage.borrow<&Breaks.Collection>(
            from: Breaks.BreakCollectionStoragePath
        ) ?? panic("Could not borrow BreakCollection.")

        collectionRef.createBreak(price: price, totalSpots: totalSpots)
    }

    execute {
        log("Break Created Successfully!")
    }
}