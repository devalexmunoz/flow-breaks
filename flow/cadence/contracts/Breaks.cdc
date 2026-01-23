import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"
import FungibleToken from "FungibleToken"
import FlowToken from "FlowToken"

access(all) contract Breaks {

    // -----------------------------------------------------------------------
    // Events
    // -----------------------------------------------------------------------
    access(all) event BreakCreated(breakId: UInt64, host: Address, price: UFix64, totalSpots: UInt64)
    access(all) event SpotPurchased(breakId: UInt64, buyer: Address, spotIndex: UInt64)
    access(all) event StatusChanged(breakId: UInt64, status: UInt8)

    // -----------------------------------------------------------------------
    // Paths
    // -----------------------------------------------------------------------
    access(all) let BreakCollectionStoragePath: StoragePath
    access(all) let BreakCollectionPublicPath: PublicPath

    // -----------------------------------------------------------------------
    // State
    // -----------------------------------------------------------------------
    access(all) var nextBreakId: UInt64

    // -----------------------------------------------------------------------
    // Enums
    // -----------------------------------------------------------------------
    access(all) enum BreakStatus: UInt8 {
        access(all) case OPEN
        access(all) case FILLED
        access(all) case RANDOMIZED
        access(all) case COMPLETED
    }

    // -----------------------------------------------------------------------
    // The "BreakPool" Resource
    // -----------------------------------------------------------------------
    access(all) resource BreakPool {
        access(all) let id: UInt64
        access(all) let host: Address
        access(all) let price: UFix64
        access(all) let totalSpots: UInt64
        
        access(all) var spots: {UInt64: Address} 
        access(all) var status: BreakStatus

        access(self) let escrow: @FlowToken.Vault

        init(host: Address, price: UFix64, totalSpots: UInt64) {
            self.id = Breaks.nextBreakId
            self.host = host
            self.price = price
            self.totalSpots = totalSpots
            self.spots = {}
            self.status = BreakStatus.OPEN
            self.escrow <- FlowToken.createEmptyVault(vaultType: Type<@FlowToken.Vault>())

            Breaks.nextBreakId = Breaks.nextBreakId + 1
        }

        access(all) fun buySpot(payment: @FlowToken.Vault, buyer: Address) {
            pre {
                self.status == BreakStatus.OPEN: "Break is not open."
                self.spots.keys.length < Int(self.totalSpots): "Break is full."
                payment.balance == self.price: "Incorrect payment amount."
            }

            self.escrow.deposit(from: <-payment)

            let newSpotIndex = UInt64(self.spots.keys.length)
            self.spots[newSpotIndex] = buyer

            emit SpotPurchased(breakId: self.id, buyer: buyer, spotIndex: newSpotIndex)

            if self.spots.keys.length == Int(self.totalSpots) {
                self.status = BreakStatus.FILLED
                emit StatusChanged(breakId: self.id, status: self.status.rawValue)
            }
        }

        access(all) view fun getEscrowBalance(): UFix64 {
            return self.escrow.balance
        }
    }

    // -----------------------------------------------------------------------
    //  Collection
    // -----------------------------------------------------------------------
    access(all) resource interface BreakCollectionPublic {
        access(all) fun getBreakIDs(): [UInt64]
        access(all) fun borrowBreak(breakId: UInt64): &BreakPool
        access(all) fun createBreak(price: UFix64, totalSpots: UInt64)
    }

    access(all) resource Collection: BreakCollectionPublic {
        access(all) var breaks: @{UInt64: BreakPool}

        init() {
            self.breaks <- {}
        }

        access(all) fun createBreak(price: UFix64, totalSpots: UInt64) {
            let newBreak <- create BreakPool(
                host: self.owner!.address,
                price: price,
                totalSpots: totalSpots
            )

            let id = newBreak.id
            self.breaks[id] <-! newBreak

            emit BreakCreated(breakId: id, host: self.owner!.address, price: price, totalSpots: totalSpots)
        }

        access(all) view fun  getBreakIDs(): [UInt64] {
            return self.breaks.keys
        }

        access(all) view fun borrowBreak(breakId: UInt64): &BreakPool {
            return (&self.breaks[breakId] as &BreakPool?)!
        }
    }

    // -----------------------------------------------------------------------
    //  Global Functions
    // -----------------------------------------------------------------------
    access(all) fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    // -----------------------------------------------------------------------
    // Contract Init
    // -----------------------------------------------------------------------
    init() {
        self.nextBreakId = 1
        self.BreakCollectionStoragePath = /storage/BreakCollection
        self.BreakCollectionPublicPath = /public/BreakCollection

        let collection <- create Collection()
        self.account.storage.save(<-collection, to: self.BreakCollectionStoragePath)

        let collectionCap = self.account.capabilities.storage.issue<&Breaks.Collection>(self.BreakCollectionStoragePath)
        self.account.capabilities.publish(collectionCap, at: self.BreakCollectionPublicPath)
    }
}