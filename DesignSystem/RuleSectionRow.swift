import SwiftUI
import SpearheadDomain

public struct RuleSectionRow: View {
    let title: String
    let category: RuleSectionCategory
    let accessibilityId: String

    public init(title: String, category: RuleSectionCategory, accessibilityId: String) {
        self.title = title
        self.category = category
        self.accessibilityId = accessibilityId
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(title)
                    .font(.headline)
                Text(categoryLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .frame(minHeight: DesignTokens.minTouchTarget)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(categoryLabel)")
        .accessibilityIdentifier(accessibilityId)
    }

    private var categoryLabel: String {
        switch category {
        case .core: String(localized: "Core Rules")
        case .spearhead: String(localized: "Spearhead")
        case .glossary: String(localized: "Glossary")
        }
    }
}
