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
                    ScrollView {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                            Text(entry.definition)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityIdentifier("glossary.sheetContent.\(entry.id)")

                            GlossaryChipsRow(
                                text: entry.definition,
                                gameSystemId: link.gameSystemId,
                                ruleSections: ruleSections
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(DesignTokens.Spacing.md)
                    }
                } else if let errorMessage {
                    ContentUnavailableView(
                        String(localized: "Term unavailable"),
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else {
                    ProgressView(String(localized: "Loading term…"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(entry?.term ?? String(localized: "Glossary"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) {
                        dismiss()
                    }
                    .accessibilityIdentifier("glossary.sheetDone")
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task(id: link.id) { await load() }
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
