import Foundation
import TabletomeDomain

@MainActor
final class BatchCombatEvaluatorViewModel: ObservableObject {
    @Published var successfulHits = 0
    @Published var successfulWounds = 0
    @Published var failedSaves = 0
    @Published var wardNegatedCount = 0
    @Published var damagePerWound = 1
    @Published var usesManualTotalDamage = false
    @Published var manualTotalDamage = 0
    @Published private(set) var hitDiceCount = 1
    @Published private(set) var saveTarget = 4
    @Published private(set) var rend = 0
    @Published private(set) var saveNeededOnDice = 4
    @Published private(set) var wardTarget: Int?
    @Published private(set) var mortalDamage = false
    @Published private(set) var usesVariableDamage = false
    @Published private(set) var evaluation: BatchCombatRollEvaluation?

    func sync(from viewModel: UnitMatchupEvaluatorViewModel) {
        guard viewModel.canEvaluate,
              let weapon = viewModel.selectedAttackerWeapon,
              let defender = viewModel.selectedDefenderUnit,
              let save = defender.save else {
            evaluation = nil
            return
        }

        let plan = viewModel.attackerHitDicePlan
        hitDiceCount = max(1, plan?.fixedTotalHitDice ?? 1)
        saveTarget = save
        rend = weapon.rend
        let mods = CombatMatchupBuffCatalog.aggregateModifiers(
            from: viewModel.matchupBuffs,
            enabledIds: viewModel.enabledBuffIds
        )
        saveNeededOnDice = BatchCombatRollEngine.saveNeededOnDice(
            saveTarget: save,
            rend: weapon.rend,
            saveModifier: mods.save
        )
        wardTarget = mods.wardTarget
        mortalDamage = viewModel.resolvedRollOptions().mortalDamage

        if case .fixed(let value) = weapon.damageKind {
            damagePerWound = value
            usesVariableDamage = false
        } else {
            usesVariableDamage = true
            damagePerWound = viewModel.damage
        }

        clampCounts()
        evaluate()
    }

    func evaluate() {
        clampCounts()
        evaluation = BatchCombatRollEngine.evaluate(
            BatchCombatRollInput(
                successfulHits: successfulHits,
                successfulWounds: successfulWounds,
                failedSaves: failedSaves,
                damagePerWound: damagePerWound,
                wardNegatedCount: wardNegatedCount,
                mortalDamage: mortalDamage,
                manualTotalDamage: usesManualTotalDamage ? manualTotalDamage : nil
            )
        )
    }

    func resetCounts() {
        successfulHits = 0
        successfulWounds = 0
        failedSaves = 0
        wardNegatedCount = 0
        usesManualTotalDamage = false
        manualTotalDamage = 0
        evaluate()
    }

    private func clampCounts() {
        successfulHits = min(max(0, successfulHits), hitDiceCount)
        successfulWounds = min(max(0, successfulWounds), successfulHits)
        failedSaves = min(max(0, failedSaves), successfulWounds)
        wardNegatedCount = min(max(0, wardNegatedCount), failedSaves)
        manualTotalDamage = max(0, manualTotalDamage)
    }
}
