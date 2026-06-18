import Foundation

/// User-facing rules/search copy scoped by game system as Tabletome adds more modes.
public enum GameSystemRulesLabels {
    public static let defaultGameSystemId = "aos-spearhead"

    public static func tabTitle(gameSystemId: String) -> String {
        switch gameSystemId {
        case "aos-spearhead": String(localized: "AoS")
        case "wh40k-11e": String(localized: "40k")
        default: String(localized: "Rules")
        }
    }

    public static func tabAccessibilityTitle(gameSystemId: String) -> String {
        switch gameSystemId {
        case "aos-spearhead": String(localized: "AoS Rules")
        case "wh40k-11e": String(localized: "40k Rules")
        default: String(localized: "Rules")
        }
    }

    public static func rulesReferenceTitle(gameSystemId: String) -> String {
        tabAccessibilityTitle(gameSystemId: gameSystemId)
    }

    public static func glossaryTitle(gameSystemId: String) -> String {
        switch gameSystemId {
        case "aos-spearhead": String(localized: "AoS Glossary")
        case "wh40k-11e": String(localized: "40k Glossary")
        default: String(localized: "Glossary")
        }
    }

    public static func searchNavigationTitle(gameSystemId: String) -> String {
        tabAccessibilityTitle(gameSystemId: gameSystemId)
    }

    public static func searchPrompt(gameSystemId: String) -> String {
        switch gameSystemId {
        case "aos-spearhead": String(localized: "AoS rules, units, topics…")
        case "wh40k-11e": String(localized: "40k rules, units, topics…")
        default: String(localized: "Rules, units, topics…")
        }
    }

    public static func rulesSearchPrompt(gameSystemId: String) -> String {
        switch gameSystemId {
        case "aos-spearhead": String(localized: "Search AoS rules")
        case "wh40k-11e": String(localized: "Search 40k rules")
        default: String(localized: "Search rules")
        }
    }

    public static func browseIntro(gameSystemId: String) -> String {
        switch gameSystemId {
        case "aos-spearhead":
            String(
                localized: """
                Search Age of Sigmar Spearhead rules, glossary terms, warscrolls, setup steps, and phase tips.
                """
            )
        case "wh40k-11e":
            String(
                localized: """
                Search Warhammer 40,000 11th Edition rules, glossary terms, and guide topics.
                """
            )
        default:
            String(localized: "Search rules, glossary terms, and guide topics.")
        }
    }

    public static func rulesReferenceLinkTitle(gameSystemId: String) -> String {
        rulesReferenceTitle(gameSystemId: gameSystemId)
    }

    public static func searchResultRulesSectionTitle(gameSystemId: String) -> String {
        switch gameSystemId {
        case "aos-spearhead": String(localized: "AoS Rules")
        case "wh40k-11e": String(localized: "40k Rules")
        default: String(localized: "Rules")
        }
    }
}
