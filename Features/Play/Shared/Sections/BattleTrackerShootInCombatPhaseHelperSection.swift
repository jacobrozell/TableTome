import SwiftUI
import TabletomeDomain

struct BattleTrackerShootInCombatPhaseHelperSection: View {
    let isVisible: Bool
    let units: [SpearheadUnit]
    let onSelectUnit: (String, String) -> Void

    var body: some View {
        if isVisible {
            ShootInCombatEligibleUnitsCard(
                units: units,
                onSelectUnit: onSelectUnit
            )
        }
    }
}
