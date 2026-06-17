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
    @Published var variableDamage: WeaponVariableDamage?
    @Published private(set) var lastRolls: [DiceRollResult] = []
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

    func rollAttack() {
        clearResults()
        let result = CombatRollSimulator.rollAndEvaluate(
            parameters: SimulatedAttackRollSupport.rollParameters(from: self)
        )
        apply(result.rolls)
        announceRolls(result.rolls.rolls)
        evaluation = result.evaluation
    }

    func rollHit() {
        SimulatedAttackRollSupport.rollField(.hit, currentValue: &hitRoll, lastRolls: &lastRolls)
        clearResults()
    }

    func rollWound() {
        SimulatedAttackRollSupport.rollField(.wound, currentValue: &woundRoll, lastRolls: &lastRolls)
        clearResults()
    }

    func rollSave() {
        SimulatedAttackRollSupport.rollField(.save, currentValue: &saveRoll, lastRolls: &lastRolls)
        clearResults()
    }

    func clearResults() {
        evaluation = nil
    }

    func clearSimulatedRolls() {
        lastRolls = []
        clearResults()
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
        variableDamage = nil
        lastRolls = []
        evaluation = nil
    }

    func apply(weapon: SpearheadWeapon, defaultSave: Int = 4) {
        hitTarget = weapon.hit
        woundTarget = weapon.wound
        rend = weapon.rend
        saveTarget = defaultSave
        switch weapon.damageKind {
        case .fixed(let value):
            damage = value
            variableDamage = nil
        case .variable(let kind):
            variableDamage = kind
            damage = kind == .d3 ? 2 : 3
        case nil:
            break
        }
        rollOptions = CombatRollOptions.from(weapon: weapon)
        lastRolls = []
        evaluation = nil
    }

    private func announceRolls(_ rolls: [DiceRollResult]) {
        rolls.forEach { SimulatedAttackRollSupport.announceRoll($0) }
    }

    private func apply(_ simulated: SimulatedAttackRolls) {
        hitRoll = simulated.hitRoll
        woundRoll = simulated.woundRoll
        saveRoll = simulated.saveRoll
        damage = simulated.damage
        lastRolls = simulated.rolls
    }
}
