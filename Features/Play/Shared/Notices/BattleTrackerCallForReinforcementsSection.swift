import SwiftUI
import TabletomeDomain

struct BattleTrackerCallForReinforcementsSection: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let calledUnitKeys: Set<String>
    let showsCallReminder: Bool
    let onReinforcementOnTableChanged: (String, String, Bool) -> Void

    var body: some View {
        CallForReinforcementsCard(
            playerOneName: playerOneName,
            playerTwoName: playerTwoName,
            playerOneArmy: playerOneArmy,
            playerTwoArmy: playerTwoArmy,
            calledUnitKeys: calledUnitKeys,
            showsCallReminder: showsCallReminder,
            onReinforcementOnTableChanged: onReinforcementOnTableChanged
        )
    }
}
