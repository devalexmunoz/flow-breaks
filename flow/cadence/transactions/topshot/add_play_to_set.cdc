import TopShot from "TopShot"

transaction(setID: UInt32, playID: UInt32) {

    let admin: &TopShot.Admin

    prepare(signer: auth(Storage) &Account) {
        // borrow a reference to the admin resource
        self.admin = signer.storage.borrow<&TopShot.Admin>(from: /storage/TopShotAdmin)
            ?? panic("Could not borrow a reference to the TopShot Admin resource")
    }

    execute {
        // borrow a reference to the set
        let setRef = self.admin.borrowSet(setID: setID)

        // add the play to the set
        setRef.addPlay(playID: playID)
        
        log("Added Play to Set")
    }
}
