import Foundation

public enum OwnedArmyResolver: Sendable {
    public static func ownedArmyIds(for profile: PlayerProfile) -> Set<String> {
        profile.ownedSpearheadArmyIds
    }

    public static func filtersArmies(
        _ armies: [SpearheadArmy],
        ownedIds: Set<String>
    ) -> (owned: [SpearheadArmy], other: [SpearheadArmy]) {
        let owned = armies.filter { ownedIds.contains($0.id) }
        let other = armies.filter { !ownedIds.contains($0.id) }
        return (owned, other)
    }
}
