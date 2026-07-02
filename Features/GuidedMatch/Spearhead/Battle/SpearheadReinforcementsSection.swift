import SwiftUI
import TabletomeDomain

struct SpearheadReinforcementsSection: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let calledUnitKeys: Set<String>
    var showsCallReminder: Bool = false
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
