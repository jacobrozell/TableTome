import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    @ViewBuilder
    var unitFocusSheet: some View {
        if let selection = unitFocusSelection,
           let army = viewModel.army(withId: selection.armyId),
           let unit = army.units.first(where: { $0.id == selection.unitId }) {
            let woundKey = UnitWoundTracker.unitKey(armyId: army.id, unitId: unit.id)
            let capacity = viewModel.woundCapacity(for: army.id, unit: unit)
            let remaining = viewModel.trackerState.unitWoundsRemaining[woundKey] ?? capacity
            let catalogHealth = unit.health
            let effectiveHealth = viewModel.effectiveHealthPerModel(for: army.id, unit: unit)
            let hasOverride = viewModel.healthPerModelOverride(for: woundKey) != nil

            UnitFocusSheet(
                army: army,
                unit: unit,
                playerName: viewModel.playerName(forArmyId: army.id),
                woundsRemaining: remaining,
                woundCapacity: capacity,
                catalogHealthPerModel: catalogHealth,
                effectiveHealthPerModel: effectiveHealth,
                hasHealthOverride: hasOverride,
                isActivePlayerUnit: viewModel.isActivePlayerArmy(army.id),
                preferredWeaponId: selection.preferredWeaponId,
                onWoundsChange: { viewModel.setUnitWounds(key: woundKey, remaining: $0) },
                onSetHealthPerModelOverride: {
                    viewModel.setUnitHealthPerModelOverride(
                        armyId: army.id,
                        unit: unit,
                        healthPerModel: $0
                    )
                },
                onClearHealthOverride: {
                    viewModel.setUnitHealthPerModelOverride(
                        armyId: army.id,
                        unit: unit,
                        healthPerModel: nil
                    )
                },
                onResolveWeapon: { weaponId in
                    commitUnitFocusCombatPrefill(
                        armyId: selection.armyId,
                        unitId: selection.unitId,
                        preferredWeaponId: weaponId
                    )
                },
                onSetAsDefender: {
                    commitUnitFocusCombatPrefill(
                        armyId: selection.armyId,
                        unitId: selection.unitId,
                        preferredWeaponId: nil
                    )
                }
            )
        }
    }

    func presentUnitFocus(
        armyId: String,
        unitId: String,
        preferredWeaponId: String? = nil
    ) {
        rememberFocusedUnit(armyId: armyId, unitId: unitId, preferredWeaponId: preferredWeaponId)
        unitFocusSelection = UnitFocusSelection(
            armyId: armyId,
            unitId: unitId,
            preferredWeaponId: preferredWeaponId
        )
    }

    func commitUnitFocusCombatPrefill(
        armyId: String,
        unitId: String,
        preferredWeaponId: String?
    ) {
        applyArmyUnitCombatPrefill(
            armyId: armyId,
            unitId: unitId,
            preferredWeaponId: preferredWeaponId
        )
        unitFocusSelection = nil
        selectedSectionTab = .combat
    }
}
