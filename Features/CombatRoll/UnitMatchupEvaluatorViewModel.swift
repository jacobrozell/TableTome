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
        selectedAttackerWeapon != nil && selectedDefenderUnit?.save != nil
    }

    var matchupTitle: String? {
        guard let attacker = selectedAttackerUnit, let defender = selectedDefenderUnit else { return nil }
        return "\(attacker.name) vs \(defender.name)"
    }

    var evaluateDamageButtonTitle: String {
        guard let title = matchupTitle else { return String(localized: "Evaluate Damage") }
        return String(localized: "Evaluate Damage: \(title)")
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
        selectedAttackerUnit?.weapons.filter { $0.numericRollProfile != nil } ?? []
    }

    var matchupBuffs: [CombatMatchupBuff] {
        CombatMatchupBuffCatalog.matchupBuffs(
            attacker: selectedAttackerUnit,
            defender: selectedDefenderUnit
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
        clearResults()
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
        clearResults()
    }

    func setAttackerUnit(_ unitId: String) {
        attackerUnitId = unitId
        selectDefaultAttackerWeapon()
        pruneDisabledBuffs()
        syncProfileFromSelection()
        clearResults()
    }

    func setDefenderUnit(_ unitId: String) {
        defenderUnitId = unitId
        pruneDisabledBuffs()
        syncProfileFromSelection()
        clearResults()
    }

    func setAttackerWeapon(_ weaponId: String) {
        attackerWeaponId = weaponId
        syncProfileFromSelection()
        clearResults()
    }

    func toggleBuff(_ buff: CombatMatchupBuff, enabled: Bool) {
        if enabled {
            enabledBuffIds.insert(buff.id)
        } else {
            enabledBuffIds.remove(buff.id)
        }
        clearResults()
    }

    func evaluate() {
        guard let weapon = selectedAttackerWeapon,
              let profile = weapon.numericRollProfile,
              let save = selectedDefenderUnit?.save else { return }

        let mods = CombatMatchupBuffCatalog.aggregateModifiers(from: matchupBuffs, enabledIds: enabledBuffIds)
        evaluation = CombatRollEngine.evaluate(
            AttackRollInput(
                hitTarget: profile.hit,
                woundTarget: profile.wound,
                saveTarget: save,
                rend: profile.rend,
                damage: damage,
                hitRoll: hitRoll,
                woundRoll: woundRoll,
                saveRoll: saveRoll,
                hitModifier: mods.hit,
                woundModifier: mods.wound,
                saveModifier: mods.save,
                wardTarget: mods.wardTarget,
                wardRoll: mods.wardTarget == nil ? nil : wardRoll
            )
        )
    }

    func clearResults() {
        evaluation = nil
    }

    func resetAll() {
        hitRoll = 4
        woundRoll = 4
        saveRoll = 4
        wardRoll = 4
        enabledBuffIds = []
        evaluation = nil
        applyInitialSelection()
        syncProfileFromSelection()
    }

    private func applyInitialSelection() {
        guard !armies.isEmpty else { return }

        if let attackerPrefill, armies.contains(where: { $0.id == attackerPrefill.armyId }) {
            attackerArmyId = attackerPrefill.armyId
            attackerUnitId = attackerPrefill.unitId
            attackerWeaponId = attackerPrefill.weaponId ?? ""
        } else {
            attackerArmyId = armies[0].id
            selectDefaultAttackerUnit()
        }

        if let defenderPrefill, armies.contains(where: { $0.id == defenderPrefill.armyId }) {
            defenderArmyId = defenderPrefill.armyId
            defenderUnitId = defenderPrefill.unitId
        } else {
            defenderArmyId = armies.first { $0.id != attackerArmyId }?.id ?? armies[0].id
            defenderUnitId = selectedDefenderArmy?.units.first?.id ?? ""
        }

        selectDefaultAttackerWeapon()
        pruneDisabledBuffs()
        syncProfileFromSelection()
    }

    private func selectDefaultAttackerUnit() {
        attackerUnitId = selectedAttackerArmy?.units.first?.id ?? ""
        selectDefaultAttackerWeapon()
    }

    private func selectDefaultAttackerWeapon() {
        attackerWeaponId = evaluableWeapons.first?.id ?? ""
    }

    private func syncProfileFromSelection() {
        if let profile = selectedAttackerWeapon?.numericRollProfile {
            damage = profile.damage
        }
    }

    private func pruneDisabledBuffs() {
        let validIds = Set(matchupBuffs.map(\.id))
        enabledBuffIds = enabledBuffIds.intersection(validIds)
    }
}
