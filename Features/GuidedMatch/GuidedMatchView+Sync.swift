import SwiftUI
import TabletomeDomain
import TabletomeData
import TabletomeHobbyData

extension GuidedMatchView {
    func configureMatchSyncAnalytics() {
        matchSyncService.analyticsHandler = { eventName, metadata in
            let level: LogLevel = eventName.hasSuffix("_failed") ? .error : .info
            switch level {
            case .error:
                dependencies.logger.error(.network, eventName: eventName, message: eventName, metadata: metadata)
            default:
                dependencies.logger.info(.network, eventName: eventName, message: eventName, metadata: metadata)
            }
        }
    }

    @ToolbarContentBuilder
    var padSidebarToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
            }
            .accessibilityLabel(String(localized: "Back"))
            .accessibilityIdentifier("guidedMatch.back")
        }
        matchSyncToolbar
    }

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
