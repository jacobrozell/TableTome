import SwiftUI
import TabletomeDomain

struct BattleTrackerShootingPhaseHelperSection: View {
    let isVisible: Bool
    let units: [SpearheadUnit]
    let armyName: String
    let gameSystemId: GameSystemId
    let onSelectUnit: (String) -> Void

    var body: some View {
        if isVisible {
            ShootingEligibleUnitsCard(
                units: units,
                armyName: armyName,
                gameSystemId: gameSystemId,
                onSelectUnit: onSelectUnit
            )
        }
    }
}
