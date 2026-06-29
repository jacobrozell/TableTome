import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    /// Scopes acted-unit tracking to the current round, active player, and phase so the
    /// list resets itself whenever any of those change.
    var phaseActivationKey: String {
        "\(trackerState.battleRound)-\(trackerState.activePlayerIsOne)-\(trackerState.currentPhase.rawValue)"
    }

    /// Whether the current phase is one where unit-by-unit attack tracking is useful.
    var showsCombatActivationTracker: Bool {
        guard ReleaseSurface.showsCombatResolver(for: gameSystemId) else { return false }
        guard !playContext.capabilities.showsActivationBar else { return false }
        return !combatActivationUnits.isEmpty
    }

    /// The active player's units that can attack in the current phase.
    var combatActivationUnits: [SpearheadUnit] {
        guard let army = activeArmy else { return [] }
        let units: [SpearheadUnit]
        switch trackerState.currentPhase {
        case .shooting:
            units = army.units.filter(\.canShoot)
        case .combat, .anyCombat, .assault:
            units = army.units.filter { $0.canFight || $0.canShoot }
        default:
            return []
        }
        return units.filter { !unitIsDestroyed(armyId: army.id, unit: $0) }
    }

    /// Phase-relevant weapon names so a shooting unit doesn't list its melee weapon (and vice versa).
    func activationWeaponNames(for unit: SpearheadUnit) -> String {
        let weapons: [SpearheadWeapon]
        switch trackerState.currentPhase {
        case .shooting:
            weapons = unit.shootingWeapons
        case .combat, .anyCombat, .assault:
            let shootInCombat = unit.weapons.filter { $0.hasShootInCombat && $0.isRanged }
            weapons = unit.meleeWeapons + shootInCombat
        default:
            weapons = unit.weapons
        }
        return weapons.map(\.name).joined(separator: ", ")
    }

    func unitHasActed(unitId: String) -> Bool {
        guard let armyId = activeArmy?.id else { return false }
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unitId)
        return trackerState.unitsActedThisPhase[phaseActivationKey]?.contains(key) ?? false
    }

    func setUnitActed(armyId: String, unitId: String, acted: Bool) {
        let phaseKey = phaseActivationKey
        let unitKey = UnitWoundTracker.unitKey(armyId: armyId, unitId: unitId)
        var acting = trackerState.unitsActedThisPhase[phaseKey] ?? []
        if acted {
            guard !acting.contains(unitKey) else { return }
            acting.insert(unitKey)
        } else {
            guard acting.contains(unitKey) else { return }
            acting.remove(unitKey)
        }
        trackerState.unitsActedThisPhase[phaseKey] = acting
        persist()
    }

    func toggleUnitActed(unitId: String) {
        guard let armyId = activeArmy?.id else { return }
        setUnitActed(armyId: armyId, unitId: unitId, acted: !unitHasActed(unitId: unitId))
    }

    /// Marks the active player's attacker as having fought once damage is resolved.
    func markActiveAttackerActed(armyId: String, unitId: String) {
        guard isActivePlayerArmy(armyId) else { return }
        guard combatActivationUnits.contains(where: { $0.id == unitId }) else { return }
        setUnitActed(armyId: armyId, unitId: unitId, acted: true)
    }

    var combatActivationDoneCount: Int {
        combatActivationUnits.filter { unitHasActed(unitId: $0.id) }.count
    }

    private func unitIsDestroyed(armyId: String, unit: SpearheadUnit) -> Bool {
        guard unit.health != nil else { return false }
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unit.id)
        guard let remaining = trackerState.unitWoundsRemaining[key] else { return false }
        return remaining <= 0
    }
}
