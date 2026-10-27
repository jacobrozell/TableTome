import SwiftUI
import TabletomeDomain

extension SpearheadBattleView {
    var showsSpearheadBattleChrome: Bool {
        viewModel.playContext.capabilities.showsBattleTacticDecks
    }

    var activePlayerProfile: PlayerProfile? {
        let selection = viewModel.trackerState.activePlayerIsOne
            ? viewModel.matchState.playerOne
            : viewModel.matchState.playerTwo
        guard let profileId = selection.profileId else { return nil }
        return householdProfiles.first { $0.id == profileId }
    }

    @ViewBuilder
    var battleTacticCommandGuideSection: some View {
        BattleTrackerBattleTacticCommandGuideSection(
            isVisible: showsSpearheadBattleChrome
                && PlayerCoachingPolicy.shouldShowTip(
                    tipKey: .battleTacticCommandGuide,
                    profile: activePlayerProfile,
                    globallyDismissed: NewPlayerTipsStore.hasDismissedBattleTacticCommandGuide
                ),
            currentPhase: viewModel.trackerState.currentPhase
        )
        .accessibilityIdentifier("spearheadBattle.battleTacticGuide")
    }

    func focusActivePlayerUnit(unitId: String, preferredWeaponId: String? = nil) {
        guard let armyId = viewModel.activeArmy?.id else { return }
        expandedUnitKey = UnitWoundTracker.unitKey(armyId: armyId, unitId: unitId)
        if let preferredWeaponId {
            handleSelectWeapon(armyId: armyId, unitId: unitId, weaponId: preferredWeaponId)
        }
    }
}
