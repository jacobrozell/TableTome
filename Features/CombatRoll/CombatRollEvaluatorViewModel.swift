import Foundation
import TabletomeDomain

@MainActor
final class CombatRollEvaluatorViewModel: ObservableObject {
    @Published var hitTarget = 4
    @Published var woundTarget = 4
    @Published var saveTarget = 4
    @Published var rend = 0
    @Published var damage = 1
    @Published var hitRoll = 4
    @Published var woundRoll = 4
    @Published var saveRoll = 4
    @Published var hitModifier = 0
    @Published var woundModifier = 0
    @Published var saveModifier = 0
    @Published private(set) var evaluation: AttackRollEvaluation?

    func evaluate() {
        evaluation = CombatRollEngine.evaluate(
            AttackRollInput(
                hitTarget: hitTarget,
                woundTarget: woundTarget,
                saveTarget: saveTarget,
                rend: rend,
                damage: damage,
                hitRoll: hitRoll,
                woundRoll: woundRoll,
                saveRoll: saveRoll,
                hitModifier: hitModifier,
                woundModifier: woundModifier,
                saveModifier: saveModifier
            )
        )
    }

    func clearResults() {
        evaluation = nil
    }

    func resetAll() {
        hitTarget = 4
        woundTarget = 4
        saveTarget = 4
        rend = 0
        damage = 1
        hitRoll = 4
        woundRoll = 4
        saveRoll = 4
        hitModifier = 0
        woundModifier = 0
        saveModifier = 0
        evaluation = nil
    }

    func apply(weapon: SpearheadWeapon, defaultSave: Int = 4) {
        guard let profile = weapon.numericRollProfile else { return }
        hitTarget = profile.hit
        woundTarget = profile.wound
        rend = profile.rend
        damage = profile.damage
        saveTarget = defaultSave
        evaluation = nil
    }
}
