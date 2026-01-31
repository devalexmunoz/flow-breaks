import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"
import FungibleToken from "FungibleToken"
import FlowToken from "FlowToken"
import RandomBeaconHistory from "RandomBeaconHistory"

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
        
        // New fields for draft/randomization
        access(all) var teams: [String]
        access(all) var assignments: {UInt64: [String]}

        access(self) let escrow: @FlowToken.Vault

        init(host: Address, price: UFix64, totalSpots: UInt64) {
            self.id = Breaks.nextBreakId
            self.host = host
            self.price = price
            self.totalSpots = totalSpots
            self.spots = {}
            self.status = BreakStatus.OPEN
            self.teams = []
            self.assignments = {}
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

        access(all) fun randomize(teams: [String]) {
            pre {
                self.status == BreakStatus.FILLED: "Break is not filled."
                teams.length >= Int(self.totalSpots): "Number of teams must be at least the number of spots."
            }

            self.teams = teams
            
            // Secure Randomness using RandomBeaconHistory
            let blockHeight = getCurrentBlock().height
            // Get the source of randomness from the previous block to ensure it's available
            let sourceOfRandomness = RandomBeaconHistory.sourceOfRandomness(atBlockHeight: blockHeight - 1)
            let randomCoordinates = sourceOfRandomness.value

            // Use the random coordinates to seed our shuffle
            // We'll use a simple approach of hashing the seed with the index to get a new random value for each swap
            
            var i = 0
            while i < self.teams.length - 1 {
                // Combine random coordinates with the current index to vary the randomness
                // In a real production app, consider a more robust PRNG helper contract
                let dataToHash = randomCoordinates.concat(i.toBigEndianBytes())
                let hash = String.encodeHex(HashAlgorithm.SHA3_256.hash(dataToHash))
                
                // Convert a portion of the hash to a UInt64
                // Taking first 8 bytes (16 hex chars) roughly
                // For simplicity in this demo without a helper, we can treat the hash bytes as the source
                let hashBytes = HashAlgorithm.SHA3_256.hash(dataToHash)
                
                // Manual conversion of first 8 bytes to UInt64
                var randomVal: UInt64 = 0
                var b = 0
                while b < 8 {
                    randomVal = randomVal | (UInt64(hashBytes[b]) << UInt64(b * 8))
                    b = b + 1
                }

                // Random index j where i <= j < n
                let range = UInt64(self.teams.length - i)
                let j = Int(randomVal % range) + i
                
                // Swap
                let temp = self.teams[i]
                self.teams[i] = self.teams[j]
                self.teams[j] = temp
                
                i = i + 1
            }

            // Assign teams to spots in a Round Robin fashion
            
            // 1. Initialize empty arrays for all spot IDs
            var spotIndex: UInt64 = 0
            while spotIndex < self.totalSpots {
                self.assignments[spotIndex] = []
                spotIndex = spotIndex + 1
            }

            // 2. Distribute teams
            var teamIndex = 0
            while teamIndex < self.teams.length {
                let targetSpot = UInt64(teamIndex) % self.totalSpots
                
                // Append team to the target spot's list
                // Since we initialized all keys above, force unwrap is safe
                self.assignments[targetSpot]?.append(self.teams[teamIndex])
                
                teamIndex = teamIndex + 1
            }

            self.status = BreakStatus.RANDOMIZED
            emit StatusChanged(breakId: self.id, status: self.status.rawValue)
        }

        access(all) view fun getWinner(team: String): Address? {
            // Iterate through all spot assignments
            for spotId in self.assignments.keys {
                let assignedTeams = self.assignments[spotId]!
                
                // Check if the team is in this spot's list
                if assignedTeams.contains(team) {
                    // Return the owner of this spot
                    return self.spots[spotId]
                }
            }
            return nil
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