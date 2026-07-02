import SwiftUI
import TabletomeDomain

/// Spearhead-owned Guided Match hub surfaces (§15) — wraps shared shell sections.
enum SpearheadGuidedMatchContent {
    @ViewBuilder
    static func armiesTab<Matchup: View, Players: View>(
        showsArmyPicker: Bool,
        @ViewBuilder matchup: () -> Matchup,
        @ViewBuilder players: () -> Players
    ) -> some View {
        if showsArmyPicker {
            matchup()
            players()
        }
    }

    @ViewBuilder
    static func setupTab<SampleTurn: View, Progress: View, Roll: View, Loadout: View, Continue: View, Handoff: View, Steps: View>(
        @ViewBuilder sampleTurn: () -> SampleTurn,
        @ViewBuilder setupProgress: () -> Progress,
        @ViewBuilder rollPrompt: () -> Roll,
        @ViewBuilder preBattleLoadout: () -> Loadout,
        @ViewBuilder continueSetup: () -> Continue,
        @ViewBuilder setupCompleteHandoff: () -> Handoff,
        @ViewBuilder matchSteps: () -> Steps,
        usesCompactSetupLayout: Bool
    ) -> some View {
        if !usesCompactSetupLayout {
            sampleTurn()
        }
        setupProgress()
        rollPrompt()
        preBattleLoadout()
        continueSetup()
        setupCompleteHandoff()
        matchSteps()
    }

    /// Phone Battle hub tab — battle tracker when setup complete, gate otherwise.
    @ViewBuilder
    static func battleTab<Ready: View, Gate: View>(
        setupComplete: Bool,
        @ViewBuilder whenReady: () -> Ready,
        @ViewBuilder whenIncomplete: () -> Gate
    ) -> some View {
        if setupComplete {
            whenReady()
        } else {
            whenIncomplete()
        }
    }

    /// iPad sidebar + expanded phone list — full setup flow in document order (§15).
    // swiftlint:disable function_parameter_count
    @ViewBuilder
    static func sidebarFlow<
        Matchup: View,
        Players: View,
        StarterHandoff: View,
        Progress: View,
        Roll: View,
        Loadout: View,
        Continue: View,
        Handoff: View,
        Battle: View,
        SampleTurn: View,
        Steps: View
    >(
        showsArmyPicker: Bool,
        usesCompactSetupLayout: Bool,
        @ViewBuilder matchup: () -> Matchup,
        @ViewBuilder players: () -> Players,
        @ViewBuilder starterHandoff: () -> StarterHandoff,
        @ViewBuilder setupProgress: () -> Progress,
        @ViewBuilder rollPrompt: () -> Roll,
        @ViewBuilder preBattleLoadout: () -> Loadout,
        @ViewBuilder continueSetup: () -> Continue,
        @ViewBuilder setupCompleteHandoff: () -> Handoff,
        @ViewBuilder battleTracker: () -> Battle,
        @ViewBuilder sampleTurn: () -> SampleTurn,
        @ViewBuilder matchSteps: () -> Steps
    ) -> some View {
        if showsArmyPicker {
            matchup()
            players()
        }
        starterHandoff()
        setupProgress()
        rollPrompt()
        preBattleLoadout()
        continueSetup()
        setupCompleteHandoff()
        battleTracker()
        if usesCompactSetupLayout {
            sampleTurn()
        }
        matchSteps()
    }
    // swiftlint:enable function_parameter_count
}
