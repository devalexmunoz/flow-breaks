import TopShot from "TopShot"
import NonFungibleToken from "NonFungibleToken"

transaction(setID: UInt32, playID: UInt32, recipientAddr: Address) {

    let admin: &TopShot.Admin
    let receiverRef: &{NonFungibleToken.CollectionPublic}

    prepare(signer: auth(Storage) &Account) {
        // borrow a reference to the admin resource
        self.admin = signer.storage.borrow<&TopShot.Admin>(from: /storage/TopShotAdmin)
            ?? panic("Could not borrow a reference to the TopShot Admin resource")
        
        // get the recipient's public collection reference
        let recipient = getAccount(recipientAddr)
        self.receiverRef = recipient.capabilities.get<&{NonFungibleToken.CollectionPublic}>(/public/MomentCollection).borrow()
            ?? panic("Could not borrow a reference to the recipient's Moment Collection")
    }

    execute {
        // borrow a reference to the set
        let setRef = self.admin.borrowSet(setID: setID)

        // mint the moment
        let moment <- setRef.mintMoment(playID: playID)
        
        log("Minted Moment with ID:")
        log(moment.id)

        // deposit the moment in the recipient's collection
        self.receiverRef.deposit(token: <-moment)
    }
}
