import SwiftUI
import TabletomeDomain

struct AppSearchDestinationView: View {
    let result: AppSearchResult
    let ruleSections: [RuleSection]
    let gettingStartedSteps: [GuideStep]
    let armies: [SpearheadArmy]
    @ObservedObject var dependencies: AppDependencies

    var body: some View {
        switch result.kind {
        case .ruleSection:
            if let section = ruleSections.first(where: { $0.id == result.referenceId }) {
                RuleSectionDetailView(section: section, allSections: ruleSections)
            } else {
                AppSearchResultDetailView(result: result)
            }
        case .glossary:
            RulesGlossaryView(highlightedEntryId: result.referenceId)
        case .gettingStarted:
            if let step = gettingStartedSteps.first(where: { $0.id == result.referenceId }) {
                GuideStepDetailView(
                    gameSystemId: "aos-spearhead",
                    step: step,
                    ruleSections: ruleSections
                )
            } else {
                AppSearchResultDetailView(result: result)
            }
        case .battleTactics, .cardDeck:
            BattleTacticsReferenceView(ruleSections: ruleSections)
        case .warscroll, .armyRule:
            if let armyId = result.secondaryReferenceId,
               let army = armies.first(where: { $0.id == armyId }) {
                ArmyRosterView(army: army, ruleSections: ruleSections)
            } else {
                AppSearchResultDetailView(result: result)
            }
        case .appFeature:
            appFeatureDestination
        case .matchSetup, .deployment, .phaseTip:
            AppSearchResultDetailView(result: result)
        }
    }

    @ViewBuilder
    private var appFeatureDestination: some View {
        if let army = armies.first(where: { $0.id == result.referenceId }) {
            ArmyRosterView(army: army, ruleSections: ruleSections)
        } else if result.referenceId == "guidedMatch" {
            GuidedMatchView(
                viewModel: dependencies.makeGuidedMatchViewModel(),
                ruleSections: ruleSections
            )
        } else if result.referenceId == "combatResolver" {
            UnitMatchupEvaluatorView(ruleSections: ruleSections)
        } else {
            AppSearchResultDetailView(result: result)
        }
    }
}

struct AppSearchResultDetailView: View {
    let result: AppSearchResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(result.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(result.detailBody)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                GlossaryChipsRow(text: result.detailBody)
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .navigationTitle(result.title)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("search.detail.\(result.id)")
    }
}
