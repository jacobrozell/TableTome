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
    @Published var rollOptions = CombatRollOptions()
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
                saveModifier: saveModifier,
                critAutoWound: rollOptions.critAutoWound,
                critMortal: rollOptions.critMortal,
                mortalDamage: rollOptions.mortalDamage
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
        rollOptions = CombatRollOptions()
        evaluation = nil
    }

    func apply(weapon: SpearheadWeapon, defaultSave: Int = 4) {
        hitTarget = weapon.hit
        woundTarget = weapon.wound
        rend = weapon.rend
        saveTarget = defaultSave
        if case .fixed(let value) = weapon.damageKind {
            damage = value
        }
        rollOptions = CombatRollOptions.from(weapon: weapon)
        evaluation = nil
    }
}
