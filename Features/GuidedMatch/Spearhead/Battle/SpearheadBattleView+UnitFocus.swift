import SwiftUI
import TabletomeDomain

extension SpearheadBattleView {
    var usesUnitFocusFullScreenPresentation: Bool {
        !usesTwoColumnLayout
    }

    @ViewBuilder
    var unitFocusSheet: some View {
        if let selection = unitFocusSelection,
           let army = viewModel.army(withId: selection.armyId),
           let unit = army.units.first(where: { $0.id == selection.unitId }) {
            let woundKey = UnitWoundTracker.unitKey(armyId: army.id, unitId: unit.id)
            let capacity = viewModel.woundCapacity(for: army.id, unit: unit)
            let remaining = viewModel.trackerState.unitWoundsRemaining[woundKey] ?? capacity

            UnitFocusSheet(
                gameSystemId: viewModel.gameSystemId,
                army: army,
                unit: unit,
                playerName: viewModel.playerName(forArmyId: army.id),
                woundsRemaining: remaining,
                woundCapacity: capacity,
                catalogHealthPerModel: unit.health,
                effectiveHealthPerModel: viewModel.effectiveHealthPerModel(for: army.id, unit: unit),
                hasHealthOverride: viewModel.healthPerModelOverride(for: woundKey) != nil,
                isActivePlayerUnit: viewModel.isActivePlayerArmy(army.id),
                isPlayerOne: army.id == viewModel.playerOneArmy?.id,
                preferredWeaponId: selection.preferredWeaponId,
                defenderUnit: defenderUnit(for: selection),
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
                    commitUnitFocusCombat(
                        armyId: selection.armyId,
                        unitId: selection.unitId,
                        preferredWeaponId: weaponId
                    )
                },
                onSetAsDefender: {
                    assignCombatDefender(armyId: selection.armyId, unitId: selection.unitId)
                }
            )
        } else {
            UnitFocusUnavailableFallback {
                unitFocusSelection = nil
            }
        }
    }

    func presentUnitFocus(
        armyId: String,
        unitId: String,
        preferredWeaponId: String? = nil
    ) {
        unitFocusSelection = UnitFocusSelection(
            armyId: armyId,
            unitId: unitId,
            preferredWeaponId: preferredWeaponId
        )
    }

    func assignCombatDefender(armyId: String, unitId: String) {
        let defenderKey = "\(armyId):\(unitId)"
        seedCombatContextIfNeeded()
        if let current = resolverContext {
            resolverContext = InlineResolverContext(
                attackerKey: current.attackerKey,
                weaponId: current.weaponId,
                defenderKey: defenderKey
            )
        }
        unitFocusSelection = nil
        if usesNewBattleScreen, resolverContext != nil {
            showsCombatSheet = true
        }
    }

    func commitUnitFocusCombat(
        armyId: String,
        unitId: String,
        preferredWeaponId: String
    ) {
        guard ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId) else { return }
        unitFocusSelection = nil
        handleSelectWeapon(armyId: armyId, unitId: unitId, weaponId: preferredWeaponId)
    }

    private func defenderUnit(for selection: UnitFocusSelection) -> SpearheadUnit? {
        guard let defenderKey = resolverContext?.defenderKey,
              defenderKey != selection.id else { return nil }
        let parts = defenderKey.split(separator: ":")
        guard parts.count == 2 else { return nil }
        let armyId = String(parts[0])
        let unitId = String(parts[1])
        return viewModel.army(withId: armyId)?.units.first { $0.id == unitId }
    }
}

private struct UnitFocusUnavailableFallback: View {
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                String(localized: "Unit unavailable"),
                systemImage: "exclamationmark.triangle",
                description: Text(String(localized: "This unit could not be loaded. Try again from the unit list."))
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Done")) {
                        onDismiss()
                        dismiss()
                    }
                }
            }
        }
    }
}
