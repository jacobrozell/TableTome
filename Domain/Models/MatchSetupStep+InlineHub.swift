import Foundation

extension MatchSetupStep {
    /// Steps whose controls can live on the Setup tab without pushing a detail screen.
    public static let inlineHubSetupStepIds: Set<String> = [
        "roll-attacker",
        "pick-enhancement",
        "determine-mission",
        "setup-battlefield",
        "declare-formations",
        "deploy-armies",
        "roll-first-turn",
        "regiment-abilities",
        "force-disposition",
        "enhancements",
        "realm-battlefield",
        "deploy-battlefield",
        "battlefield-setup",
    ]

    public var supportsInlineHubSetup: Bool {
        Self.inlineHubSetupStepIds.contains(id)
    }

    /// Battlefield/deployment steps that use a shortened inline layout on the Setup tab.
    public static let compactInlineBattlefieldStepIds: Set<String> = [
        "realm-battlefield",
        "deploy-battlefield",
        "battlefield-setup",
        "setup-battlefield",
    ]

    public var usesCompactInlineHubContent: Bool {
        Self.compactInlineBattlefieldStepIds.contains(id)
    }
}
