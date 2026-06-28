import SwiftUI
import TabletomeDomain

/// Maps chooser / onboarding rows to a distinct SF Symbol.
enum BoxProductThumbnailStyle: Equatable {
    case spearhead
    case combatPatrol
    case wh40kBattleforce
    case wh40kArmageddon
    case wh40kFull
    case starCraft

    init(gameSystemId: String, chooserIdentifier: String = "") {
        switch chooserIdentifier {
        case "home.chooser.wh40k11eArmageddon":
            self = .wh40kArmageddon
            return
        case "home.chooser.wh40k11eBattleforce":
            self = .wh40kBattleforce
            return
        case "home.chooser.wh40k11e":
            self = .wh40kFull
            return
        default:
            break
        }

        let context = GameSystemPlayContext.context(for: gameSystemId)
        if context.capabilities.showsBattleTacticDecks {
            self = .spearhead
        } else if context.capabilities.usesPatrolFormatRules {
            self = .combatPatrol
        } else if context.capabilities.showsActivationBar {
            self = .starCraft
        } else if context.capabilities.deploymentChecklistStyle == .wh40k {
            self = .wh40kArmageddon
        } else {
            self = .wh40kFull
        }
    }

    var systemImage: String {
        switch self {
        case .spearhead: "shield.lefthalf.filled"
        case .combatPatrol: "shield.checkered"
        case .wh40kBattleforce: "shippingbox"
        case .wh40kArmageddon: "shippingbox.fill"
        case .wh40kFull: "scope"
        case .starCraft: "gamecontroller.fill"
        }
    }
}

struct BoxProductThumbnail: View {
    let style: BoxProductThumbnailStyle
    var size: CGFloat = DesignTokens.minTouchTarget

    var body: some View {
        Image(systemName: style.systemImage)
            .font(.title2)
            .foregroundStyle(Color.accentOnSurface)
            .symbolRenderingMode(.hierarchical)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
