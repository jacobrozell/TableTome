import SwiftUI
import TabletomeDomain

/// Legacy entry point — forwards to the unit-based Combat Resolver.
struct CombatRollEvaluatorView: View {
    let ruleSections: [RuleSection]
    let attackerPrefill: MatchupUnitPrefill?

    init(ruleSections: [RuleSection] = [], prefilledWeapon: SpearheadWeapon? = nil) {
        self.ruleSections = ruleSections
        self.attackerPrefill = nil
    }

    init(
        ruleSections: [RuleSection] = [],
        attackerPrefill: MatchupUnitPrefill?
    ) {
        self.ruleSections = ruleSections
        self.attackerPrefill = attackerPrefill
    }

    var body: some View {
        UnitMatchupEvaluatorView(
            ruleSections: ruleSections,
            attackerPrefill: attackerPrefill
        )
        .accessibilityIdentifier("rollEvaluator.screen")
    }
}
