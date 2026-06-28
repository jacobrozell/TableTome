import Foundation

/// User-facing rules/search copy scoped by game system.
/// Delegates to `GameSystemRegistry` — do not add per-system switches here.
public enum GameSystemRulesLabels {
    public static let defaultGameSystemId = GameSystemId.default.rawValue

    private static let registry = GameSystemRegistry.bundled

    private static func copy(for gameSystemId: String) -> GameSystemCopy {
        registry.copy(for: gameSystemId) ?? fallbackCopy
    }

    private static let fallbackCopy = GameSystemCopy(
        shortLabel: String(localized: "Rules"),
        rulesTitle: String(localized: "Rules"),
        glossaryTitle: String(localized: "Glossary"),
        searchPrompt: String(localized: "Rules, units, topics…"),
        rulesSearchPrompt: String(localized: "Search rules"),
        browseIntro: String(localized: "Search rules, glossary terms, and guide topics."),
        gameGuideBrowseTitle: String(localized: "Game Guide"),
        searchEmptyStateHint: String(
            localized: "No matches — try fewer words or a glossary term like “rend” or “pile in”."
        ),
        displayName: String(localized: "Guided Match"),
        searchPickerLabel: String(localized: "Game System")
    )

    public static func tabTitle(gameSystemId: String) -> String {
        copy(for: gameSystemId).tabTitle
    }

    public static func tabAccessibilityTitle(gameSystemId: String) -> String {
        copy(for: gameSystemId).tabAccessibilityTitle
    }

    public static func rulesReferenceTitle(gameSystemId: String) -> String {
        copy(for: gameSystemId).rulesReferenceTitle
    }

    public static func glossaryTitle(gameSystemId: GameSystemId) -> String {
        glossaryTitle(gameSystemId: gameSystemId.rawValue)
    }

    public static func glossaryTitle(gameSystemId: String) -> String {
        copy(for: gameSystemId).glossaryTitle
    }

    public static func searchNavigationTitle(gameSystemId: String) -> String {
        copy(for: gameSystemId).searchNavigationTitle
    }

    public static func searchPrompt(gameSystemId: String) -> String {
        copy(for: gameSystemId).searchPrompt
    }

    public static func rulesSearchPrompt(gameSystemId: String) -> String {
        copy(for: gameSystemId).rulesSearchPrompt
    }

    public static func browseIntro(gameSystemId: String) -> String {
        copy(for: gameSystemId).browseIntro
    }

    public static func rulesReferenceLinkTitle(gameSystemId: String) -> String {
        copy(for: gameSystemId).rulesReferenceLinkTitle
    }

    public static func searchResultRulesSectionTitle(gameSystemId: String) -> String {
        copy(for: gameSystemId).searchResultRulesSectionTitle
    }

    public static func gameGuideBrowseTitle(gameSystemId: String) -> String {
        copy(for: gameSystemId).gameGuideBrowseTitle
    }

    public static func searchEmptyStateHint(gameSystemId: String) -> String {
        copy(for: gameSystemId).searchEmptyStateHint
    }

    public static func searchGameSystemPickerLabel(_ system: GameSystem) -> String {
        registry.copy(for: system.id)?.searchPickerLabel ?? system.name
    }

    public static func availableCategories(gameSystemId: String) -> [RuleSectionCategory] {
        registry.capabilities(for: gameSystemId)?.ruleCategories ?? RuleSectionCategory.allCases
    }

    public static func categoryLabel(
        _ category: RuleSectionCategory,
        gameSystemId: String
    ) -> String {
        switch category {
        case .core: String(localized: "Core")
        case .spearhead: String(localized: "Spearhead")
        case .combatPatrol: String(localized: "Combat Patrol")
        case .glossary: String(localized: "Glossary")
        }
    }

    public static func categoryRowLabel(
        _ category: RuleSectionCategory,
        gameSystemId: String
    ) -> String {
        switch category {
        case .core: String(localized: "Core Rules")
        case .spearhead: String(localized: "Spearhead")
        case .combatPatrol: String(localized: "Combat Patrol")
        case .glossary: String(localized: "Glossary")
        }
    }

    public static func displayName(gameSystemId: GameSystemId) -> String {
        displayName(gameSystemId: gameSystemId.rawValue)
    }

    public static func displayName(gameSystemId: String) -> String {
        copy(for: gameSystemId).displayName
    }

    public static func guidedMatchTitle(gameSystemId: GameSystemId) -> String {
        switch gameSystemId {
        case .aosSpearhead:
            String(localized: "Spearhead match")
        case .wh40k10eCp:
            String(localized: "Combat Patrol match")
        case .wh40k11e:
            String(localized: "Warhammer 40,000 match")
        case .scTmg:
            String(localized: "StarCraft match")
        }
    }
}
