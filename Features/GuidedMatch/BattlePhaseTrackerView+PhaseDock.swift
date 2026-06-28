import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    var phaseDock: some View {
        BattleTrackerPhaseDock(
            mainPhases: viewModel.playContext.playEngine.mainPhases(),
            currentPhase: viewModel.trackerState.currentPhase,
            nextPhase: viewModel.playContext.playEngine.nextMainPhase(
                after: viewModel.trackerState.currentPhase
            ),
            myUnitLabel: focusedUnitDisplayName,
            myUnitEnabled: focusedUnitSelection != nil,
            victoryPointsSubtitle: victoryPointsDockSubtitle,
            scoreVictoryPointsEnabled: showsVictoryPointsOnTurnTab,
            compactLandscape: layoutContext.prefersCollapsedBattleChrome,
            onSelectPhase: { phase in
                viewModel.setPhase(phase)
                selectedSectionTab = .turn
                scrollToPhaseControls = true
            },
            onAdvancePhase: {
                viewModel.advancePhase()
                selectedSectionTab = .turn
                scrollToPhaseControls = true
            },
            onMyUnit: openFocusedUnit,
            onResolve: { focusCombatResolverSection() },
            onScoreVictoryPoints: {
                selectedSectionTab = .turn
                scrollToVictoryPoints = true
            },
            resolveAccessibilityHint: showsDedicatedCombatTab
                ? String(localized: "Opens the Combat tab with dice tools")
                : String(localized: "Opens combat dice tools on the Turn tab")
        )
    }

    var victoryPointsDockSubtitle: String {
        let playerOne = viewModel.trackerState.playerOneVictoryPoints
        let playerTwo = viewModel.trackerState.playerTwoVictoryPoints
        if playerOne == 0, playerTwo == 0 {
            return String(localized: "VP")
        }
        return "\(playerOne) · \(playerTwo)"
    }

    var focusedUnitDisplayName: String? {
        guard let selection = focusedUnitSelection,
              let army = viewModel.army(withId: selection.armyId),
              let unit = army.units.first(where: { $0.id == selection.unitId }) else {
            return nil
        }
        return unit.name
    }

    var focusedUnitSelection: UnitFocusSelection? {
        if let lastFocusedUnitSelection {
            return lastFocusedUnitSelection
        }
        return defaultFocusedUnitSelection()
    }

    func rememberFocusedUnit(armyId: String, unitId: String, preferredWeaponId: String? = nil) {
        lastFocusedUnitSelection = UnitFocusSelection(
            armyId: armyId,
            unitId: unitId,
            preferredWeaponId: preferredWeaponId
        )
    }

    func openFocusedUnit() {
        guard let selection = focusedUnitSelection else { return }
        presentUnitFocus(
            armyId: selection.armyId,
            unitId: selection.unitId,
            preferredWeaponId: selection.preferredWeaponId
        )
    }

    private func defaultFocusedUnitSelection() -> UnitFocusSelection? {
        guard let army = viewModel.activeArmy else { return nil }
        let aliveUnit = army.units.first { unit in
            guard unit.health != nil else { return false }
            let key = UnitWoundTracker.unitKey(armyId: army.id, unitId: unit.id)
            let capacity = viewModel.woundCapacity(for: army.id, unit: unit)
            let remaining = viewModel.trackerState.unitWoundsRemaining[key] ?? capacity
            return remaining > 0
        }
        guard let aliveUnit else { return nil }
        return UnitFocusSelection(armyId: army.id, unitId: aliveUnit.id)
    }
}
