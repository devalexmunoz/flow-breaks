import Breaks from "Breaks"

access(all) fun main(host: Address): [UInt64] {
    
    let collection = getAccount(host)
        .capabilities.borrow<&{Breaks.BreakCollectionPublic}>(Breaks.BreakCollectionPublicPath)
        ?? panic("Could not borrow BreakCollectionPublic.")

    return collection.getBreakIDs()
}