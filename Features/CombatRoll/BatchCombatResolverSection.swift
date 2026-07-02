import SwiftUI
import TabletomeDomain

struct BatchCombatResolverSection: View {
    @ObservedObject var batchViewModel: BatchCombatEvaluatorViewModel
    @ObservedObject var combatViewModel: UnitMatchupEvaluatorViewModel
    let accessibilityPrefix: String
    var defenderName: String?
    var defenderWoundsRemaining: Int?
    var onApplyDamage: ((Int, CombatBatchLogContext?) -> Void)?

    @State private var confirmedZeroHits = false
    @State private var confirmedZeroWounds = false

    var body: some View {
        if combatViewModel.canEvaluate {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                BatchCombatResolverHeaderSection(hitDiceCount: batchViewModel.hitDiceCount)
                BatchCombatResolverFlowPillsSection(
                    hasWardTarget: batchViewModel.wardTarget != nil,
                    activeStep: activeStep,
                    stepIsComplete: stepIsComplete
                )
                BatchCombatResolverInputsSection(
                    batchViewModel: batchViewModel,
                    confirmedZeroHits: $confirmedZeroHits,
                    confirmedZeroWounds: $confirmedZeroWounds,
                    accessibilityPrefix: accessibilityPrefix,
                    activeStep: activeStep,
                    hitsStepComplete: hitsStepComplete,
                    woundsStepComplete: woundsStepComplete,
                    savesStepComplete: savesStepComplete,
                    wardStepComplete: wardStepComplete,
                    wardStepNumber: wardStepNumber,
                    woundsStepHint: woundsStepHint
                )
                BatchCombatResolverSaveReferenceSection(
                    successfulWounds: batchViewModel.successfulWounds,
                    mortalDamage: batchViewModel.mortalDamage,
                    saveTarget: batchViewModel.saveTarget,
                    rend: batchViewModel.rend,
                    saveNeededOnDice: batchViewModel.saveNeededOnDice,
                    usesWh40kRules: usesWh40kRules
                )
                if let evaluation = batchViewModel.evaluation {
                    BatchCombatResolverOutcomeSection(
                        batchViewModel: batchViewModel,
                        combatViewModel: combatViewModel,
                        evaluation: evaluation,
                        accessibilityPrefix: accessibilityPrefix,
                        defenderName: defenderName,
                        defenderWoundsRemaining: defenderWoundsRemaining,
                        onApplyDamage: onApplyDamage
                    )
                }
            }
            .padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
            .accessibilityIdentifier("\(accessibilityPrefix).batchCombat")
        }
    }

    private var woundsStepHint: String {
        if batchViewModel.successfulHits == 0 {
            return String(localized: "Enter 0 if no hits became wounds")
        }
        return String(localized: "How many hits became wounds after wound rolls")
    }

    private var hitsStepComplete: Bool {
        batchViewModel.successfulHits > 0 || confirmedZeroHits
    }

    private var woundsStepComplete: Bool {
        guard hitsStepComplete, !confirmedZeroHits else { return confirmedZeroHits }
        return batchViewModel.successfulWounds > 0
            || batchViewModel.failedSaves > 0
            || batchViewModel.wardNegatedCount > 0
            || confirmedZeroWounds
    }

    private var savesStepComplete: Bool {
        guard woundsStepComplete, !confirmedZeroHits, !confirmedZeroWounds else {
            return confirmedZeroHits || confirmedZeroWounds
        }
        return batchViewModel.failedSaves > 0
            || batchViewModel.wardNegatedCount > 0
            || batchViewModel.mortalDamage
            || batchViewModel.successfulWounds == 0
    }

    private var wardStepComplete: Bool {
        guard savesStepComplete, !confirmedZeroHits, !confirmedZeroWounds else {
            return confirmedZeroHits || confirmedZeroWounds
        }
        return batchViewModel.wardNegatedCount > 0 || batchViewModel.wardTarget == nil
    }

    private var wardStepNumber: Int {
        batchViewModel.mortalDamage ? 3 : 4
    }

    private var usesWh40kRules: Bool {
        CombatRollEngineRouter.usesWh40kRules(gameSystemId: combatViewModel.gameSystemId)
    }

    private var activeStep: BatchCombatFlowStep {
        if !hitsStepComplete { return .hits }
        if !woundsStepComplete { return .wounds }
        if !batchViewModel.mortalDamage, !savesStepComplete { return .saves }
        if batchViewModel.wardTarget != nil, !wardStepComplete { return .ward }
        return .damage
    }

    private func stepIsComplete(_ step: BatchCombatFlowStep) -> Bool {
        switch step {
        case .hits: hitsStepComplete
        case .wounds: woundsStepComplete
        case .saves: savesStepComplete
        case .ward: wardStepComplete
        case .damage: (batchViewModel.evaluation?.totalDamage ?? 0) >= 0 && hitsStepComplete
        }
    }
}
