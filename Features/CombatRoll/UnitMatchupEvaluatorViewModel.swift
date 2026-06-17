import Foundation
import TabletomeDomain

@MainActor
final class UnitMatchupEvaluatorViewModel: ObservableObject {
    @Published private(set) var armies: [SpearheadArmy] = []
    @Published private(set) var errorMessage: String?
    @Published var attackerArmyId = ""
    @Published var attackerUnitId = ""
    @Published var attackerWeaponId = ""
    @Published var defenderArmyId = ""
    @Published var defenderUnitId = ""
    @Published var enabledBuffIds: Set<String> = []
    @Published var damage = 1
    @Published var hitRoll = 4
    @Published var woundRoll = 4
    @Published var saveRoll = 4
    @Published var wardRoll = 4
    @Published var rollOptions = CombatRollOptions()
    @Published private(set) var lastRolls: [DiceRollResult] = []
    @Published private(set) var evaluation: AttackRollEvaluation?

    private let catalogRepository: any SpearheadCatalogRepository
    private let attackerPrefill: MatchupUnitPrefill?
    private let defenderPrefill: MatchupUnitPrefill?

    init(
        catalogRepository: any SpearheadCatalogRepository,
        attackerPrefill: MatchupUnitPrefill? = nil,
        defenderPrefill: MatchupUnitPrefill? = nil
    ) {
        self.catalogRepository = catalogRepository
        self.attackerPrefill = attackerPrefill
        self.defenderPrefill = defenderPrefill
    }

    var canEvaluate: Bool {
        selectedAttackerWeapon?.isRollEvaluable == true && selectedDefenderUnit?.save != nil
    }

    var matchupTitle: String? {
        guard let attacker = selectedAttackerUnit, let defender = selectedDefenderUnit else { return nil }
        return "\(attacker.name) vs \(defender.name)"
    }

    var evaluateDamageButtonTitle: String {
        guard let title = matchupTitle else { return String(localized: "Evaluate Damage") }
        return "Evaluate Damage: \(title)"
    }

    var selectedAttackerArmy: SpearheadArmy? {
        armies.first { $0.id == attackerArmyId }
    }

    var selectedDefenderArmy: SpearheadArmy? {
        armies.first { $0.id == defenderArmyId }
    }

    var selectedAttackerUnit: SpearheadUnit? {
        selectedAttackerArmy?.units.first { $0.id == attackerUnitId }
    }

    var selectedDefenderUnit: SpearheadUnit? {
        selectedDefenderArmy?.units.first { $0.id == defenderUnitId }
    }

    var selectedAttackerWeapon: SpearheadWeapon? {
        guard let unit = selectedAttackerUnit else { return nil }
        if attackerWeaponId.isEmpty {
            return unit.weapons.first { $0.numericRollProfile != nil }
        }
        return unit.weapons.first { $0.id == attackerWeaponId }
    }

    var evaluableWeapons: [SpearheadWeapon] {
        selectedAttackerUnit?.weapons.filter(\.isRollEvaluable) ?? []
    }

    var matchupBuffs: [CombatMatchupBuff] {
        CombatMatchupBuffCatalog.matchupBuffs(
            attacker: selectedAttackerUnit,
            defender: selectedDefenderUnit,
            weapon: selectedAttackerWeapon
        )
    }

    var attackerBuffs: [CombatMatchupBuff] {
        matchupBuffs.filter { $0.side == .attacker }
    }

    var defenderBuffs: [CombatMatchupBuff] {
        matchupBuffs.filter { $0.side == .defender }
    }

    var activeWardTarget: Int? {
        CombatMatchupBuffCatalog.aggregateModifiers(from: matchupBuffs, enabledIds: enabledBuffIds).wardTarget
    }

    func load() async {
        do {
            let catalog = try await catalogRepository.loadCatalog()
            armies = catalog.factions
                .flatMap(\.armies)
                .filter { SpearheadFeaturedArmies.isFeatured($0.id) }
                .sorted { $0.name < $1.name }
            applyInitialSelection()
            errorMessage = nil
        } catch {
            errorMessage = String(localized: "Spearhead armies could not be loaded.")
        }
    }

