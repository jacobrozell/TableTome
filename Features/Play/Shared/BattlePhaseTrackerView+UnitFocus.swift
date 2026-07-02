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
                gameSystemId: viewModel.gameSystemId,
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
                defenderUnit: combatViewModel.selectedDefenderUnit,
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
        guard ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId) else { return }
        applyArmyUnitCombatPrefill(
            armyId: armyId,
            unitId: unitId,
            preferredWeaponId: preferredWeaponId
        )
        unitFocusSelection = nil
        focusCombatResolverSection()
    }

    func presentMarketingUnitFocusIfNeeded() {
        let preferredNames = ["Rat Ogors", "Clanrats"]
        let armies = [viewModel.playerOneArmy, viewModel.playerTwoArmy].compactMap { $0 }
        for name in preferredNames {
            for army in armies {
                if let unit = army.units.first(where: { $0.name == name && $0.hasWarscroll }) {
                    presentUnitFocus(armyId: army.id, unitId: unit.id)
                    return
                }
            }
        }
        for army in armies {
            if let unit = army.units.first(where: { $0.hasWarscroll && !$0.weapons.isEmpty }) {
                presentUnitFocus(armyId: army.id, unitId: unit.id)
                return
            }
        }
    }
}

struct UnitFocusPresentationModifier<Presented: View>: ViewModifier {
    @Binding var selection: UnitFocusSelection?
    let usesFullScreen: Bool
    @ViewBuilder let presented: () -> Presented

    func body(content: Content) -> some View {
        if usesFullScreen {
            content.fullScreenCover(item: $selection) { _ in
                presented()
                    .presentationBackground(Color(.systemGroupedBackground))
            }
        } else {
            content.sheet(item: $selection) { _ in
                presented()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Color(.systemGroupedBackground))
            }
        }
    }
}

extension BattlePhaseTrackerView {
    /// Full-screen unit focus on iPhone — half-height sheets hid controls behind the tab bar.
    var usesUnitFocusFullScreenPresentation: Bool {
        !usesPadTabbedTwoColumnLayout
    }
}
