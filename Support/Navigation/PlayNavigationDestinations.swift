import SwiftUI
import TabletomeDomain

extension View {
    /// Register Play-tab deep links once on the `NavigationStack` root (`HomeView`, Rules tab).
    /// Pair with `glossaryEntryNavigation()` for glossary bottom sheets. Do not apply again on pushed screens.
    func playNavigationDestinations() -> some View {
        modifier(PlayNavigationDestinationsModifier())
    }
}

private struct PlayNavigationDestinationsModifier: ViewModifier {
    @EnvironmentObject private var dependencies: AppDependencies

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: GettingStartedLink.self) { link in
                GettingStartedDestinationView(gameSystemId: link.gameSystemId)
            }
            .navigationDestination(for: EditionMigrationLink.self) { link in
                EditionMigrationDestinationView(gameSystemId: link.gameSystemId)
            }
            .navigationDestination(for: GuidedMatchLink.self) { link in
                GuidedMatchDestinationView(
                    gameSystemId: link.gameSystemId,
                    opensBattleTab: link.opensBattleTab
                )
            }
            .navigationDestination(for: SampleTurnLink.self) { _ in
                SampleTurnWalkthroughView()
            }
            .navigationDestination(for: CombatPatrolSampleTurnLink.self) { _ in
                CombatPatrolSampleTurnWalkthroughView()
            }
            .navigationDestination(for: Wh40k11eSampleTurnLink.self) { _ in
                Wh40k11eSampleTurnWalkthroughView()
            }
            .navigationDestination(for: MatchHistoryLink.self) { _ in
                MatchHistoryListView(viewModel: dependencies.makeMatchHistoryViewModel())
            }
            .navigationDestination(for: GuideStepLink.self) { link in
                GuideStepDestinationView(gameSystemId: link.gameSystemId, stepId: link.stepId)
            }
            .navigationDestination(for: RuleSectionLink.self) { link in
                RuleSectionDestinationView(gameSystemId: link.gameSystemId, sectionId: link.sectionId)
            }
            .navigationDestination(for: RulesGlossaryBrowseLink.self) { link in
                RulesGlossaryBrowseDestinationView(link: link)
            }
            .navigationDestination(for: BattleTacticsReferenceLink.self) { link in
                BattleTacticsReferenceDestinationView(gameSystemId: link.gameSystemId)
            }
            .navigationDestination(for: GameSystemRulesReferenceLink.self) { link in
                GameSystemRulesReferenceDestinationView(gameSystemId: link.gameSystemId)
            }
            .navigationDestination(for: CombatResolverLink.self) { link in
                CombatResolverDestinationView(link: link)
            }
            .navigationDestination(for: ArmyRosterLink.self) { link in
                ArmyRosterDestinationView(gameSystemId: link.gameSystemId, armyId: link.armyId)
            }
            .navigationDestination(for: CombatPatrolMissionsLink.self) { link in
                CombatPatrolMissionsDestinationView(gameSystemId: link.gameSystemId)
            }
            .navigationDestination(for: GameGuideBrowseLink.self) { link in
                GameSystemDetailView(gameSystemId: link.gameSystemId)
            }
            .navigationDestination(for: RulesReferenceBrowseLink.self) { link in
                RulesReferenceBrowseDestinationView(gameSystemId: link.gameSystemId)
            }
            .navigationDestination(for: AppSearchResultLink.self) { link in
                AppSearchResultDestinationView(link: link)
            }
    }
}

struct GuideStepDestinationView: View {
    let gameSystemId: String
    let stepId: String

    @EnvironmentObject private var dependencies: AppDependencies
    @State private var gameSystem: GameSystem?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let gameSystem, let step = resolvedStep(in: gameSystem) {
                GuideStepDetailView(
                    gameSystemId: gameSystemId,
                    step: step,
                    ruleSections: gameSystem.ruleSections
                )
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Guide topic unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading guide…"))
                    .asyncContentShell()
            }
        }
        .task { await load() }
    }

    private func resolvedStep(in gameSystem: GameSystem) -> GuideStep? {
        gameSystem.gettingStartedSteps.first { $0.id == stepId }
            ?? gameSystem.editionMigrationSteps.first { $0.id == stepId }
    }

    private func load() async {
        do {
            gameSystem = try await dependencies.rulesRepository.gameSystem(id: gameSystemId)
            if gameSystem.map({ resolvedStep(in: $0) }) == nil {
                errorMessage = String(localized: "This guide topic could not be loaded.")
            }
        } catch {
            errorMessage = String(localized: "This guide topic could not be loaded.")
        }
    }
}

