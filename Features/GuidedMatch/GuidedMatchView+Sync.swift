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
                if selectedDestination != nil {
                    selectedDestination = nil
                    padDetailNavigationPath = NavigationPath()
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: "chevron.backward")
            }
            .accessibilityLabel(
                selectedDestination != nil
                    ? String(localized: "Back to match overview")
                    : String(localized: "Back")
            )
            .accessibilityIdentifier("guidedMatch.back")
        }
        matchSyncToolbar
    }

    @ToolbarContentBuilder
    var matchSyncToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                if shouldShowMatchSyncToolbar {
                    Button {
                        showsMatchSync = true
                    } label: {
                        Label(String(localized: "Sync with Nearby Device"), systemImage: "arrow.triangle.2.circlepath")
                    }
                    .accessibilityIdentifier("guidedMatch.sync")
                }
                if ReleaseSurface.showsMatchHistory, showsMatchHistoryToolbar {
                    Button {
                        showsMatchHistory = true
                    } label: {
                        Label(String(localized: "Match History"), systemImage: "clock.arrow.circlepath")
                    }
                    .accessibilityIdentifier("guidedMatch.history")
                }
                Divider()
                Button(String(localized: "Reset Match…"), role: .destructive) {
                    showsResetConfirmation = true
                }
                .accessibilityIdentifier("guidedMatch.reset")
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .accessibilityLabel(String(localized: "Match menu"))
            .accessibilityIdentifier("guidedMatch.menu")
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
