import Foundation
import TabletomeDomain

/// Maps first-session Play context into optional New army defaults.
enum CollectionArmyPrefillResolver {
    struct Prefill: Equatable, Sendable {
        let game: String
        let suggestedFactions: [String]
        let suggestedArmyName: String?
    }

    /// Faction and army name applied after the game picker’s async faction reset (Add army sheet).
    struct NewArmyDeferredDefaults: Equatable, Sendable {
        let faction: String?
        let armyName: String?
    }

    static func newArmyDeferredDefaults(from prefill: Prefill, existingName: String) -> NewArmyDeferredDefaults {
        let faction = prefill.suggestedFactions.first
        let armyName: String?
        if existingName.trimmingCharacters(in: .whitespaces).isEmpty {
            armyName = prefill.suggestedArmyName ?? faction.map { String(localized: "My \($0)") }
        } else {
            armyName = nil
        }
        return NewArmyDeferredDefaults(faction: faction, armyName: armyName)
    }

    static func prefill(onboardingChoice: String?, activeGameSystemId: String) -> Prefill? {
        guard let gameSystemId = resolveGameSystemId(
            onboardingChoice: onboardingChoice,
            activeGameSystemId: activeGameSystemId
        ),
              let gameSystem = GameSystemId(knownRawValue: gameSystemId),
              let hobbyGame = hobbyGame(for: gameSystem) else {
            return nil
        }
        let factions = suggestedFactions(for: gameSystem, hobbyGame: hobbyGame)
        let armyName = factions.first.map { String(localized: "My \($0)") }
        return Prefill(game: hobbyGame, suggestedFactions: factions, suggestedArmyName: armyName)
    }

    static func factionLabel(forSlug slug: String, game: String) -> String? {
        let humanized = slug
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
        let label = FactionResolver.normalize(humanized)
        guard FactionResolver.canonicalByGame[game]?.contains(label) == true else { return nil }
        return label
    }

    private static func resolveGameSystemId(
        onboardingChoice: String?,
        activeGameSystemId: String
    ) -> String? {
        if let onboardingChoice, GameSystemId(knownRawValue: onboardingChoice) != nil {
            return onboardingChoice
        }
        if GameSystemId(knownRawValue: activeGameSystemId) != nil {
            return activeGameSystemId
        }
        return onboardingChoice ?? activeGameSystemId
    }

    private static func hobbyGame(for gameSystem: GameSystemId) -> String? {
        switch gameSystem {
        case .aosSpearhead:
            return "AoS"
        case .wh40k11e, .wh40k10eCp:
            return "40k"
        case .scTmg:
            return nil
        }
    }

    private static func suggestedFactions(for gameSystem: GameSystemId, hobbyGame: String) -> [String] {
        guard let featured = GameSystemRegistry.bundled.featuredArmies(for: gameSystem) else {
            return []
        }
        let slugs = [featured.playerOne.factionId, featured.playerTwo.factionId]
        var labels: [String] = []
        for slug in slugs {
            guard let label = factionLabel(forSlug: slug, game: hobbyGame) else { continue }
            if !labels.contains(label) {
                labels.append(label)
            }
        }
        return labels
    }
}
