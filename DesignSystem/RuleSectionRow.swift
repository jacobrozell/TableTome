import SwiftUI
import TabletomeDomain

public struct RuleSectionRow: View {
    let title: String
    let category: RuleSectionCategory
    let accessibilityId: String

    private var categoryLabel: String {
        GameSystemRulesLabels.categoryRowLabel(category, gameSystemId: gameSystemId)
    }

    private let gameSystemId: String

    public init(
        title: String,
        category: RuleSectionCategory,
        gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId,
        accessibilityId: String
    ) {
        self.title = title
        self.category = category
        self.gameSystemId = gameSystemId
        self.accessibilityId = accessibilityId
    }

    public var body: some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: RuleSectionCategorySymbol.systemImage(for: category))
                .font(.body.weight(.medium))
                .foregroundStyle(Color.accentOnSurface)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(title)
                    .font(.headline)
                Text(categoryLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .frame(minHeight: DesignTokens.minTouchTarget)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(categoryLabel)")
        .accessibilityHint(String(localized: "Opens this rule section."))
        .accessibilityIdentifier(accessibilityId)
    }
}
