import SwiftUI
import TabletomeDomain

struct BattleTrackerArmyTrackerSection: View {
    let isVisible: Bool
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let unitWoundsRemaining: [String: Int]
    let healthPerModelOverrides: [String: Int]
    let activePlayerIsOne: Bool
    let usesWideLayout: Bool
    let usesCompactSidebar: Bool
    let gameSystemId: GameSystemId
    let calledReinforcementUnitKeys: Set<String>
    let onChange: (String, Int) -> Void
    let onSelectUnit: (String, String) -> Void

    var body: some View {
        if isVisible {
            ArmyTrackerCard(
                playerOneName: playerOneName,
                playerTwoName: playerTwoName,
                playerOneArmy: playerOneArmy,
                playerTwoArmy: playerTwoArmy,
                woundsRemaining: unitWoundsRemaining,
                healthPerModelOverrides: healthPerModelOverrides,
                activePlayerIsOne: activePlayerIsOne,
                usesWideLayout: usesWideLayout,
                usesCompactSidebar: usesCompactSidebar,
                gameSystemId: gameSystemId,
                calledReinforcementUnitKeys: calledReinforcementUnitKeys,
                onChange: onChange,
                onSelectUnit: onSelectUnit
            )
        }
    }
}
