import SwiftUI
import TabletomeDomain

extension SpearheadBattleView {
    @ViewBuilder
    var phaseHelpers: some View {
        if viewModel.trackerState.currentPhase == .movement {
            movementPhaseHelpers
        } else if viewModel.trackerState.currentPhase == .shooting {
            shootingPhaseHelpers
        } else if isCombatPhase {
            combatPhaseHelpers
        }
    }

    private var isCombatPhase: Bool {
        viewModel.trackerState.currentPhase == .combat
            || viewModel.trackerState.currentPhase == .anyCombat
    }

    @ViewBuilder
    private var movementPhaseHelpers: some View {
        MovementRangeCard(
            playerName: viewModel.activePlayerName,
            army: viewModel.activeArmy,
            woundsRemaining: viewModel.trackerState.unitWoundsRemaining,
            armyId: viewModel.activeArmy?.id
        )
        MovementActionPicker(
            action: $movementAction,
            gameSystemId: viewModel.gameSystemId.rawValue
        )
        .accessibilityIdentifier("spearheadBattle.movementAction")
    }

    @ViewBuilder
    private var shootingPhaseHelpers: some View {
        if ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId),
           !viewModel.shootingEligibleUnits.isEmpty {
            ShootingEligibleUnitsCard(
                units: viewModel.shootingEligibleUnits,
                armyName: viewModel.activeArmy?.name ?? viewModel.activePlayerName,
                gameSystemId: viewModel.gameSystemId,
                onSelectUnit: { unitId in
                    focusActivePlayerUnit(unitId: unitId)
                }
            )
            .accessibilityIdentifier("spearheadBattle.shootingEligible")
        }
    }

    @ViewBuilder
    private var combatPhaseHelpers: some View {
        if ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId),
           !viewModel.shootInCombatEligibleUnits.isEmpty {
            ShootInCombatEligibleUnitsCard(
                units: viewModel.shootInCombatEligibleUnits,
                onSelectUnit: { unitId, weaponId in
                    focusActivePlayerUnit(unitId: unitId, preferredWeaponId: weaponId)
                }
            )
            .accessibilityIdentifier("spearheadBattle.shootInCombatEligible")
        }

        if showsPileInGuide {
            PileInGuideCard()
                .accessibilityIdentifier("spearheadBattle.pileInGuide")
        }
    }

    private var showsPileInGuide: Bool {
        PlayerCoachingPolicy.shouldShowTip(
            tipKey: .pileInGuide,
            profile: activePlayerProfile,
            globallyDismissed: NewPlayerTipsStore.hasDismissedPileInGuide
        )
    }
}
