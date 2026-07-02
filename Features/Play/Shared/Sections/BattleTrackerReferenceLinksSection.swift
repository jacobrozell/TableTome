import SwiftUI
import TabletomeDomain

struct BattleTrackerReferenceLinksSection: View {
    let ruleSections: [RuleSection]
    var gameSystemId: GameSystemId = .default

    init(ruleSections: [RuleSection], gameSystemId: GameSystemId = .default) {
        self.ruleSections = ruleSections
        self.gameSystemId = gameSystemId
    }

    init(ruleSections: [RuleSection], gameSystemId: String) {
        self.init(ruleSections: ruleSections, gameSystemId: GameSystemId(resolving: gameSystemId))
    }

    private var capabilities: PlayCapabilities {
        GameSystemPlayContext.context(for: gameSystemId).capabilities
    }

    var body: some View {
        VStack(spacing: 0) {
            if capabilities.showsBattleTacticDecks {
                NavigationLink(value: BattleTacticsReferenceLink(gameSystemId: gameSystemId.rawValue)) {
                    referenceLinkLabel(String(localized: "Card Decks Guide"), systemImage: "rectangle.stack")
                }
                .accessibilityIdentifier("battleTracker.battleTactics")

                Divider().padding(.leading, DesignTokens.Spacing.md)
            }

            NavigationLink(value: RulesGlossaryBrowseLink(gameSystemId: gameSystemId.rawValue)) {
                referenceLinkLabel(
                    GameSystemRulesLabels.glossaryTitle(gameSystemId: gameSystemId),
                    systemImage: "book.fill"
                )
            }
            .accessibilityIdentifier("battleTracker.glossary")

            if let scoringId = capabilities.scoringRuleSectionId,
               let section = ruleSections.first(where: { $0.id == scoringId }) {
                Divider().padding(.leading, DesignTokens.Spacing.md)
                NavigationLink(value: RuleSectionLink(gameSystemId: gameSystemId.rawValue, sectionId: section.id)) {
                    referenceLinkLabel(section.title, systemImage: "doc.text")
                }
                .accessibilityIdentifier("battleTracker.scoringRules")
            }
        }
        .surfaceCard(padding: 0)
    }

    private func referenceLinkLabel(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignTokens.Spacing.md)
            .frame(minHeight: DesignTokens.minTouchTarget)
    }
}
