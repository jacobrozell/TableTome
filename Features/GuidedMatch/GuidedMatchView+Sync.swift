import SwiftUI
import TabletomeData

extension GuidedMatchView {
    @ToolbarContentBuilder
    var matchSyncToolbar: some ToolbarContent {
        if showsHubChromeCollapseToggle {
            ToolbarItem(placement: .topBarLeading) {
                ChromeCollapseToolbarButton(
                    isCollapsed: $isHubChromeCollapsed,
                    expandedAccessibilityLabel: String(localized: "Hide match summary"),
                    collapsedAccessibilityLabel: String(localized: "Show match summary"),
                    accessibilityIdentifier: "guidedMatch.hubChromeCollapse"
                )
            }
        }
        matchHistoryToolbarItems
        if viewModel.matchState.hasBothArmies {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showsMatchSync = true
                } label: {
                    Label(String(localized: "Nearby sync"), systemImage: "arrow.triangle.2.circlepath")
                }
                .accessibilityIdentifier("guidedMatch.sync")
                .accessibilityHint(
                    String(
                        localized: "Share match state with your opponent on the same Wi-Fi or Bluetooth. Optional."
                    )
                )
            }
        }
    }

    var matchSyncSheet: some View {
        MatchSyncSheet(syncService: matchSyncService, gameSystemId: gameSystemId.rawValue) {
            viewModel.reloadFromStore()
        }
    }
}
