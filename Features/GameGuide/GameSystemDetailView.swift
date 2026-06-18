import SwiftUI
import TabletomeDomain

struct GameSystemDetailView: View {
    let gameSystemId: String
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @EnvironmentObject private var dependencies: AppDependencies
    @State private var gameSystem: GameSystem?
    @State private var featuredArmies: [SpearheadArmy] = []
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let gameSystem {
                List {
                    if gameSystemId == "aos-spearhead" {
                        Section {
                            NewPlayerStartHereCard()
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }

                    if gameSystemId == "wh40k-11e" {
                        Section {
                            FortyKStartHereCard(gameSystem: gameSystem)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }

                    if gameSystemId == "wh40k-10e-cp" {
                        Section {
                            CombatPatrolStartHereCard(gameSystem: gameSystem)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }

                    if gameSystemId == "sc-tmg" {
                        Section {
                            ScStartHereCard(gameSystem: gameSystem)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }

                    if gameSystemId == "wh40k-11e", !featuredArmies.isEmpty {
                        Section {
                            ForEach(featuredArmies) { army in
                                NavigationLink {
                                    ArmyRosterView(
                                        army: army,
                                        ruleSections: gameSystem.ruleSections,
                                        gameSystemId: gameSystemId,
                                        featuredArmies: FortyKFeaturedArmies.configuration
                                    )
                                } label: {
                                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                        Text(army.name)
                                            .font(.headline)
                                        Text(army.general)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                                }
                                .accessibilityIdentifier("guide.armyRoster.\(army.id)")
                            }
                        } header: {
                            Text(String(localized: "Starter Set Armies"))
                        } footer: {
                            Text(String(localized: "Datasheets, abilities, and battle tools for the Armageddon launch box armies."))
                        }
                    }

                    if (gameSystemId == "aos-spearhead" || gameSystemId == "sc-tmg" || gameSystemId == "wh40k-10e-cp"), !featuredArmies.isEmpty {
                        Section {
                            ForEach(featuredArmies) { army in
                                NavigationLink {
                                    ArmyRosterView(
                                        army: army,
                                        ruleSections: gameSystem.ruleSections,
                                        gameSystemId: gameSystemId,
                                        featuredArmies: GuidedMatchFeaturedArmies.forGameSystem(gameSystemId)
                                            ?? SpearheadFeaturedArmies.configuration
                                    )
                                } label: {
                                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                        Text(army.name)
                                            .font(.headline)
                                        Text(army.general)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                                }
                                .accessibilityIdentifier("guide.armyRoster.\(army.id)")
                            }
                        } header: {
                            Text(starterArmiesSectionTitle)
                        } footer: {
                            Text(starterArmiesSectionFooter)
                        }
                    }

                    Section {
                        NavigationLink {
                            GettingStartedView(gameSystem: gameSystem)
                        } label: {
                            guideRow(
                                title: String(localized: "Getting Started"),
                                symbol: "map",
                                detail: gettingStartedDetail
                            )
                        }
                        .accessibilityIdentifier("guide.gettingStarted.\(gameSystemId)")

                        if gameSystemId == "wh40k-10e-cp" {
                            NavigationLink {
                                CombatPatrolSampleTurnWalkthroughView()
                            } label: {
                                guideRow(
                                    title: String(localized: "Preview a Turn"),
                                    symbol: "play.circle",
                                    detail: String(localized: "Command-first tour — objectives, stratagems, and scoring")
                                )
                            }
                            .accessibilityIdentifier("guide.combatPatrolSampleTurn.\(gameSystemId)")
                        }

                        if !gameSystem.editionMigrationSteps.isEmpty {
                            NavigationLink {
                                EditionMigrationView(gameSystem: gameSystem)
                            } label: {
                                guideRow(
                                    title: editionMigrationLinkTitle,
                                    symbol: gameSystemId == "sc-tmg" ? "gamecontroller" : "arrow.triangle.2.circlepath",
                                    detail: editionMigrationLinkDetail
                                )
                            }
                            .accessibilityIdentifier("guide.whatsNew.\(gameSystemId)")
                        }

                        if !gameSystem.ruleSections.isEmpty {
                            NavigationLink {
                                GameSystemRulesReferenceView(gameSystem: gameSystem)
                            } label: {
                                guideRow(
                                    title: GameSystemRulesLabels.rulesReferenceLinkTitle(gameSystemId: gameSystemId),
                                    symbol: "doc.text.fill",
                                    detail: String(localized: "Search phases, combat, terrain, and glossary")
                                )
                            }
                            .accessibilityIdentifier("guide.rulesReference.\(gameSystemId)")
                        }

                        if ReleaseSurface.showsGuidedMatch(for: gameSystemId) {
                            NavigationLink {
                                GuidedMatchView(
                                    viewModel: dependencies.makeGuidedMatchViewModel(
                                        gameSystemId: GameSystemId(resolving: gameSystemId)
                                    ),
                                    ruleSections: gameSystem.ruleSections
                                )
                            } label: {
                                guideRow(
                                    title: String(localized: "Guided Match"),
                                    symbol: "flag.checkered",
                                    detail: guidedMatchDetail
                                )
                            }
                            .accessibilityIdentifier("guide.guidedMatch.\(gameSystemId)")
                        }

                        if ReleaseSurface.showsCombatResolver(for: gameSystemId) {
                            NavigationLink {
                                UnitMatchupEvaluatorView(
                                    ruleSections: gameSystem.ruleSections,
                                    gameSystemId: gameSystemId,
                                    catalogRepository: dependencies.catalogRepository(
                                        for: GameSystemId(resolving: gameSystemId)
                                    )
                                )
                            } label: {
                                guideRow(
                                    title: String(localized: "Combat Resolver"),
                                    symbol: "dice.fill",
                                    detail: GameSystemPlayContext.context(for: gameSystemId).isCombatPatrol
                                        ? String(localized: "Resolve hit, wound, and save rolls at the table")
                                        : String(localized: "Practice attack dice math between games")
                                )
                            }
                            .accessibilityIdentifier("guide.combatResolver.\(gameSystemId)")
                        }
                    } header: {
                        Text(String(localized: "Play"))
                    } footer: {
                        if gameSystemId == "aos-spearhead" {
                            Text(String(localized: "New to a term? Open AoS Glossary under Table Reference."))
                        } else if gameSystemId == "wh40k-11e" {
                            Text(String(localized: "Use Guided Match for the Armageddon starter matchup, or browse all factions in army selection."))
                        } else if gameSystemId == "wh40k-10e-cp" {
                            Text(
                                String(
                                    localized: """
                                    Start with Getting Started, then open Missions Reference before your first Clash of Patrols game. \
                                    Guided Match includes the Leviathan Combat Patrol starter setup.
                                    """
                                )
                            )
                        } else if gameSystemId == "sc-tmg" {
                            Text(String(localized: "Start with Use Starter Matchup for the 2-Player Founders Edition."))
                        }
                    }

                    if gameSystemId == "aos-spearhead" {
                        Section(String(localized: "Table Reference")) {
                            NavigationLink {
                                BattleTacticsReferenceView(ruleSections: gameSystem.ruleSections)
                            } label: {
                                Label(String(localized: "Card Decks Guide"), systemImage: "rectangle.stack")
                                    .frame(minHeight: DesignTokens.minTouchTarget)
                            }
                            .accessibilityHint(String(localized: "Twist cards vs battle tactic cards — which deck is which"))
                            NavigationLink {
                                RulesGlossaryView(
                                    gameSystemId: gameSystemId,
                                    ruleSections: gameSystem.ruleSections
                                )
                            } label: {
                                Label(
                                    GameSystemRulesLabels.glossaryTitle(gameSystemId: gameSystemId),
                                    systemImage: "book.fill"
                                )
                                    .frame(minHeight: DesignTokens.minTouchTarget)
                            }
                        }
                    }

                    if gameSystemId == "wh40k-10e-cp" {
                        Section(String(localized: "Table Reference")) {
                            NavigationLink {
                                CombatPatrolMissionsReferenceView(ruleSections: gameSystem.ruleSections)
                            } label: {
                                Label(String(localized: "Missions Reference"), systemImage: "map")
                                    .frame(minHeight: DesignTokens.minTouchTarget)
                            }
                            .accessibilityHint(String(localized: "Six Combat Patrol missions, securing rules, and scoring"))
                            NavigationLink {
                                RulesGlossaryView(
                                    gameSystemId: gameSystemId,
                                    ruleSections: gameSystem.ruleSections
                                )
                            } label: {
                                Label(
                                    GameSystemRulesLabels.glossaryTitle(gameSystemId: gameSystemId),
                                    systemImage: "book.fill"
                                )
                                    .frame(minHeight: DesignTokens.minTouchTarget)
                            }
                        }
                    }

                    if let links = gameSystem.externalLinks, !links.isEmpty {
                        Section(String(localized: "Official Resources")) {
                            ForEach(links) { link in
                                Link(destination: link.url) {
                                    Label(link.title, systemImage: "arrow.up.right.square")
                                        .frame(minHeight: DesignTokens.minTouchTarget)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .tabBarScrollInset()
            } else if let errorMessage {
                EmptyStateView(title: String(localized: "Not Found"), message: errorMessage)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(verticalSizeClass == .compact ? .inline : .large)
        .task { await load() }
    }

    private var navigationTitle: String {
        guard let gameSystem else { return String(localized: "Game Guide") }
        if gameSystemId == "wh40k-11e" {
            return String(localized: "Warhammer 40,000")
        }
        if gameSystemId == "wh40k-10e-cp" {
            return String(localized: "Combat Patrol")
        }
        if gameSystemId == "sc-tmg" {
            return String(localized: "StarCraft")
        }
        return gameSystem.name
    }

    private var gettingStartedDetail: String {
        switch gameSystemId {
        case "wh40k-10e-cp":
            String(localized: "Pick a patrol box, a mission, and play five rounds")
        case "wh40k-11e":
            String(localized: "What you need, army building, and how a battle works")
        case "sc-tmg":
            String(localized: "Minerals, supply, reserves, and five battle rounds")
        default:
            String(localized: "Five-minute read — what you need and how a battle works")
        }
    }

    private var guidedMatchDetail: String {
        switch gameSystemId {
        case "sc-tmg":
            String(localized: "Raynor vs Kerrigan starter — activations, Pass, and supply tracking")
        default:
            String(localized: "Interactive setup and battle tracker — start with Use Starter Matchup")
        }
    }

    private var starterArmiesSectionTitle: String {
        gameSystemId == "sc-tmg"
            ? String(localized: "Founders Edition Armies")
            : String(localized: "Starter Set Armies")
    }

    private var starterArmiesSectionFooter: String {
        switch gameSystemId {
        case "sc-tmg":
            String(localized: "Rosters and battle tools for the Terran vs Zerg starter matchup.")
        case "wh40k-10e-cp":
            String(localized: "Rosters and setup tools for the Leviathan Combat Patrol starter armies.")
        default:
            String(localized: "Full warscrolls, abilities, and battle tools for the Skaventide starter armies.")
        }
    }

    private var editionMigrationLinkTitle: String {
        gameSystemId == "sc-tmg"
            ? String(localized: "RTS → Tabletop")
            : String(localized: "What's New in 11th Edition")
    }

    private var editionMigrationLinkDetail: String {
        gameSystemId == "sc-tmg"
            ? String(localized: "Supply, fog of war, and activations for SC II veterans")
            : String(localized: "Upgrading from 10th — key rule changes at the table")
    }

    private func guideRow(title: String, symbol: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Label(title, systemImage: symbol)
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
    }

    private func load() async {
        do {
            gameSystem = try await dependencies.rulesRepository.gameSystem(id: gameSystemId)
            guard let featuredArmyIds = dependencies.gameSystemRegistry.featuredArmies(
                for: GameSystemId(resolving: gameSystemId)
            )?.armyIds else {
                return
            }
            let catalog = try await dependencies.catalogRepository(
                for: GameSystemId(resolving: gameSystemId)
            ).loadCatalog()
            featuredArmies = featuredArmyIds.compactMap { armyId in
                catalog.factions.flatMap(\.armies).first { $0.id == armyId }
            }
        } catch {
            errorMessage = String(localized: "This game guide could not be loaded.")
        }
    }
}
