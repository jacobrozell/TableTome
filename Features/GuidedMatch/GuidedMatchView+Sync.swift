import SwiftUI
import TabletomeData

extension GuidedMatchView {
    @ToolbarContentBuilder
    var matchSyncToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showsMatchSync = true
            } label: {
                Label(String(localized: "Sync"), systemImage: "arrow.triangle.2.circlepath")
            }
            .accessibilityIdentifier("guidedMatch.sync")
        }
    }

    var matchSyncSheet: some View {
        MatchSyncSheet(syncService: matchSyncService) {
            viewModel.reloadFromStore()
        }
    }
}
