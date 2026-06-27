import SwiftUI
import TabletomeDomain

struct GameSystemDetailView: View {
    let gameSystemId: String
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @EnvironmentObject private var dependencies: AppDependencies
    @EnvironmentObject private var learnNavigationCoordinator: LearnNavigationCoordinator
    @State private var gameSystem: GameSystem?
    @State private var featuredArmyRows: [FeaturedArmyRow] = []
    @State private var errorMessage: String?
    @State private var dismissedWrongGuideAlert = false

    private struct FeaturedArmyRow: Identifiable {
        let factionName: String
        let army: SpearheadArmy
        var id: String { army.id }
    }

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    private var showsStartHereCard: Bool {
        playContext.isSpearhead
            || playContext.isWh40k11e
            || playContext.isCombatPatrol
            || playContext.isStarCraft
    }

    private var wrongGuideAlert: WrongGuideAlert? {
        guard !dismissedWrongGuideAlert else { return nil }
        return WrongGuideResolver.alert(
            currentGameSystemId: gameSystemId,
            onboardingChoice: FirstSessionStore.onboardingChoice,
            wh40kVariant: FirstSessionStore.onboardingWh40kVariant
        )
    }

    var body: some View {
        Group {
            if let gameSystem {
                List {
                    if let wrongGuideAlert {
                        Section {
                            WrongGuideBanner(
                                alert: wrongGuideAlert,
                                onOpenSuggestedGuide: {
                                    learnNavigationCoordinator.openGameGuide(
                                        gameSystemId: wrongGuideAlert.suggestedGameSystemId
                                    )
                                },
                                onDismiss: {
                                    dismissedWrongGuideAlert = true
                                }
                            )
                            .listHeroCardRow()
                        }
                    }

                    if playContext.isSpearhead {
                        Section {
                            NewPlayerStartHereCard()
                                .listHeroCardRow()
                        }

                        Section {
                            WhatYouNeedCard()
                                .listHeroCardRow()
                        }
                    }

                    if playContext.isWh40k11e {
                        Section {
                            FortyKStartHereCard(gameSystem: gameSystem)
                                .listHeroCardRow()
                        }

                        Section {
                            Wh40k11eWhatYouNeedCard()
                                .listHeroCardRow()
                        }
                    }

                    if playContext.isCombatPatrol {
                        Section {
                            CombatPatrolStartHereCard(gameSystem: gameSystem)
                                .listHeroCardRow()
                        }
                    }

                    if playContext.isStarCraft {
                        Section {
                            ScStartHereCard(gameSystem: gameSystem)
                                .listHeroCardRow()
                        }
                    }

                    if playContext.isWh40k11e, !featuredArmyRows.isEmpty {
                        Section {
                            ForEach(featuredArmyRows) { row in
                                NavigationLink(value: ArmyRosterLink(gameSystemId: gameSystemId, armyId: row.army.id)) {
                                    starterArmyRow(factionName: row.factionName, army: row.army)
                                }
                                .accessibilityIdentifier("guide.armyRoster.\(row.army.id)")
                            }
                        } header: {
                            Text(String(localized: "Starter Set Armies"))
                        } footer: {
                            Text(String(localized: "Datasheets, abilities, and battle tools for the Armageddon launch box armies."))
                        }
                    }

                    if playContext.isSpearhead || playContext.isStarCraft || playContext.isCombatPatrol,
                       !featuredArmyRows.isEmpty {
                        Section {
                            ForEach(featuredArmyRows) { row in
                                NavigationLink(value: ArmyRosterLink(gameSystemId: gameSystemId, armyId: row.army.id)) {
                                    starterArmyRow(factionName: row.factionName, army: row.army)
                                }
                                .accessibilityIdentifier("guide.armyRoster.\(row.army.id)")
                            }
                        } header: {
                            Text(starterArmiesSectionTitle)
                        } footer: {
                            Text(starterArmiesSectionFooter)
                        }
                    }

                    Section {
                        if !showsStartHereCard {
                            NavigationLink(value: GettingStartedLink(gameSystemId: gameSystemId)) {
                                guideRow(
                                    title: String(localized: "Getting Started"),
                                    symbol: "map",
                                    detail: gettingStartedDetail
                                )
                            }
                            .accessibilityIdentifier("guide.gettingStarted.\(gameSystemId)")

                            if playContext.isCombatPatrol {
                                NavigationLink(value: CombatPatrolSampleTurnLink()) {
                                    guideRow(
                                        title: String(localized: "Preview a Turn"),
                                        symbol: "play.circle",
                                        detail: String(localized: "~2 minutes — each battle phase, dice, and scoring")
                                    )
                                }
                                .accessibilityIdentifier("guide.combatPatrolSampleTurn.\(gameSystemId)")
                            }

                            if !gameSystem.editionMigrationSteps.isEmpty {
                                NavigationLink(value: EditionMigrationLink(gameSystemId: gameSystemId)) {
                                    guideRow(
                                        title: editionMigrationLinkTitle,
                                        symbol: playContext.isStarCraft ? "gamecontroller" : "arrow.triangle.2.circlepath",
                                        detail: editionMigrationLinkDetail
                                    )
                                }
                                .accessibilityIdentifier("guide.whatsNew.\(gameSystemId)")
                            }

                            if ReleaseSurface.showsGuidedMatch(for: gameSystemId), !showsStartHereCard {
                                NavigationLink(value: GuidedMatchLink(gameSystemId: GameSystemId(resolving: gameSystemId))) {
                                    guideRow(
                                        title: String(localized: "Guided Match"),
                                        symbol: "flag.checkered",
                                        detail: guidedMatchDetail
                                    )
                                }
                                .accessibilityIdentifier("guide.guidedMatch.\(gameSystemId)")
                            }
                        }

                        if !gameSystem.ruleSections.isEmpty, !playContext.isStarCraft {
                            NavigationLink(value: GameSystemRulesReferenceLink(gameSystemId: gameSystemId)) {
                                guideRow(
                                    title: GameSystemRulesLabels.rulesReferenceLinkTitle(gameSystemId: gameSystemId),
                                    symbol: "doc.text.fill",
                                    detail: String(localized: "Search phases, combat, terrain, and glossary")
                                )
                            }
                            .accessibilityIdentifier("guide.rulesReference.\(gameSystemId)")
                        }

                        if ReleaseSurface.showsCombatResolver(for: gameSystemId) {
                            NavigationLink(value: CombatResolverLink(gameSystemId: gameSystemId)) {
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
                        Text(showsStartHereCard ? String(localized: "More") : String(localized: "Play"))
                    } footer: {
                        if showsStartHereCard {
                            Text(String(localized: "Use Start here above for your first path. These links are for rules lookup and optional tools."))
                        } else if playContext.isSpearhead {
                            Text(String(localized: "New to a term? Open AoS Glossary under Table Reference."))
                        } else if playContext.isWh40k11e {
                            Text(
                                String(
                                    localized: """
                                    Use Guided Match for the Armageddon starter matchup, or browse all factions \
                                    in army selection.
                                    """
                                )
                            )
                        } else if playContext.isCombatPatrol {
                            Text(
                                String(
                                    localized: """
                                    Start with Getting Started, then open Missions Reference before your first game. \
                                    Guided Match walks through setup and includes a starter matchup.
                                    """
                                )
                            )
                        } else if playContext.isStarCraft {
                            Text(String(localized: "Start with Use Starter Matchup for the 2-Player Founders Edition."))
                        }
                    }

                    if playContext.isSpearhead {
                        Section(String(localized: "Table Reference")) {
                            NavigationLink(value: BattleTacticsReferenceLink(gameSystemId: gameSystemId)) {
                                Label(String(localized: "Card Decks Guide"), systemImage: "rectangle.stack")
                                    .frame(minHeight: DesignTokens.minTouchTarget)
                            }
                            .accessibilityHint(String(localized: "Twist cards vs battle tactic cards — which deck is which"))
                            NavigationLink(value: RulesGlossaryBrowseLink(gameSystemId: gameSystemId)) {
                                Label(
                                    GameSystemRulesLabels.glossaryTitle(gameSystemId: gameSystemId),
                                    systemImage: "book.fill"
                                )
                                    .frame(minHeight: DesignTokens.minTouchTarget)
                            }
                        }
                    }

                    if playContext.isWh40k11e || playContext.isStarCraft {
                        Section(String(localized: "Table Reference")) {
                            NavigationLink(value: RulesGlossaryBrowseLink(gameSystemId: gameSystemId)) {
                                Label(
                                    GameSystemRulesLabels.glossaryTitle(gameSystemId: gameSystemId),
                                    systemImage: "book.fill"
                                )
                                    .frame(minHeight: DesignTokens.minTouchTarget)
                            }
                            if playContext.isStarCraft {
                                NavigationLink(value: GameSystemRulesReferenceLink(gameSystemId: gameSystemId)) {
                                    Label(
                                        GameSystemRulesLabels.rulesReferenceLinkTitle(gameSystemId: gameSystemId),
                                        systemImage: "doc.text.fill"
                                    )
                                        .frame(minHeight: DesignTokens.minTouchTarget)
                                }
                            }
                        }
                    }

                    if playContext.isCombatPatrol {
                        Section(String(localized: "Table Reference")) {
                            NavigationLink(value: CombatPatrolMissionsLink(gameSystemId: gameSystemId)) {
                                Label(String(localized: "Missions Reference"), systemImage: "map")
                                    .frame(minHeight: DesignTokens.minTouchTarget)
                            }
                            .accessibilityHint(String(localized: "Six Combat Patrol missions, securing rules, and scoring"))
                            NavigationLink(value: RulesGlossaryBrowseLink(gameSystemId: gameSystemId)) {
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
                .floatingCardListStyle()
                .tabBarScrollInset()
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Game guide unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading game guide…"))
                    .asyncContentShell()
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(verticalSizeClass == .compact ? .inline : .large)
        .task(id: gameSystemId) {
            dismissedWrongGuideAlert = false
            ActiveGameContextStore.setActiveGameSystem(gameSystemId)
            FirstSessionStore.recordGameGuideOpened()
            await load()
        }
    }

    private var navigationTitle: String {
        guard gameSystem != nil else { return String(localized: "Game Guide") }
        if playContext.isSpearhead {
            return String(localized: "Spearhead")
        }
        if playContext.isWh40k11e {
            return String(localized: "Warhammer 40,000")
        }
        if playContext.isCombatPatrol {
            return String(localized: "Combat Patrol (10th Edition)")
        }
        if playContext.isStarCraft {
            return String(localized: "StarCraft")
        }
        return gameSystem?.name ?? String(localized: "Game Guide")
    }

    private var gettingStartedDetail: String {
        if playContext.isCombatPatrol {
            return String(localized: "Pick a patrol box, a mission, and play five rounds")
        }
        if playContext.isWh40k11e {
            return String(localized: "What you need, army building, and how a battle works")
        }
        if playContext.isStarCraft {
            return String(localized: "Minerals, supply, reserves, and five battle rounds")
        }
        return String(localized: "Five-minute read — what you need and how a battle works")
    }

    private var guidedMatchDetail: String {
        if playContext.isStarCraft {
            return String(localized: "Raynor vs Kerrigan starter — activations, Pass, and supply tracking")
        }
        return String(localized: "Interactive setup and battle tracker — start with Use Starter Matchup")
    }

    private var starterArmiesSectionTitle: String {
        playContext.isStarCraft
            ? String(localized: "Founders Edition Armies")
            : String(localized: "Starter Set Armies")
    }

    private var starterArmiesSectionFooter: String {
        if playContext.isStarCraft {
            return String(localized: "Rosters and battle tools for the Terran vs Zerg starter matchup.")
        }
        if playContext.isCombatPatrol {
            return String(localized: "Rosters and setup tools for Combat Patrol starter armies.")
        }
        return String(localized: "Unit profiles, abilities, and battle tools for the starter armies in your box.")
    }

    private var editionMigrationLinkTitle: String {
        playContext.isStarCraft
            ? String(localized: "RTS → Tabletop")
            : String(localized: "What's New in 11th Edition")
    }

    private var editionMigrationLinkDetail: String {
        playContext.isStarCraft
            ? String(localized: "Supply, fog of war, and activations for SC II veterans")
            : String(localized: "Upgrading from 10th — key rule changes at the table")
    }

    private func starterArmyRow(factionName: String, army: SpearheadArmy) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.title3)
                .foregroundStyle(Color.accentOnSurface)
                .symbolRenderingMode(.hierarchical)
                .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(factionName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.accentOnSurface)
                Text(army.name)
                    .font(.headline)
                Text(army.general)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
        .contentShape(Rectangle())
    }

    private func guideRow(title: String, symbol: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(Color.accentOnSurface)
                .symbolRenderingMode(.hierarchical)
                .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
        .contentShape(Rectangle())
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
            featuredArmyRows = catalog.factions.flatMap { faction in
                faction.armies
                    .filter { featuredArmyIds.contains($0.id) }
                    .map { FeaturedArmyRow(factionName: faction.name, army: $0) }
            }
        } catch {
            errorMessage = String(localized: "This game guide could not be loaded.")
        }
    }
}
