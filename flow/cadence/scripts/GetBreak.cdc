import Breaks from "Breaks"

access(all) fun main(host: Address, breakId: UInt64): {String: AnyStruct} {
    
    let collection = getAccount(host)
        .capabilities.borrow<&{Breaks.BreakCollectionPublic}>(Breaks.BreakCollectionPublicPath)
        ?? panic("Could not borrow BreakCollectionPublic.")

    let breakPool = collection.borrowBreak(breakId: breakId)

    return {
        "id": breakPool.id,
        "price": breakPool.price,
        "totalSpots": breakPool.totalSpots,
        "spotsFilled": breakPool.spots.keys.length,
        "spots": breakPool.spots,
        "status": breakPool.status.rawValue,
        "escrowBalance": breakPool.getEscrowBalance()
    }
}