struct RuleSectionDestinationView: View {
    let gameSystemId: String
    let sectionId: String

    @EnvironmentObject private var dependencies: AppDependencies
    @State private var gameSystem: GameSystem?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let gameSystem,
               let section = gameSystem.ruleSections.first(where: { $0.id == sectionId }) {
                RuleSectionDetailView(
                    section: section,
                    allSections: gameSystem.ruleSections,
                    gameSystemId: gameSystemId
                )
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Rules section unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading rules…"))
                    .asyncContentShell()
            }
        }
        .task { await load() }
    }

    private func load() async {
        do {
            gameSystem = try await dependencies.rulesRepository.gameSystem(id: gameSystemId)
            if gameSystem?.ruleSections.contains(where: { $0.id == sectionId }) == false {
                errorMessage = String(localized: "This rule section could not be loaded.")
            }
        } catch {
            errorMessage = String(localized: "This rule section could not be loaded.")
        }
    }
}

struct RulesGlossaryBrowseDestinationView: View {
    let link: RulesGlossaryBrowseLink

    @EnvironmentObject private var dependencies: AppDependencies
    @State private var ruleSections: [RuleSection]?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let ruleSections {
                RulesGlossaryView(
                    highlightedEntryId: link.highlightedEntryId,
                    gameSystemId: link.gameSystemId,
                    ruleSections: ruleSections
                )
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Glossary unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading glossary…"))
                    .asyncContentShell()
            }
        }
        .task { await load() }
    }

    private func load() async {
        do {
            let gameSystem = try await dependencies.rulesRepository.gameSystem(id: link.gameSystemId)
            ruleSections = gameSystem.ruleSections
        } catch {
            errorMessage = String(localized: "The glossary could not be loaded.")
        }
    }
}

struct GlossaryEntryDestinationView: View {
    let link: GlossaryEntryLink

    @EnvironmentObject private var dependencies: AppDependencies
    @State private var entry: RulesGlossaryEntry?
    @State private var ruleSections: [RuleSection] = []
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let entry {
                GlossaryEntryDetailView(
                    entry: entry,
                    gameSystemId: link.gameSystemId,
                    ruleSections: ruleSections
                )
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Term unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading term…"))
                    .asyncContentShell()
            }
        }
        .task { await load() }
    }

    private func load() async {
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

struct BattleTacticsReferenceDestinationView: View {
    let gameSystemId: String

    @EnvironmentObject private var dependencies: AppDependencies
    @State private var ruleSections: [RuleSection]?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let ruleSections {
                BattleTacticsReferenceView(ruleSections: ruleSections, gameSystemId: gameSystemId)
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Reference unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading reference…"))
                    .asyncContentShell()
            }
        }
        .task { await load() }
    }

    private func load() async {
        do {
            let gameSystem = try await dependencies.rulesRepository.gameSystem(id: gameSystemId)
            ruleSections = gameSystem.ruleSections
        } catch {
            errorMessage = String(localized: "This reference could not be loaded.")
        }
    }
}

struct GameSystemRulesReferenceDestinationView: View {
    let gameSystemId: String

    @EnvironmentObject private var dependencies: AppDependencies
    @State private var gameSystem: GameSystem?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let gameSystem {
                GameSystemRulesReferenceView(gameSystem: gameSystem)
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Rules unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading rules…"))
                    .asyncContentShell()
            }
        }
        .task { await load() }
    }

    private func load() async {
        do {
            gameSystem = try await dependencies.rulesRepository.gameSystem(id: gameSystemId)
        } catch {
            errorMessage = String(localized: "Rules could not be loaded.")
        }
    }
}

struct CombatResolverDestinationView: View {
    let link: CombatResolverLink

    @EnvironmentObject private var dependencies: AppDependencies
    @State private var ruleSections: [RuleSection]?
    @State private var errorMessage: String?

    private var attackerPrefill: MatchupUnitPrefill? {
        guard let armyId = link.attackerArmyId, let unitId = link.attackerUnitId else { return nil }
        return MatchupUnitPrefill(
            armyId: armyId,
            unitId: unitId,
            weaponId: link.attackerWeaponId
        )
    }

    var body: some View {
        Group {
            if let ruleSections {
                UnitMatchupEvaluatorView(
                    ruleSections: ruleSections,
                    gameSystemId: link.gameSystemId,
                    catalogRepository: dependencies.catalogRepository(
                        for: GameSystemId(resolving: link.gameSystemId)
                    ),
                    attackerPrefill: attackerPrefill
                )
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Combat tools unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading combat tools…"))
                    .asyncContentShell()
            }
        }
        .task { await load() }
    }

