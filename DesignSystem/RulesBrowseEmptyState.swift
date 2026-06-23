import SwiftUI

/// Inline empty state for rules section lists (Rules tab and game guide).
struct RulesBrowseEmptyState: View {
    let searchText: String

    var body: some View {
        ContentUnavailableView {
            Label(
                searchText.isEmpty
                    ? String(localized: "No matching sections")
                    : String(localized: "No results"),
                systemImage: searchText.isEmpty ? "doc.text.magnifyingglass" : "magnifyingglass"
            )
        } description: {
            if searchText.isEmpty {
                Text(String(localized: "Try a different category or game system."))
            } else {
                Text(String(localized: "Try a shorter phrase or check another category."))
            }
        }
        .listRowInsets(EdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
