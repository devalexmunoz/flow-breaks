import Breaks from "Breaks"

transaction(breakId: UInt64, teams: [String]) {

    let breakPoolRef: &Breaks.BreakPool

    prepare(signer: auth(BorrowValue) &Account) {
        // Borrow the BreakCollection from the signer (Host) to access the private BreakPool resource
        let collectionRef = signer.storage.borrow<&Breaks.Collection>(from: Breaks.BreakCollectionStoragePath)
            ?? panic("Could not borrow reference to the Break Collection")
            
        // Borrow the specific BreakPool to call the randomize function
        // Note: In the contract, borrowBreak is public but returns &BreakPool. 
        // We need to ensure we can call mutating functions.
        // Since the collection is in the signer's storage, we have full access.
        self.breakPoolRef = collectionRef.borrowBreak(breakId: breakId)
    }

    execute {
        // Call the randomize function
        self.breakPoolRef.randomize(teams: teams)
        log("Break randomized and teams assigned!")
    }
}
