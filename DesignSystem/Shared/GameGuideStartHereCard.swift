import SwiftUI
import TabletomeDomain

/// Capability-routed "Start here" card for game guides — replaces per-system entry views.
struct GameGuideStartHereCard: View {
    let gameSystem: GameSystem

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystem.id)
    }

    var body: some View {
        Group {
            if playContext.capabilities.showsBattleTacticDecks {
                NewPlayerStartHereCard()
            } else if playContext.capabilities.deploymentChecklistStyle == .wh40k {
                FortyKStartHereCard(gameSystem: gameSystem)
            } else if playContext.capabilities.usesPatrolFormatRules {
                CombatPatrolStartHereCard(gameSystem: gameSystem)
            } else if playContext.capabilities.showsActivationBar {
                ScStartHereCard(gameSystem: gameSystem)
            }
        }
    }
}

/// Capability-routed "What you need" card for game guides.
struct GameGuideWhatYouNeedCard: View {
    let gameSystemId: String

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    var body: some View {
        Group {
            if playContext.capabilities.showsBattleTacticDecks {
                WhatYouNeedCard()
            } else if playContext.capabilities.deploymentChecklistStyle == .wh40k {
                Wh40k11eWhatYouNeedCard()
            }
        }
    }
}
