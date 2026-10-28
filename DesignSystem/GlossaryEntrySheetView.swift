import SwiftUI
import TabletomeDomain

/// Compact glossary definition — presented as a bottom sheet from chips and inline terms.
struct GlossaryEntrySheetView: View {
    let link: GlossaryEntryLink

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dependencies: AppDependencies

    @State private var entry: RulesGlossaryEntry?
    @State private var ruleSections: [RuleSection] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if let entry {
                    loaded(entry)
                } else if let errorMessage {
                    TTEmptyState(
                        title: String(localized: "Term unavailable"),
                        message: errorMessage,
                        systemImage: "exclamationmark.triangle"
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ProgressView(String(localized: "Loading term…"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityLabel(String(localized: "Loading term"))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(TTColor.canvas)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: RuleSectionLink.self) { destination in
                if let section = ruleSections.first(where: { $0.id == destination.sectionId }) {
                    RuleSectionDetailView(
                        section: section,
                        allSections: ruleSections,
                        gameSystemId: destination.gameSystemId
                    )
                }
            }
        }
        .presentationDetents([.fraction(0.4), .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(TTColor.canvas)
        .task(id: link.id) { await load() }
    }

    private func loaded(_ entry: RulesGlossaryEntry) -> some View {
        VStack(spacing: 0) {
            TTSheetHeader(title: entry.term, onClose: { dismiss() })
                .accessibilityIdentifier("glossary.sheetDone")
                .background(TTColor.canvas)
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    TTRichText(entry.definition)
                        .accessibilityIdentifier("glossary.sheetContent.\(entry.id)")

                    GlossaryChipsRow(
                        text: entry.definition,
                        gameSystemId: link.gameSystemId,
                        ruleSections: ruleSections
                    )

                    if let related = relatedSection(for: entry) {
                        NavigationLink(
                            value: RuleSectionLink(
                                gameSystemId: link.gameSystemId,
                                sectionId: related.id
                            )
                        ) {
                            TTRow(
                                title: String(localized: "Related rule"),
                                subtitle: related.title,
                                systemImage: "doc.text"
                            )
                            .padding(.horizontal, DesignTokens.Spacing.md)
                            .padding(.vertical, DesignTokens.Spacing.xs)
                        }
                        .buttonStyle(.plain)
                        .surfaceCard(padding: 0)
                        .accessibilityHint(String(localized: "Opens the related rule section."))
                        .accessibilityIdentifier("glossary.relatedRule.\(related.id)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .readableContentWidth()
                .padding(DesignTokens.Spacing.md)
            }
        }
    }

    /// Matches a loaded rule section when the glossary entry id is that section, or the
    /// `glossary-` content id used in rules-v1.json (for example `contest` → `glossary-contest`).
    private func relatedSection(for entry: RulesGlossaryEntry) -> RuleSection? {
        if let match = ruleSections.first(where: { $0.id == entry.id }) {
            return match
        }
        let glossarySectionId = "glossary-\(entry.id)"
        if let match = ruleSections.first(where: { $0.id == glossarySectionId }) {
            return match
        }
        return ruleSections.first {
            $0.title.compare(entry.term, options: .caseInsensitive) == .orderedSame
        }
    }

    private func load() async {
        entry = nil
        errorMessage = nil
        do {
            let gameSystem = try await dependencies.rulesRepository.gameSystem(id: link.gameSystemId)
            ruleSections = gameSystem.ruleSections
            entry = RulesGlossaryCatalog.entries(
                gameSystemId: link.gameSystemId,
                ruleSections: ruleSections
            ).first { $0.id == link.entryId }
            if entry == nil {
                errorMessage = String(localized: "This glossary term could not be loaded.")
            }
        } catch {
            errorMessage = String(localized: "This glossary term could not be loaded.")
        }
    }
}
