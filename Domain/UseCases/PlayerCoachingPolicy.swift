import Foundation

public enum PlayerCoachingPolicy: Sendable {
    public enum TipKey: String, Sendable {
        case battleTrackerCoach = "battle_tracker_coach"
        case combatSequencePrimer = "combat_sequence_primer"
        case pileInGuide = "pile_in_guide"
        case guidedMatchSetupExpanded = "guided_match_setup_expanded"
        case physicalDiceResolverHint = "physical_dice_resolver_hint"
        case heroRoundOneNudge = "hero_round_one_nudge"
        case battleTacticCommandGuide = "battle_tactic_command_guide"
        case wargamePrimer = "wargame_primer"
    }

    public static func showsPlayerScopedCoaching(for profile: PlayerProfile?) -> Bool {
        guard let profile else { return true }
        return profile.guidedMatchPreferences.experienceLevel != .tableRegular
    }

    /// Resolution order: table-regular suppresses → global dismiss → per-profile dismiss.
    public static func shouldShowTip(
        tipKey: TipKey,
        profile: PlayerProfile?,
        globallyDismissed: Bool
    ) -> Bool {
        guard showsPlayerScopedCoaching(for: profile) else { return false }
        if globallyDismissed { return false }
        if let profile, profile.guidedMatchPreferences.dismissedCoachTipKeys.contains(tipKey.rawValue) {
            return false
        }
        return true
    }

    public static func isGloballyDismissed(_ tipKey: TipKey) -> Bool {
        switch tipKey {
        case .battleTrackerCoach:
            NewPlayerTipsStore.hasSeenBattleTrackerCoach
        case .combatSequencePrimer:
            NewPlayerTipsStore.hasDismissedCombatSequencePrimer
        case .pileInGuide:
            NewPlayerTipsStore.hasDismissedPileInGuide
        case .guidedMatchSetupExpanded:
            NewPlayerTipsStore.hasExpandedGuidedMatchSetup
        case .physicalDiceResolverHint:
            NewPlayerTipsStore.hasSeenPhysicalDiceResolverHint
        case .heroRoundOneNudge:
            NewPlayerTipsStore.hasDismissedHeroRoundOneNudge
        case .battleTacticCommandGuide:
            NewPlayerTipsStore.hasDismissedBattleTacticCommandGuide
        case .wargamePrimer:
            NewPlayerTipsStore.hasDismissedWargamePrimer
        }
    }
}
