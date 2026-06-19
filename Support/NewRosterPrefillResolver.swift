import Foundation
import TabletomeDomain

/// Maps first-session Play context into optional New list defaults and starter-box guidance.
enum NewRosterPrefillResolver {
    struct Prefill: Equatable, Sendable {
        let suggestedFactions: [String]
        let suggestedBattleSizeKey: String?
        let starterBoxGuidance: StarterBoxGuidance?
    }

    struct StarterBoxGuidance: Equatable, Sendable {
        let gameSystemId: String
        let message: String
        let buttonTitle: String
    }

    private static let fixedRosterGameSystemIds: Set<String> = [
        GameSystemId.wh40k10eCp.rawValue,
        GameSystemId.aosSpearhead.rawValue,
        GameSystemId.scTmg.rawValue,
    ]

    static func isFixedRosterGameSystem(_ gameSystemId: String) -> Bool {
        fixedRosterGameSystemIds.contains(gameSystemId)
    }

    static func prefill(
        onboardingChoice: String?,
        activeGameSystemId: String,
        hasExplicitPrefill: Bool
    ) -> Prefill? {
        let resolvedGameSystemId = resolveGameSystemId(
            onboardingChoice: onboardingChoice,
            activeGameSystemId: activeGameSystemId
        )
        let suggestedFactions = suggestedFactions(for: resolvedGameSystemId)
        let suggestedBattleSizeKey = suggestedBattleSizeKey(for: resolvedGameSystemId)
        let starterBoxGuidance = hasExplicitPrefill
            ? nil
            : starterBoxGuidance(for: resolvedGameSystemId)
        guard starterBoxGuidance != nil
            || suggestedBattleSizeKey != nil
            || !suggestedFactions.isEmpty else {
            return nil
        }
        return Prefill(
            suggestedFactions: suggestedFactions,
            suggestedBattleSizeKey: suggestedBattleSizeKey,
            starterBoxGuidance: starterBoxGuidance
        )
    }

    static func rosterFactionLabel(forSlug slug: String, game: String = "40k") -> String? {
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

    private static func suggestedFactions(for gameSystemId: String?) -> [String] {
        guard let gameSystemId,
              let gameSystem = GameSystemId(knownRawValue: gameSystemId),
              gameSystem == .wh40k10eCp || gameSystem == .wh40k11e,
              let featured = GameSystemRegistry.bundled.featuredArmies(for: gameSystem) else {
            return []
        }
        let slugs = [featured.playerOne.factionId, featured.playerTwo.factionId]
        var labels: [String] = []
        for slug in slugs {
            guard let label = rosterFactionLabel(forSlug: slug) else { continue }
            if !labels.contains(label) {
                labels.append(label)
            }
        }
        return labels
    }

    private static func suggestedBattleSizeKey(for gameSystemId: String?) -> String? {
        guard let gameSystemId,
              let gameSystem = GameSystemId(knownRawValue: gameSystemId) else {
            return nil
        }
        switch gameSystem {
        case .wh40k10eCp:
            return "combat-patrol"
        case .wh40k11e, .aosSpearhead, .scTmg:
            return nil
        }
    }

    private static func starterBoxGuidance(for gameSystemId: String?) -> StarterBoxGuidance? {
        guard let gameSystemId,
              fixedRosterGameSystemIds.contains(gameSystemId),
              let gameSystem = GameSystemId(knownRawValue: gameSystemId) else {
            return nil
        }
        let displayName = GameSystemRulesLabels.displayName(gameSystemId: gameSystem)
        return StarterBoxGuidance(
            gameSystemId: gameSystemId,
            message: String(
                localized: """
                \(displayName) uses fixed box rosters — you don't need an army list for your first game. \
                Start on Play with Guided Match instead.
                """
            ),
            buttonTitle: String(localized: "Open Guided Match")
        )
    }
}
