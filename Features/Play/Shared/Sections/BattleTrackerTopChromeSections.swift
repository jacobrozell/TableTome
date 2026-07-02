import SwiftUI
import TabletomeDomain

struct BattleTrackerPhoneCompactTopChrome: View {
    let gameSystemId: GameSystemId
    let battleRound: Int
    let phaseTitle: String
    let playerOneName: String
    let playerTwoName: String
    let activePlayerIsOne: Bool
    let isTopChromeCollapsed: Bool
    let isEmbeddedInGuidedMatch: Bool
    let prefersCollapsedBattleChrome: Bool
    @Binding var selectedSectionTab: BattleTrackerSectionTab
    let onExpand: () -> Void
    let onCollapse: () -> Void

    var body: some View {
        if isTopChromeCollapsed {
            BattleTrackerCollapsedTopChrome(
                gameSystemId: gameSystemId,
                tabs: BattleTrackerSectionTab.visibleTabs(gameSystemId: gameSystemId),
                selection: $selectedSectionTab,
                round: battleRound,
                phaseTitle: phaseTitle,
                playerName: activePlayerIsOne ? playerOneName : playerTwoName,
                onExpand: onExpand
            )
        } else {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.xs) {
                VStack(spacing: prefersCollapsedBattleChrome ? DesignTokens.Spacing.xs : DesignTokens.Spacing.sm) {
                    BattleTrackerSectionTabBar(
                        gameSystemId: gameSystemId,
                        selection: $selectedSectionTab
                    )
                    if !isEmbeddedInGuidedMatch {
                        StickyPhaseHeader(
                            round: battleRound,
                            phaseTitle: phaseTitle,
                            playerName: activePlayerIsOne ? playerOneName : playerTwoName,
                            gameSystemId: gameSystemId
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ChromeCollapseInlineButton(
                    accessibilityLabel: String(localized: "Hide battle header"),
                    accessibilityIdentifier: "battleTracker.chromeCollapseInline",
                    onCollapse: onCollapse
                )
            }
            .barChromeBackground(
                horizontalPadding: DesignTokens.Spacing.md,
                verticalPadding: prefersCollapsedBattleChrome ? 2 : DesignTokens.Spacing.xs
            )
        }
    }
}

struct BattleTrackerPadTopChrome: View {
    let gameSystemId: GameSystemId
    let battleRound: Int
    let phaseTitle: String
    let playerOneName: String
    let playerTwoName: String
    let activePlayerIsOne: Bool
    let isTopChromeCollapsed: Bool
    let isEmbeddedInGuidedMatch: Bool
    @Binding var selectedSectionTab: BattleTrackerSectionTab
    let onExpand: () -> Void
    let onCollapse: () -> Void

    var body: some View {
        if isEmbeddedInGuidedMatch && isTopChromeCollapsed {
            BattleTrackerCollapsedTopChrome(
                gameSystemId: gameSystemId,
                tabs: BattleTrackerSectionTab.visibleTabs(gameSystemId: gameSystemId),
                selection: $selectedSectionTab,
                round: battleRound,
                phaseTitle: phaseTitle,
                playerName: activePlayerIsOne ? playerOneName : playerTwoName,
                onExpand: onExpand
            )
        } else {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.xs) {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    BattleTrackerSectionTabBar(
                        gameSystemId: gameSystemId,
                        selection: $selectedSectionTab
                    )
                    if !isEmbeddedInGuidedMatch {
                        StickyPhaseHeader(
                            round: battleRound,
                            phaseTitle: phaseTitle,
                            playerName: activePlayerIsOne ? playerOneName : playerTwoName,
                            gameSystemId: gameSystemId
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isEmbeddedInGuidedMatch {
                    ChromeCollapseInlineButton(
                        accessibilityLabel: String(localized: "Hide battle header"),
                        accessibilityIdentifier: "battleTracker.chromeCollapseInline",
                        onCollapse: onCollapse
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
}
