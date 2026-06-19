import Foundation
import TabletomeDomain

extension Army {
    public func presentation(overrides: [FactionPresetOverride]) -> (crest: String, colorHex: String) {
        let resolved = FactionResolver.resolve(faction: faction, game: game, overrides: overrides)
        return (crestOverride ?? resolved.crest, safeColor(colorOverrideHex ?? resolved.color))
    }
}

extension Roster {
    public func presentation(overrides: [FactionPresetOverride]) -> (crest: String, colorHex: String) {
        let resolved = FactionResolver.resolve(faction: faction, game: game, overrides: overrides)
        return (resolved.crest, resolved.color)
    }

    public var orderedEntries: [RosterEntry] {
        entries.sorted {
            if $0.sortIndex != $1.sortIndex { return $0.sortIndex < $1.sortIndex }
            return $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }
    }

    public func touch() { updatedAt = Date() }
}
