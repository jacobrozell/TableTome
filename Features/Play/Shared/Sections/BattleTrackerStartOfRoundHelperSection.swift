import SwiftUI
import TabletomeDomain

struct BattleTrackerStartOfRoundHelperSection: View {
    let isVisible: Bool
    let abilities: [TriggeredAbility]

    var body: some View {
        if isVisible {
            StartOfRoundAbilitiesBanner(abilities: abilities)
        }
    }
}
