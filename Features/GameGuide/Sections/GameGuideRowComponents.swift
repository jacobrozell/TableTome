import SwiftUI
import TabletomeDomain

struct GameGuideStarterArmyRow: View {
    let factionName: String
    let army: SpearheadArmy

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.title3)
                .foregroundStyle(Color.accentOnSurface)
                .symbolRenderingMode(.hierarchical)
                .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(factionName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.accentOnSurface)
                Text(army.name)
                    .font(.headline)
                Text(army.general)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
        .contentShape(Rectangle())
    }
}

struct GameGuideNavigationRow: View {
    let title: String
    let symbol: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(Color.accentOnSurface)
                .symbolRenderingMode(.hierarchical)
                .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
        .contentShape(Rectangle())
    }
}

struct GameGuideFeaturedArmyRow: Identifiable {
    let factionName: String
    let army: SpearheadArmy
    var id: String { army.id }
}