    private func load() async {
        do {
            let gameSystem = try await dependencies.rulesRepository.gameSystem(id: link.gameSystemId)
            ruleSections = gameSystem.ruleSections
        } catch {
            errorMessage = String(localized: "Combat tools could not be loaded.")
        }
    }
}

struct ArmyRosterDestinationView: View {
    let gameSystemId: String
    let armyId: String

    @EnvironmentObject private var dependencies: AppDependencies
    @State private var army: SpearheadArmy?
    @State private var ruleSections: [RuleSection]?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let army, let ruleSections {
                ArmyRosterView(
                    army: army,
                    ruleSections: ruleSections,
                    gameSystemId: gameSystemId,
                    featuredArmies: featuredArmies
                )
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Army roster unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading army…"))
                    .asyncContentShell()
            }
        }
        .task { await load() }
    }

    private var featuredArmies: GuidedMatchFeaturedArmies {
        if gameSystemId == "wh40k-11e" {
            return FortyKFeaturedArmies.configuration
        }
        return GuidedMatchFeaturedArmies.forGameSystem(gameSystemId)
            ?? SpearheadFeaturedArmies.configuration
    }

    private func load() async {
        do {
            let gameSystem = try await dependencies.rulesRepository.gameSystem(id: gameSystemId)
            ruleSections = gameSystem.ruleSections
            let catalog = try await dependencies.catalogRepository(
                for: GameSystemId(resolving: gameSystemId)
            ).loadCatalog()
            army = catalog.factions.flatMap(\.armies).first { $0.id == armyId }
            if army == nil {
                errorMessage = String(localized: "This army roster could not be loaded.")
            }
        } catch {
            errorMessage = String(localized: "This army roster could not be loaded.")
        }
    }
}

struct CombatPatrolMissionsDestinationView: View {
    let gameSystemId: String

    @EnvironmentObject private var dependencies: AppDependencies
    @State private var ruleSections: [RuleSection]?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let ruleSections {
                CombatPatrolMissionsReferenceView(ruleSections: ruleSections, gameSystemId: gameSystemId)
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Missions unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading missions…"))
                    .asyncContentShell()
            }
        }
        .task { await load() }
    }

    private func load() async {
        do {
            let gameSystem = try await dependencies.rulesRepository.gameSystem(id: gameSystemId)
            ruleSections = gameSystem.ruleSections
        } catch {
            errorMessage = String(localized: "Missions could not be loaded.")
        }
    }
}

struct RulesReferenceBrowseDestinationView: View {
    let gameSystemId: String

    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        RulesReferenceView(
            viewModel: dependencies.makeRulesReferenceViewModel(
                gameSystemId: GameSystemId(resolving: gameSystemId)
            )
        )
    }
}

struct AppSearchResultDestinationView: View {
    let link: AppSearchResultLink

    @EnvironmentObject private var dependencies: AppDependencies
    @State private var result: AppSearchResult?
    @State private var ruleSections: [RuleSection] = []
    @State private var gettingStartedSteps: [GuideStep] = []
    @State private var editionMigrationSteps: [GuideStep] = []
    @State private var armies: [SpearheadArmy] = []
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let result {
                AppSearchDestinationView(
                    result: result,
                    ruleSections: ruleSections,
                    gettingStartedSteps: gettingStartedSteps,
                    editionMigrationSteps: editionMigrationSteps,
                    armies: armies,
                    gameSystemId: link.gameSystemId,
                    dependencies: dependencies
                )
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Search result unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading…"))
                    .asyncContentShell()
            }
        }
        .task { await load() }
    }

    private func load() async {
        do {
            let gameSystem = try await dependencies.rulesRepository.gameSystem(id: link.gameSystemId)
            ruleSections = gameSystem.ruleSections
            gettingStartedSteps = gameSystem.gettingStartedSteps
            editionMigrationSteps = gameSystem.editionMigrationSteps
            let catalog = try await dependencies.catalogRepository(
                for: GameSystemId(resolving: link.gameSystemId)
            ).loadCatalog()
            armies = catalog.factions.flatMap(\.armies)
            let index = AppSearchIndexBuilder.build(gameSystem: gameSystem, catalog: catalog)
            result = index.first { $0.id == link.resultId }
            if result == nil {
                errorMessage = String(localized: "This search result could not be loaded.")
            }
        } catch {
            errorMessage = String(localized: "This search result could not be loaded.")
        }
    }
}
