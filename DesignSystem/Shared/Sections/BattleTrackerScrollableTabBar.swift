import SwiftUI
import TabletomeDomain

struct BattleTrackerScrollableTabBar: View {
    let gameSystemId: GameSystemId
    let tabs: [BattleTrackerSectionTab]
    @Binding var selection: BattleTrackerSectionTab

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(String(localized: "Battle tracker section"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    ForEach(tabs) { tab in
                        sectionTabButton(tab)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func sectionTabButton(_ tab: BattleTrackerSectionTab) -> some View {
        let isSelected = selection == tab
        return Button {
            selection = tab
        } label: {
            Label(tab.title, systemImage: tab.systemImage)
                .font(.caption.weight(.semibold))
                .adaptiveLineLimit(1)
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .background(
                    isSelected ? Color.accentColor : Color(.tertiarySystemFill),
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
        .frame(minHeight: DesignTokens.minTouchTarget)
        .accessibilityLabel(tab.title)
        .accessibilityHint(tab.accessibilityHint(gameSystemId: gameSystemId))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("battleTracker.sectionTab.\(tab.id)")
    }
}
