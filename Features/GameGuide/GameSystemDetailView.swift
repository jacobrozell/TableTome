import SwiftUI
import TabletomeDomain

struct GameSystemDetailView: View {
    let gameSystemId: String
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @EnvironmentObject private var dependencies: AppDependencies
    @Environment(AppRouter.self) private var router
    @State private var gameSystem: GameSystem?
    @State private var featuredArmyRows: [GameGuideFeaturedArmyRow] = []
    @State private var errorMessage: String?
    @State private var dismissedWrongGuideAlert = false

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    private var showsStartHereCard: Bool {
        playContext.capabilities.showsBattleTacticDecks
            || playContext.capabilities.deploymentChecklistStyle == .wh40k
            || playContext.capabilities.usesPatrolFormatRules
            || playContext.capabilities.showsActivationBar
    }

    private var showsWhatYouNeedCard: Bool {
        playContext.capabilities.showsBattleTacticDecks
            || playContext.capabilities.deploymentChecklistStyle == .wh40k
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
                GameSystemDetailContent(
                    gameSystemId: gameSystemId,
                    gameSystem: gameSystem,
                    playContext: playContext,
                    featuredArmyRows: featuredArmyRows,
                    wrongGuideAlert: wrongGuideAlert,
                    showsStartHereCard: showsStartHereCard,
                    showsWhatYouNeedCard: showsWhatYouNeedCard,
                    onOpenSuggestedGuide: {
                        if let wrongGuideAlert {
                            router.openGameGuide(gameSystemId: wrongGuideAlert.suggestedGameSystemId)
                        }
                    },
                    onDismissWrongGuideAlert: { dismissedWrongGuideAlert = true }
                )
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
            router.setActiveGameSystem(gameSystemId)
            FirstSessionStore.recordGameGuideOpened()
            await load()
        }
    }

    private var navigationTitle: String {
        guard gameSystem != nil else { return String(localized: "Game Guide") }
        if playContext.capabilities.showsBattleTacticDecks {
            return String(localized: "Spearhead")
        }
        if playContext.capabilities.deploymentChecklistStyle == .wh40k {
            return String(localized: "Warhammer 40,000")
        }
        if playContext.capabilities.usesPatrolFormatRules {
            return String(localized: "Combat Patrol (10th Edition)")
        }
        if playContext.capabilities.showsActivationBar {
            return String(localized: "StarCraft")
        }
        return gameSystem?.name ?? String(localized: "Game Guide")
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
                    .map { GameGuideFeaturedArmyRow(factionName: faction.name, army: $0) }
            }
        } catch {
            errorMessage = String(localized: "This game guide could not be loaded.")
        }
    }
}