    func setAttackerArmy(_ armyId: String) {
        attackerArmyId = armyId
        if defenderArmyId == armyId {
            defenderArmyId = armies.first { $0.id != armyId }?.id ?? ""
            defenderUnitId = selectedDefenderArmy?.units.first?.id ?? ""
        }
        selectDefaultAttackerUnit()
        syncProfileFromSelection()
        refreshEvaluation()
    }

    func setDefenderArmy(_ armyId: String) {
        defenderArmyId = armyId
        if attackerArmyId == armyId {
            attackerArmyId = armies.first { $0.id != armyId }?.id ?? ""
            selectDefaultAttackerUnit()
        }
        defenderUnitId = selectedDefenderArmy?.units.first?.id ?? ""
        pruneDisabledBuffs()
        syncProfileFromSelection()
        refreshEvaluation()
    }

    func setAttackerUnit(_ unitId: String) {
        attackerUnitId = unitId
        selectDefaultAttackerWeapon()
        pruneDisabledBuffs()
        syncProfileFromSelection()
        refreshEvaluation()
    }

    func setDefenderUnit(_ unitId: String) {
        defenderUnitId = unitId
        pruneDisabledBuffs()
        syncProfileFromSelection()
        refreshEvaluation()
    }

    func setAttackerWeapon(_ weaponId: String) {
        attackerWeaponId = weaponId
        syncProfileFromSelection()
        refreshEvaluation()
    }

    func toggleBuff(_ buff: CombatMatchupBuff, enabled: Bool) {
        if enabled {
            enabledBuffIds.insert(buff.id)
        } else {
            enabledBuffIds.remove(buff.id)
        }
        refreshEvaluation()
    }

    func syncBattleContext(
        activePlayerIsOne: Bool,
        playerOneArmyId: String?,
        playerTwoArmyId: String?
    ) {
        guard let playerOneArmyId, let playerTwoArmyId,
              armies.contains(where: { $0.id == playerOneArmyId }),
              armies.contains(where: { $0.id == playerTwoArmyId }) else { return }

        let attackerArmy = activePlayerIsOne ? playerOneArmyId : playerTwoArmyId
        let defenderArmy = activePlayerIsOne ? playerTwoArmyId : playerOneArmyId

        if attackerArmyId != attackerArmy {
            setAttackerArmy(attackerArmy)
        }
        if defenderArmyId != defenderArmy {
            setDefenderArmy(defenderArmy)
        }
    }

    func evaluate() {
        guard let weapon = selectedAttackerWeapon,
              let save = selectedDefenderUnit?.save else {
            evaluation = nil
            return
        }

        let mods = CombatMatchupBuffCatalog.aggregateModifiers(from: matchupBuffs, enabledIds: enabledBuffIds)
        let options = resolvedRollOptions()
        evaluation = CombatRollEngine.evaluate(
            AttackRollInput(
                hitTarget: weapon.hit,
                woundTarget: weapon.wound,
                saveTarget: save,
                rend: weapon.rend,
                damage: damage,
                hitRoll: hitRoll,
                woundRoll: woundRoll,
                saveRoll: saveRoll,
                hitModifier: mods.hit,
                woundModifier: mods.wound,
                saveModifier: mods.save,
                wardTarget: mods.wardTarget,
                wardRoll: mods.wardTarget == nil ? nil : wardRoll,
                critAutoWound: options.critAutoWound,
                critMortal: options.critMortal,
                mortalDamage: options.mortalDamage
            )
        )
    }

    func refreshEvaluation() {
        guard canEvaluate else {
            evaluation = nil
            return
        }
        evaluate()
    }

    func rollAttack() {
        guard let parameters = SimulatedAttackRollSupport.rollParameters(from: self) else { return }
        clearResults()
        let result = CombatRollSimulator.rollAndEvaluate(parameters: parameters)
        apply(result.rolls)
        result.rolls.rolls.forEach { SimulatedAttackRollSupport.announceRoll($0) }
        evaluation = result.evaluation
    }

