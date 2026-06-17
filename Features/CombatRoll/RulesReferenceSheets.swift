import SwiftUI
import TabletomeDomain

struct RulesGlossaryView: View {
    let highlightedEntryId: String?

    init(highlightedEntryId: String? = nil) {
        self.highlightedEntryId = highlightedEntryId
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

            ForEach(SpearheadRulesGlossary.entries) { entry in
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(entry.term)
                        .font(.headline)
                    Text(entry.definition)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, DesignTokens.Spacing.sm)
                .listRowBackground(entry.id == highlightedEntryId ? Color.accentColor.opacity(0.08) : nil)
                .accessibilityIdentifier("glossary.entry.\(entry.id)")
            }
        }
        .listStyle(.insetGrouped)
        .tabBarScrollInset()
        .navigationTitle(String(localized: "Rules Glossary"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("glossary.screen")
    }
}

struct BattleTacticsReferenceView: View {
    let ruleSections: [RuleSection]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                ForEach(SpearheadBattleTacticsReference.sections) { section in
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
                    }
                    .surfaceCard()
                    .accessibilityIdentifier("battleTactics.section.\(section.id)")
                }

                if let scoring = ruleSections.first(where: { $0.id == "spearhead-scoring" }) {
                    NavigationLink {
                        RuleSectionDetailView(section: scoring, allSections: ruleSections)
                    } label: {
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
        .navigationTitle(String(localized: "Battle Tactics & Twists"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("battleTactics.screen")
    }
}

private struct GlossaryBulletLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            configuration.icon
                .font(.system(size: 6))
                .padding(.top, 6)
            configuration.title
        }
    }
}
