import TopShot from 0xTopShot
import Breaks from 0xBreaks
import NonFungibleToken from 0xNonFungibleToken

transaction(breakId: UInt64, momentIDs: [UInt64]) {
    
    let adminCollection: auth(NonFungibleToken.Withdraw) &TopShot.Collection
    let breakPoolRef: &Breaks.BreakPool

    prepare(signer: auth(Storage) &Account) {
        // Borrow Admin's TopShot Collection with withdraw capability
        // Use the storage path defined in the contract or standard path
        self.adminCollection = signer.storage.borrow<auth(NonFungibleToken.Withdraw) &TopShot.Collection>(from: /storage/MomentCollection)
            ?? panic("Could not borrow TopShot Collection from admin")

        // Borrow Breaks Collection
        let breakCollection = signer.storage.borrow<&Breaks.Collection>(from: Breaks.BreakCollectionStoragePath)
            ?? panic("Could not borrow Break Collection")
            
        self.breakPoolRef = breakCollection.borrowBreak(breakId: breakId)
    }

    execute {
        for momentID in momentIDs {
            // Borrow the moment to inspect metadata
            // Admin collection allows borrowing moment reference to read data
            if let momentRef = self.adminCollection.borrowMoment(id: momentID) {
                let playID = momentRef.data.playID
                let teamInfo = TopShot.getPlayMetaDataByField(playID: playID, field: "TeamAtMoment")
                
                if let team = teamInfo {
                     if let winnerAddress = self.breakPoolRef.getWinner(team: team) {
                        
                        // Get winner's capability
                        let winnerAccount = getAccount(winnerAddress)
                        let winnerCollectionCap = winnerAccount.capabilities.get<&{TopShot.MomentCollectionPublic}>(/public/MomentCollection)

                        if let winnerCollection = winnerCollectionCap.borrow() {
                            // Withdraw and Deposit
                            let moment <- self.adminCollection.withdraw(withdrawID: momentID)
                            winnerCollection.deposit(token: <-moment)
                            log("Distributed moment to winner: ".concat(winnerAddress.toString()))
                        } else {
                            log("Winner ".concat(winnerAddress.toString()).concat(" does not have a Moment Collection set up"))
                        }
                     } else {
                         log("No winner found for team: ".concat(team))
                     }
                } else {
                    log("Could not find TeamAtMoment for playID")
                }
            } else {
                log("Could not borrow moment from admin collection: ".concat(momentID.toString()))
            }
        }
    }
}
