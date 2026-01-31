import TopShot from "TopShot"

transaction(setName: String) {

    let admin: &TopShot.Admin

    prepare(signer: auth(Storage) &Account) {
        // borrow a reference to the admin resource
        self.admin = signer.storage.borrow<&TopShot.Admin>(from: /storage/TopShotAdmin)
            ?? panic("Could not borrow a reference to the TopShot Admin resource")
    }

    execute {
        let setID = self.admin.createSet(name: setName)
        log("Created Set with ID:")
        log(setID)
    }
}
