import SwiftUI
import TabletomeDomain

/// Inline empty state for rules section lists (Rules tab and game guide).
struct RulesBrowseEmptyState: View {
    let searchText: String
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId

    private var showsEditionComparison: Bool {
        switch gameSystemId {
        case GameSystemId.wh40k10eCp.rawValue, GameSystemId.wh40k11e.rawValue:
            return true
        case GameSystemId.aosSpearhead.rawValue:
            return true
        default:
            return false
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
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

            if showsEditionComparison {
                editionComparisonCard(compact: true)
            }
        }
        .listRowInsets(EdgeInsets(top: 24, leading: 0, bottom: 24, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    private func editionComparisonCard(compact: Bool) -> some View {
        switch gameSystemId {
        case GameSystemId.wh40k10eCp.rawValue, GameSystemId.wh40k11e.rawValue:
            CombatPatrolRulesComparisonCard(compact: compact)
        case GameSystemId.aosSpearhead.rawValue:
            SpearheadRulesComparisonCard(compact: compact)
        default:
            EmptyView()
        }
    }
}
