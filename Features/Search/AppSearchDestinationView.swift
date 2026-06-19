import SwiftUI
import TabletomeDomain

struct AppSearchDestinationView: View {
    let result: AppSearchResult
    let ruleSections: [RuleSection]
    let gettingStartedSteps: [GuideStep]
    let editionMigrationSteps: [GuideStep]
    let armies: [SpearheadArmy]
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    @ObservedObject var dependencies: AppDependencies

    var body: some View {
        switch result.kind {
        case .ruleSection:
            if let section = ruleSections.first(where: { $0.id == result.referenceId }) {
                RuleSectionDetailView(
                    section: section,
                    allSections: ruleSections,
                    gameSystemId: gameSystemId
                )
            } else {
                AppSearchResultDetailView(result: result, gameSystemId: gameSystemId, ruleSections: ruleSections)
            }
        case .glossary:
            if let entry = glossaryEntry(for: result.referenceId) {
                GlossaryEntryDetailView(
                    entry: entry,
                    gameSystemId: gameSystemId,
                    ruleSections: ruleSections
                )
            } else {
                AppSearchResultDetailView(result: result, gameSystemId: gameSystemId, ruleSections: ruleSections)
            }
        case .gettingStarted, .editionMigration:
            let steps = result.kind == .gettingStarted ? gettingStartedSteps : editionMigrationSteps
            if let step = steps.first(where: { $0.id == result.referenceId }) {
                GuideStepDetailView(
                    gameSystemId: gameSystemId,
                    step: step,
                    ruleSections: ruleSections
                )
            } else {
                AppSearchResultDetailView(result: result, gameSystemId: gameSystemId, ruleSections: ruleSections)
            }
        case .battleTactics, .cardDeck:
            if GameSystemPlayContext.context(for: gameSystemId).isSpearhead {
                BattleTacticsReferenceView(ruleSections: ruleSections)
            } else {
                AppSearchResultDetailView(result: result, gameSystemId: gameSystemId, ruleSections: ruleSections)
            }
        case .warscroll, .armyRule:
            if let armyId = result.secondaryReferenceId,
               let army = armies.first(where: { $0.id == armyId }) {
                ArmyRosterView(army: army, ruleSections: ruleSections, gameSystemId: gameSystemId)
            } else {
                AppSearchResultDetailView(result: result, gameSystemId: gameSystemId, ruleSections: ruleSections)
            }
        case .appFeature:
            appFeatureDestination
        case .matchSetup, .deployment, .phaseTip:
            AppSearchResultDetailView(result: result, gameSystemId: gameSystemId, ruleSections: ruleSections)
        }
    }

    private func glossaryEntry(for referenceId: String) -> RulesGlossaryEntry? {
        RulesGlossaryCatalog.entries(gameSystemId: gameSystemId, ruleSections: ruleSections)
            .first { $0.id == referenceId }
    }

    @ViewBuilder
    private var appFeatureDestination: some View {
        if let army = armies.first(where: { $0.id == result.referenceId }) {
            ArmyRosterView(army: army, ruleSections: ruleSections, gameSystemId: gameSystemId)
        } else if result.referenceId == "guidedMatch" {
            GuidedMatchView(
                viewModel: dependencies.makeGuidedMatchViewModel(
                    gameSystemId: GameSystemId(resolving: gameSystemId)
                ),
                ruleSections: ruleSections
            )
        } else if result.referenceId == "combatResolver", ReleaseSurface.showsCombatResolver(for: gameSystemId) {
            UnitMatchupEvaluatorView(
                ruleSections: ruleSections,
                gameSystemId: gameSystemId,
                catalogRepository: dependencies.catalogRepository(
                    for: GameSystemId(resolving: gameSystemId)
                )
            )
        } else {
            AppSearchResultDetailView(result: result, gameSystemId: gameSystemId, ruleSections: ruleSections)
        }
    }
}

struct AppSearchResultDetailView: View {
    let result: AppSearchResult
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    var ruleSections: [RuleSection] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(result.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(result.detailBody)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                GlossaryChipsRow(
                    text: result.detailBody,
                    gameSystemId: gameSystemId,
                    ruleSections: ruleSections
                )
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .navigationTitle(result.title)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("search.detail.\(result.id)")
    }
}
