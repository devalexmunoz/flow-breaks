import TopShot from "TopShot"

transaction(metadata: {String: String}) {

    let admin: &TopShot.Admin

    prepare(signer: auth(Storage) &Account) {
        // borrow a reference to the admin resource
        self.admin = signer.storage.borrow<&TopShot.Admin>(from: /storage/TopShotAdmin)
            ?? panic("Could not borrow a reference to the TopShot Admin resource")
    }

    execute {
        let playID = self.admin.createPlay(metadata: metadata)
        log("Created Play with ID:")
        log(playID)
    }
}
