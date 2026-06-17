import Foundation
import TabletomeDomain

@MainActor
final class MultiAttackEvaluatorViewModel: ObservableObject {
    @Published var attackCount = 1
    @Published var currentAttackIndex = 0
    @Published var hitTarget = 4
    @Published var woundTarget = 4
    @Published var saveTarget = 4
    @Published var rend = 0
    @Published var damage = 1
    @Published var hitRoll = 4
    @Published var woundRoll = 4
    @Published var saveRoll = 4
    @Published var wardRoll = 4
    @Published var hitModifier = 0
    @Published var woundModifier = 0
    @Published var saveModifier = 0
    @Published var rollOptions = CombatRollOptions()
    @Published var enabledBuffIds: Set<String> = []
    @Published private(set) var results: [MultiAttackResult] = []
    @Published private(set) var lastEvaluation: AttackRollEvaluation?

    var totalDamage: Int { MultiAttackSequence.totalDamage(from: results) }
    var attacksRemaining: Int { max(0, attackCount - results.count) }
    var isSequenceComplete: Bool { results.count >= attackCount }

    func apply(weapon: SpearheadWeapon, saveTarget: Int, unitId: String) {
        hitTarget = weapon.hit
        woundTarget = weapon.wound
        rend = weapon.rend
        self.saveTarget = saveTarget
        if case .fixed(let value) = weapon.damageKind {
            damage = value
        }
        attackCount = weapon.fixedAttackCount ?? 1
        rollOptions = CombatRollOptions.from(weapon: weapon)
        enabledBuffIds = Set(weapon.weaponBuffs(unitId: unitId).map(\.id))
        resetSequence()
    }

    func evaluateCurrentAttack() {
        let options = resolvedRollOptions()
        let evaluation = CombatRollEngine.evaluate(
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
                wardTarget: nil,
                wardRoll: nil,
                critAutoWound: options.critAutoWound,
                critMortal: options.critMortal,
                mortalDamage: options.mortalDamage
            )
        )
        lastEvaluation = evaluation
        results.append(MultiAttackResult(id: results.count + 1, evaluation: evaluation))
        currentAttackIndex = results.count
    }

    func resetSequence() {
        results = []
        lastEvaluation = nil
        currentAttackIndex = 0
        hitRoll = 4
        woundRoll = 4
        saveRoll = 4
        wardRoll = 4
    }

    func resolvedRollOptions() -> CombatRollOptions {
        var options = rollOptions
        if let weapon = currentWeapon, let unitId = currentUnitId {
            for buff in weapon.weaponBuffs(unitId: unitId) where enabledBuffIds.contains(buff.id) {
                if buff.name.contains("Auto-wound") { options.critAutoWound = true }
                if buff.name.contains("Crit (Mortal)") { options.critMortal = true }
            }
        }
        return options
    }

    var currentWeapon: SpearheadWeapon?
    var currentUnitId: String?

    func bind(weapon: SpearheadWeapon?, unitId: String?) {
        currentWeapon = weapon
        currentUnitId = unitId
    }
}
