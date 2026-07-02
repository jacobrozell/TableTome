import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    @ViewBuilder
    var compactTopChrome: some View {
        if supportsBattleTracker {
            if usesCompactBattleTrackerChrome {
                phoneCompactTopChrome
            } else if usesPadTabbedTwoColumnLayout {
                padTopChrome
            }
        }
    }

    @ViewBuilder
    private var phoneCompactTopChrome: some View {
        if isTopChromeCollapsed {
            BattleTrackerCollapsedTopChrome(
                gameSystemId: viewModel.gameSystemId,
                tabs: BattleTrackerSectionTab.visibleTabs(gameSystemId: viewModel.gameSystemId),
                selection: $selectedSectionTab,
                round: viewModel.trackerState.battleRound,
                phaseTitle: viewModel.trackerState.currentPhase.title,
                playerName: viewModel.trackerState.activePlayerIsOne
                    ? viewModel.playerOneName
                    : viewModel.playerTwoName,
                onExpand: { expandTopChrome() }
            )
        } else {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.xs) {
                VStack(spacing: layoutContext.prefersCollapsedBattleChrome ? DesignTokens.Spacing.xs : DesignTokens.Spacing.sm) {
                    BattleTrackerSectionTabBar(
                        gameSystemId: viewModel.gameSystemId,
                        selection: $selectedSectionTab
                    )
                    if !isEmbeddedInGuidedMatch {
                        StickyPhaseHeader(
                            round: viewModel.trackerState.battleRound,
                            phaseTitle: viewModel.trackerState.currentPhase.title,
                            playerName: viewModel.trackerState.activePlayerIsOne
                                ? viewModel.playerOneName
                                : viewModel.playerTwoName,
                            gameSystemId: viewModel.gameSystemId
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ChromeCollapseInlineButton(
                    accessibilityLabel: String(localized: "Hide battle header"),
                    accessibilityIdentifier: "battleTracker.chromeCollapseInline",
                    onCollapse: collapseTopChrome
                )
            }
            .barChromeBackground(
                horizontalPadding: DesignTokens.Spacing.md,
                verticalPadding: layoutContext.prefersCollapsedBattleChrome ? 2 : DesignTokens.Spacing.xs
            )
        }
    }

    @ViewBuilder
    private var padTopChrome: some View {
        if isEmbeddedInGuidedMatch && isTopChromeCollapsed {
            BattleTrackerCollapsedTopChrome(
                gameSystemId: viewModel.gameSystemId,
                tabs: BattleTrackerSectionTab.visibleTabs(gameSystemId: viewModel.gameSystemId),
                selection: $selectedSectionTab,
                round: viewModel.trackerState.battleRound,
                phaseTitle: viewModel.trackerState.currentPhase.title,
                playerName: viewModel.trackerState.activePlayerIsOne
                    ? viewModel.playerOneName
                    : viewModel.playerTwoName,
                onExpand: { expandTopChrome() }
            )
        } else {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.xs) {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    BattleTrackerSectionTabBar(
                        gameSystemId: viewModel.gameSystemId,
                        selection: $selectedSectionTab
                    )
                    if !isEmbeddedInGuidedMatch {
                        StickyPhaseHeader(
                            round: viewModel.trackerState.battleRound,
                            phaseTitle: viewModel.trackerState.currentPhase.title,
                            playerName: viewModel.trackerState.activePlayerIsOne
                                ? viewModel.playerOneName
                                : viewModel.playerTwoName,
                            gameSystemId: viewModel.gameSystemId
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isEmbeddedInGuidedMatch {
                    ChromeCollapseInlineButton(
                        accessibilityLabel: String(localized: "Hide battle header"),
                        accessibilityIdentifier: "battleTracker.chromeCollapseInline",
                        onCollapse: collapseTopChrome
                    )
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.bar)
            .accessibilityIdentifier("battleTracker.padTopChrome")
        }
    }

    func applyCompactTopChromeDefault() {
        let prefersCollapsedByDefault = layoutContext.prefersCollapsedBattleChrome
            || (isEmbeddedInGuidedMatch && usesCompactBattleTrackerChrome)
        guard prefersCollapsedByDefault, !topChromeExpandedInLandscape else { return }
        guard !isTopChromeCollapsed else { return }
        withAnimation(chromeAnimation) {
            isTopChromeCollapsed = true
        }
    }

    func expandTopChrome() {
        withAnimation(chromeAnimation) {
            isTopChromeCollapsed = false
        }
    }

    func collapseTopChrome() {
        withAnimation(chromeAnimation) {
            isTopChromeCollapsed = true
        }
    }

    /// Battle chrome collapse/expand animation, suppressed under Reduce Motion.
    var chromeAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.2)
    }
}
