import Foundation
import TabletomeDomain

extension Army {
    public func presentation(overrides: [FactionPresetOverride]) -> FactionPresentation {
        let resolved = FactionResolver.resolve(faction: faction, game: game, overrides: overrides)
        return FactionPresentation(
            crest: crestOverride ?? resolved.crest,
            colorHex: safeColor(colorOverrideHex ?? resolved.colorHex),
            imageFileName: resolved.imageFileName
        )
    }
}

extension Roster {
    public func presentation(overrides: [FactionPresetOverride]) -> FactionPresentation {
        FactionResolver.resolve(faction: faction, game: game, overrides: overrides)
    }

    public var orderedEntries: [RosterEntry] {
        entries.sorted {
            if $0.sortIndex != $1.sortIndex { return $0.sortIndex < $1.sortIndex }
            return $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }
    }

    public func touch() { updatedAt = Date() }
}