    func rollHit() {
        SimulatedAttackRollSupport.rollField(.hit, currentValue: &hitRoll, lastRolls: &lastRolls)
        refreshEvaluation()
    }

    func rollWound() {
        SimulatedAttackRollSupport.rollField(.wound, currentValue: &woundRoll, lastRolls: &lastRolls)
        refreshEvaluation()
    }

    func rollSave() {
        SimulatedAttackRollSupport.rollField(.save, currentValue: &saveRoll, lastRolls: &lastRolls)
        refreshEvaluation()
    }

    func rollWard() {
        SimulatedAttackRollSupport.rollField(.ward, currentValue: &wardRoll, lastRolls: &lastRolls)
        refreshEvaluation()
    }

    func clearResults() {
        evaluation = nil
    }

    func clearSimulatedRolls() {
        lastRolls = []
        clearResults()
    }

    func resetAll() {
        hitRoll = 4
        woundRoll = 4
        saveRoll = 4
        wardRoll = 4
        rollOptions = CombatRollOptions()
        enabledBuffIds = []
        lastRolls = []
        evaluation = nil
        applyInitialSelection()
        syncProfileFromSelection()
    }

    func resolvedRollOptions() -> CombatRollOptions {
        var options = rollOptions
        guard let weapon = selectedAttackerWeapon, let unit = selectedAttackerUnit else { return options }
        for buff in weapon.weaponBuffs(unitId: unit.id) where enabledBuffIds.contains(buff.id) {
            if buff.name.contains("Auto-wound") { options.critAutoWound = true }
            if buff.name.contains("Crit (Mortal)") { options.critMortal = true }
        }
        return options
    }

    private func applyInitialSelection() {
        guard !armies.isEmpty else { return }

        if let attackerPrefill, armies.contains(where: { $0.id == attackerPrefill.armyId }) {
            attackerArmyId = attackerPrefill.armyId
            if attackerPrefill.unitId.isEmpty {
                attackerUnitId = armies.first { $0.id == attackerPrefill.armyId }?.units.first?.id ?? ""
            } else {
                attackerUnitId = attackerPrefill.unitId
            }
            attackerWeaponId = attackerPrefill.weaponId ?? ""
        } else {
            attackerArmyId = armies[0].id
            selectDefaultAttackerUnit()
        }

        if let defenderPrefill, armies.contains(where: { $0.id == defenderPrefill.armyId }) {
            defenderArmyId = defenderPrefill.armyId
            if defenderPrefill.unitId.isEmpty {
                defenderUnitId = armies.first { $0.id == defenderPrefill.armyId }?.units.first?.id ?? ""
            } else {
                defenderUnitId = defenderPrefill.unitId
            }
        } else {
            defenderArmyId = armies.first { $0.id != attackerArmyId }?.id ?? armies[0].id
            defenderUnitId = selectedDefenderArmy?.units.first?.id ?? ""
        }

        selectDefaultAttackerWeapon()
        pruneDisabledBuffs()
        syncProfileFromSelection()
        refreshEvaluation()
    }

    private func selectDefaultAttackerUnit() {
        attackerUnitId = selectedAttackerArmy?.units.first?.id ?? ""
        selectDefaultAttackerWeapon()
    }

    private func selectDefaultAttackerWeapon() {
        attackerWeaponId = evaluableWeapons.first?.id ?? ""
    }

    private func syncProfileFromSelection() {
        guard let weapon = selectedAttackerWeapon else { return }
        if case .fixed(let value) = weapon.damageKind {
            damage = value
        } else if case .variable(let kind) = weapon.damageKind {
            damage = kind == .d3 ? 2 : 3
        }
        rollOptions = CombatRollOptions.from(weapon: weapon)
        if let unit = selectedAttackerUnit {
            enabledBuffIds.formUnion(weapon.weaponBuffs(unitId: unit.id).map(\.id))
        }
    }

    private func pruneDisabledBuffs() {
        let validIds = Set(matchupBuffs.map(\.id))
        enabledBuffIds = enabledBuffIds.intersection(validIds)
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
