import SwiftUI
import TabletomeDomain

/// Inline empty state for rules section lists (Rules tab and game guide).
struct RulesBrowseEmptyState: View {
    let searchText: String
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId

    private var title: String {
        searchText.isEmpty
            ? String(localized: "No matching sections")
            : String(localized: "No results")
    }

    var body: some View {
        TTEmptyState(
            title: title,
            message: GameSystemRulesLabels.searchEmptyStateHint(gameSystemId: gameSystemId),
            systemImage: searchText.isEmpty ? "doc.text.magnifyingglass" : "magnifyingglass"
        )
        .listRowInsets(
            EdgeInsets(
                top: DesignTokens.Spacing.lg,
                leading: DesignTokens.Spacing.md,
                bottom: DesignTokens.Spacing.lg,
                trailing: DesignTokens.Spacing.md
            )
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

#Preview("RulesBrowseEmptyState") {
    TTPreviewMatrix {
        RulesBrowseEmptyState(searchText: "rend")
    }
}
