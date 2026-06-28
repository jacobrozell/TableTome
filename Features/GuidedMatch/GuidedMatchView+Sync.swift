import SwiftUI
import TabletomeData

extension GuidedMatchView {
    @ToolbarContentBuilder
    var matchSyncToolbar: some ToolbarContent {
        matchHistoryToolbarItems
        if shouldShowMatchSyncToolbar {
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

    /// Defer nearby sync until the player has finished first setup or opened a game guide.
    private var shouldShowMatchSyncToolbar: Bool {
        viewModel.matchState.hasBothArmies
            && (FirstSessionStore.hasCompletedSetup || FirstSessionStore.hasOpenedGameGuide)
    }

    var matchSyncSheet: some View {
        MatchSyncSheet(syncService: matchSyncService, gameSystemId: gameSystemId.rawValue) {
            viewModel.reloadFromStore()
        }
    }
}
