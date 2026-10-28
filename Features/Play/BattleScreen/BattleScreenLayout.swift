import SwiftUI

/// Five-slot battle frame: scoreboard, phase rail, now panel, action bar, and an iPad side panel.
struct BattleScreenLayout<Scoreboard: View, PhaseRail: View, Content: View, ActionBar: View, SidePanel: View>: View {
    let layoutContext: TabletomeLayoutContext
    var dynamicTypeSize: DynamicTypeSize
    @ViewBuilder var scoreboard: () -> Scoreboard
    @ViewBuilder var phaseRail: () -> PhaseRail
    @ViewBuilder var content: () -> Content
    @ViewBuilder var actionBar: () -> ActionBar
    @ViewBuilder var sidePanel: () -> SidePanel

    var body: some View {
        switch layoutContext {
        case .phoneLandscape where !dynamicTypeSize.needsLayoutAdaptation:
            landscape
        case .padPortrait, .padLandscape where !dynamicTypeSize.needsLayoutAdaptation:
            pad
        default:
            portrait
        }
    }

    private var portrait: some View {
        VStack(spacing: 0) {
            scoreboard()
            phaseRail()
            ScrollView {
                content()
                    .padding(DesignTokens.Spacing.md)
                    .readableContentWidth()
            }
            actionBar()
        }
    }

    private var landscape: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                scoreboard()
                phaseRail()
                Spacer(minLength: 0)
                actionBar()
            }
            .containerRelativeFrame(.horizontal) { width, _ in max(280, width * 0.42) }
            ScrollView {
                content()
                    .padding(DesignTokens.phoneLandscapeHorizontalPadding)
            }
        }
    }

    private var pad: some View {
        VStack(spacing: 0) {
            scoreboard()
            phaseRail()
                .frame(maxWidth: 720)
            HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                VStack(spacing: 0) {
                    ScrollView {
                        content()
                            .padding(DesignTokens.Spacing.md)
                    }
                    actionBar()
                }
                .frame(maxWidth: 480)
                ScrollView {
                    sidePanel()
                        .padding(DesignTokens.Spacing.md)
                }
            }
        }
    }
}
