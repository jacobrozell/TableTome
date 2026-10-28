import SwiftUI
import TabletomeDomain

struct RuleSectionDetailView: View {
    let section: RuleSection
    let allSections: [RuleSection]
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId

    private var glossaryEntries: [RulesGlossaryEntry] {
        RulesGlossaryCatalog.entriesReferenced(
            in: section.content,
            gameSystemId: gameSystemId,
            ruleSections: allSections
        )
    }

    private var shareText: String {
        """
        \(section.title)

        \(section.content)

        \(String(localized: "via Tabletome"))
        """
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(
                    GameSystemRulesLabels.categoryRowLabel(
                        section.category,
                        gameSystemId: gameSystemId
                    )
                )
                .ttEyebrow()
                .accessibilityAddTraits(.isHeader)

                Text(section.title)
                    .font(TTFont.title)
                    .foregroundStyle(TTColor.inkPrimary)
                    .accessibilityAddTraits(.isHeader)

                TTRichText(section.content)
                    .accessibilityIdentifier("rules.sectionContent.\(section.id)")

                if !glossaryEntries.isEmpty {
                    TTSectionHeader(String(localized: "Terms in This Rule"))
                    GlossaryChipsRow(
                        text: section.content,
                        label: nil,
                        gameSystemId: gameSystemId,
                        ruleSections: allSections
                    )
                }

                if !relatedSections.isEmpty {
                    TTSectionHeader(String(localized: "Related"))
                    ReferenceLinksGroup {
                        ForEach(Array(relatedSections.enumerated()), id: \.element.id) { index, related in
                            if index > 0 {
                                Rectangle()
                                    .fill(TTColor.stroke)
                                    .frame(height: 1)
                                    .padding(.leading, DesignTokens.Spacing.md)
                                    .accessibilityHidden(true)
                            }
                            NavigationLink(
                                value: RuleSectionLink(gameSystemId: gameSystemId, sectionId: related.id)
                            ) {
                                ReferenceLinkRow(title: related.title, systemImage: "doc.text")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(related.title)
                            .accessibilityHint(String(localized: "Opens related rule section"))
                            .accessibilityIdentifier("rules.related.\(related.id)")
                        }
                    }
                }
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .ttScreenBackground()
        .tabBarScrollInset()
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: shareText) {
                    Label(String(localized: "Share"), systemImage: "square.and.arrow.up")
                }
                .accessibilityIdentifier("rules.share.\(section.id)")
                .accessibilityHint(String(localized: "Shares this rule as plain text."))
            }
        }
    }

    private var relatedSections: [RuleSection] {
        section.relatedSectionIds.compactMap { id in
            allSections.first { $0.id == id }
        }
    }
}
