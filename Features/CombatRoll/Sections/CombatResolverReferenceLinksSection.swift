import SwiftUI
import TabletomeDomain

struct CombatResolverReferenceLinksSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    let ruleSections: [RuleSection]
    let accessibilityPrefix: String

    var body: some View {
        ReferenceLinksGroup {
            let combatSectionId = CombatRollEngineRouter.usesWh40kRules(gameSystemId: viewModel.gameSystemId)
                ? "10e-attack-sequence"
                : "combat-sequence"
            if let combatSection = ruleSections.first(where: { $0.id == combatSectionId }) {
                NavigationLink(value: RuleSectionLink(
                    gameSystemId: viewModel.gameSystemId,
                    sectionId: combatSection.id
                )) {
                    ReferenceLinkRow(title: combatSection.title, systemImage: "doc.text")
                }
                .accessibilityIdentifier("\(accessibilityPrefix).relatedRule")
                Divider().padding(.leading, DesignTokens.Spacing.md)
            }
            NavigationLink(value: RulesGlossaryBrowseLink(gameSystemId: viewModel.gameSystemId)) {
                ReferenceLinkRow(
                    title: GameSystemRulesLabels.glossaryTitle(gameSystemId: viewModel.gameSystemId),
                    systemImage: "book.fill"
                )
            }
            .accessibilityIdentifier("\(accessibilityPrefix).glossary")
        }
    }
}
