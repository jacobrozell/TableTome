import SwiftUI
import TabletomeDomain

struct RulesGlossaryView: View {
    let highlightedEntryId: String?
    let gameSystemId: String
    var ruleSections: [RuleSection] = []

    @EnvironmentObject private var glossaryNavigation: GlossaryNavigationState

    init(
        highlightedEntryId: String? = nil,
        gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId,
        ruleSections: [RuleSection] = []
    ) {
        self.highlightedEntryId = highlightedEntryId
        self.gameSystemId = gameSystemId
        self.ruleSections = ruleSections
    }

    var body: some View {
        List {
            Section {
                Text(
                    String(
                        localized: """
                        Tap a term for a plain-language definition. These appear throughout guides and the battle tracker.
                        """
                    )
                )
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .listRowBackground(Color.clear)
            }

            if glossaryEntries.isEmpty {
                Section {
                    Text(emptyStateMessage)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            ForEach(glossaryEntries) { entry in
                Button {
                    glossaryNavigation.open(
                        GlossaryEntryLink(
                            gameSystemId: gameSystemId,
                            entryId: entry.id
                        )
                    )
                } label: {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(entry.term)
                            .font(.headline)
                        Text(entry.definition)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .id(entry.id)
                .listRowBackground(entry.id == highlightedEntryId ? Color.accentColor.opacity(0.08) : nil)
                .accessibilityIdentifier("glossary.entry.\(entry.id)")
            }
        }
        .listStyle(.insetGrouped)
        .tabBarScrollInset()
        .navigationTitle(GameSystemRulesLabels.glossaryTitle(gameSystemId: gameSystemId))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("glossary.screen")
    }

    private var glossaryEntries: [RulesGlossaryEntry] {
        RulesGlossaryCatalog.entries(gameSystemId: gameSystemId, ruleSections: ruleSections)
    }

    private var emptyStateMessage: String {
        if GameSystemPlayContext.context(for: gameSystemId).isStarCraft {
            return String(
                localized: """
                StarCraft glossary terms are in the StarCraft Rules reference. Open it from Browse or the game guide.
                """
            )
        }
        return String(localized: "No glossary entries are available for this game mode yet.")
    }
}

struct GlossaryEntryDetailView: View {
    let entry: RulesGlossaryEntry
    let gameSystemId: String
    var ruleSections: [RuleSection] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(entry.definition)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("glossary.entryContent.\(entry.id)")

                GlossaryChipsRow(
                    text: entry.definition,
                    gameSystemId: gameSystemId,
                    ruleSections: ruleSections
                )

                NavigationLink(value: RulesGlossaryBrowseLink(gameSystemId: gameSystemId)) {
                    Label(
                        GameSystemRulesLabels.glossaryTitle(gameSystemId: gameSystemId),
                        systemImage: "book.fill"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: DesignTokens.minTouchTarget)
                }
                .accessibilityIdentifier("glossary.browseAll")
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .tabBarScrollInset()
        .navigationTitle(entry.term)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BattleTacticsReferenceView: View {
    let ruleSections: [RuleSection]
    var gameSystemId: String = GameSystemId.aosSpearhead.rawValue

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                introBanner

                deckComparisonSection

                ForEach(SpearheadBattleTacticsReference.sections) { section in
                    referenceSectionCard(section)
                }

                if let scoring = ruleSections.first(where: { $0.id == "spearhead-scoring" }) {
                    NavigationLink(value: RuleSectionLink(gameSystemId: gameSystemId, sectionId: scoring.id)) {
                        Label(scoring.title, systemImage: "doc.text")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(minHeight: DesignTokens.minTouchTarget)
                    }
                    .accessibilityIdentifier("battleTactics.scoringRules")
                }
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .tabBarScrollInset()
        .navigationTitle(String(localized: "Card Decks Guide"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("battleTactics.screen")
    }

    private var introBanner: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "Twists vs Battle Tactics"), systemImage: "rectangle.stack.fill")
                .font(.headline)
                .foregroundStyle(Color.accentColor)
            Text(
                String(
                    localized: """
                    Spearhead uses two completely different card decks. Mixing them up is the most common \
                    rules mistake — use this guide at the table when you are unsure which deck to grab.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .accentHighlightCard()
        .accessibilityIdentifier("battleTactics.intro")
    }

    private var deckComparisonSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(String(localized: "Which Deck Is Which?"))
                .font(.headline)

            ForEach(SpearheadBattleTacticsReference.deckGuides) { deck in
                SpearheadCardDeckGuideCard(deck: deck)
                    .accessibilityIdentifier("battleTactics.deck.\(deck.id)")
            }
        }
    }

    private func referenceSectionCard(_ section: BattleTacticsReferenceSection) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(section.title)
                .font(.headline)
            Text(section.body)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if !section.bullets.isEmpty {
                ForEach(section.bullets, id: \.self) { bullet in
                    Label(bullet, systemImage: "circle.fill")
                        .font(.callout)
                        .labelStyle(GlossaryBulletLabelStyle())
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            if !section.examples.isEmpty {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Examples"))
                        .font(.subheadline.weight(.semibold))
                    ForEach(section.examples, id: \.self) { example in
                        Label(example, systemImage: "arrow.turn.down.right")
                            .font(.callout)
                            .labelStyle(GlossaryBulletLabelStyle())
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(DesignTokens.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            }
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTactics.section.\(section.id)")
    }
}

private struct SpearheadCardDeckGuideCard: View {
    let deck: SpearheadCardDeckGuide

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(deck.name, systemImage: deck.id == "twist" ? "sparkles" : "person.fill")
                .font(.subheadline.weight(.semibold))

            deckDetailRow(label: String(localized: "Comes from"), value: deck.comesFrom)
            deckDetailRow(label: String(localized: "Who uses it"), value: deck.whoUsesIt)
            deckDetailRow(label: String(localized: "When"), value: deck.whenUsed)
            deckDetailRow(label: String(localized: "Look for"), value: deck.lookFor)
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    private func deckDetailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct GlossaryBulletLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            configuration.icon
                .font(.caption2)
                .padding(.top, 6)
            configuration.title
        }
    }
}
