import SwiftUI
import TabletomeDomain

public struct RuleSectionRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let category: RuleSectionCategory
    let accessibilityId: String

    private let gameSystemId: String
    private let content: String
    private let searchText: String

    private var categoryLabel: String {
        GameSystemRulesLabels.categoryRowLabel(category, gameSystemId: gameSystemId)
    }

    private var symbolName: String {
        RuleSectionCategorySymbol.systemImage(for: category)
    }

    private var spokenSubtitle: String {
        if !content.isEmpty {
            if let match = RuleSectionSnippet.match(in: content, query: searchText) {
                return match.text
            }
            let sentence = RuleSectionSnippet.firstSentence(of: content)
            if !sentence.isEmpty { return sentence }
        }
        return categoryLabel
    }

    public init(
        title: String,
        category: RuleSectionCategory,
        gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId,
        content: String = "",
        searchText: String = "",
        accessibilityId: String
    ) {
        self.title = title
        self.category = category
        self.gameSystemId = gameSystemId
        self.content = content
        self.searchText = searchText
        self.accessibilityId = accessibilityId
    }

    public var body: some View {
        row
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title), \(spokenSubtitle)")
            .accessibilityHint(String(localized: "Opens this rule section."))
            .accessibilityIdentifier(accessibilityId)
    }

    @ViewBuilder
    private var row: some View {
        if content.isEmpty || searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || RuleSectionSnippet.match(in: content, query: searchText) == nil {
            TTRow(title: title, subtitle: plainSubtitle, systemImage: symbolName)
        } else {
            highlightedRow
        }
    }

    private var plainSubtitle: String? {
        if !content.isEmpty {
            let sentence = RuleSectionSnippet.firstSentence(of: content)
            return sentence.isEmpty ? nil : sentence
        }
        return categoryLabel
    }

    private var highlightedRow: some View {
        let subtitle = RuleSectionSnippet.attributedSubtitle(content: content, query: searchText)
        return Group {
            if dynamicTypeSize.needsLayoutAdaptation {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    TTIconTile(systemImage: symbolName)
                    titleLabel
                    Text(subtitle)
                        .adaptiveLineLimit(2)
                    chevron
                }
            } else {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    TTIconTile(systemImage: symbolName)
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                        titleLabel
                        Text(subtitle)
                            .lineLimit(2)
                    }
                    Spacer(minLength: DesignTokens.Spacing.sm)
                    chevron
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
    }

    private var titleLabel: some View {
        Text(title)
            .font(TTFont.headline)
            .foregroundStyle(TTColor.inkPrimary)
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .foregroundStyle(TTColor.inkTertiary)
            .accessibilityHidden(true)
    }
}

#Preview("RuleSectionRow") {
    TTPreviewMatrix {
        RuleSectionRow(
            title: "Attack Roll Modifiers",
            category: .core,
            content: "Save rolls subtract the weapon's Rend from the roll.",
            searchText: "rend",
            accessibilityId: "rules.section.preview"
        )
    }
}
