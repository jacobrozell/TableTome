import SwiftUI
import TabletomeDomain

struct BattleTrackerMovementPhaseHelperSection: View {
    let isMovementPhase: Bool
    let showsSpearheadBattleChrome: Bool
    let activePlayerName: String
    let activeArmy: SpearheadArmy?
    let unitWoundsRemaining: [String: Int]
    let gameSystemId: GameSystemId
    @Binding var movementAction: MovementAction
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let calledUnitKeys: Set<String>
    let showsCallReminder: Bool
    let onReinforcementOnTableChanged: (String, String, Bool) -> Void

    var body: some View {
        if isMovementPhase {
            if showsSpearheadBattleChrome {
                BattleTrackerCallForReinforcementsSection(
                    playerOneName: playerOneName,
                    playerTwoName: playerTwoName,
                    playerOneArmy: playerOneArmy,
                    playerTwoArmy: playerTwoArmy,
                    calledUnitKeys: calledUnitKeys,
                    showsCallReminder: showsCallReminder,
                    onReinforcementOnTableChanged: onReinforcementOnTableChanged
                )
            }
            MovementRangeCard(
                playerName: activePlayerName,
                army: activeArmy,
                woundsRemaining: unitWoundsRemaining,
                armyId: activeArmy?.id
            )
            if showsSpearheadBattleChrome {
                MovementActionPicker(
                    action: $movementAction,
                    gameSystemId: gameSystemId.rawValue
                )
            }
        }
    }
}

struct BattleTrackerCombatPhaseHelperSection: View {
    let isVisible: Bool

    var body: some View {
        if isVisible {
            PileInGuideCard()
        }
    }
}
