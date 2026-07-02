import SwiftUI
import TabletomeDomain

struct BattleTrackerBattleTacticCommandGuideSection: View {
    let isVisible: Bool
    let currentPhase: BattleTurnPhase

    var body: some View {
        if isVisible, isMidTurnPhase {
            BattleTacticCommandGuideCard()
        }
    }

    private var isMidTurnPhase: Bool {
        switch currentPhase {
        case .hero, .movement, .shooting, .charge, .combat, .anyCombat:
            true
        default:
            false
        }
    }
}
