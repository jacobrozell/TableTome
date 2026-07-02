import SwiftUI
import TabletomeDomain

struct BattleTrackerSegmentedTabBar: View {
    let gameSystemId: GameSystemId
    let tabs: [BattleTrackerSectionTab]
    @Binding var selection: BattleTrackerSectionTab
    let usesCompactTabBar: Bool

    var body: some View {
        HStack(spacing: 2) {
            ForEach(tabs) { tab in
                segmentedTabButton(tab)
            }
        }
        .padding(2)
        .background(Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        .accessibilityElement(children: .contain)
    }

    private func segmentedTabButton(_ tab: BattleTrackerSectionTab) -> some View {
        let isSelected = selection == tab
        return Button {
            selection = tab
        } label: {
            Text(tab.title)
                .font(usesCompactTabBar ? .caption.weight(.semibold) : .footnote.weight(.semibold))
                .adaptiveLineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
                .padding(.vertical, usesCompactTabBar ? DesignTokens.Spacing.xs : DesignTokens.Spacing.sm)
                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                .background(
                    isSelected ? Color(.systemBackground) : Color.clear,
                    in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm - 2)
                )
        }
        .buttonStyle(.plain)
        .frame(minHeight: DesignTokens.minTouchTarget)
        .accessibilityLabel(tab.title)
        .accessibilityHint(tab.accessibilityHint(gameSystemId: gameSystemId))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("battleTracker.sectionTab.\(tab.id)")
    }
}
