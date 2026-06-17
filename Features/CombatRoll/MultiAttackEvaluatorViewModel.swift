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
    @Published var wardTarget: Int?
    @Published var rollOptions = CombatRollOptions()
    @Published var enabledBuffIds: Set<String> = []
    @Published private(set) var results: [MultiAttackResult] = []
    @Published private(set) var lastEvaluation: AttackRollEvaluation?
    @Published private(set) var lastRolls: [DiceRollResult] = []

    var hasFixedDamage: Bool { variableDamage == nil }
    var variableDamage: WeaponVariableDamage? {
        guard let weapon = currentWeapon else { return nil }
        if case .variable(let kind) = weapon.damageKind { return kind }
        return nil
    }

    var totalDamage: Int { MultiAttackSequence.totalDamage(from: results) }
    var attacksRemaining: Int { max(0, attackCount - results.count) }
    var isSequenceComplete: Bool { results.count >= attackCount }

    func apply(weapon: SpearheadWeapon, saveTarget: Int, unitId: String, wardTarget: Int? = nil) {
        hitTarget = weapon.hit
        woundTarget = weapon.wound
        rend = weapon.rend
        self.saveTarget = saveTarget
        self.wardTarget = wardTarget
        if case .fixed(let value) = weapon.damageKind {
            damage = value
        } else if case .variable(let kind) = weapon.damageKind {
            damage = kind == .d3 ? 2 : 3
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
                wardTarget: wardTarget,
                wardRoll: wardTarget == nil ? nil : wardRoll,
                critAutoWound: options.critAutoWound,
                critMortal: options.critMortal,
                mortalDamage: options.mortalDamage
            )
        )
        lastEvaluation = evaluation
        results.append(MultiAttackResult(id: results.count + 1, evaluation: evaluation))
        currentAttackIndex = results.count
    }

    func rollCurrentAttack() {
        lastRolls = []
        let result = CombatRollSimulator.rollAndEvaluate(
            parameters: SimulatedAttackRollSupport.rollParameters(from: self)
        )
        apply(result.rolls)
        result.rolls.rolls.forEach { SimulatedAttackRollSupport.announceRoll($0) }
        lastEvaluation = result.evaluation
        results.append(MultiAttackResult(id: results.count + 1, evaluation: result.evaluation))
        currentAttackIndex = results.count
    }

    func rollHit() {
        SimulatedAttackRollSupport.rollField(.hit, currentValue: &hitRoll, lastRolls: &lastRolls)
    }

    func rollWound() {
        SimulatedAttackRollSupport.rollField(.wound, currentValue: &woundRoll, lastRolls: &lastRolls)
    }

    func rollSave() {
        SimulatedAttackRollSupport.rollField(.save, currentValue: &saveRoll, lastRolls: &lastRolls)
    }

    func rollWard() {
        SimulatedAttackRollSupport.rollField(.ward, currentValue: &wardRoll, lastRolls: &lastRolls)
    }

    func clearSimulatedRolls() {
        lastRolls = []
    }

    func resetSequence() {
        results = []
        lastEvaluation = nil
        currentAttackIndex = 0
        hitRoll = 4
        woundRoll = 4
        saveRoll = 4
        wardRoll = 4
        lastRolls = []
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

    private func apply(_ simulated: SimulatedAttackRolls) {
        hitRoll = simulated.hitRoll
        woundRoll = simulated.woundRoll
        saveRoll = simulated.saveRoll
        damage = simulated.damage
        if let wardRoll = simulated.wardRoll {
            self.wardRoll = wardRoll
        }
        lastRolls = simulated.rolls
    }
}
