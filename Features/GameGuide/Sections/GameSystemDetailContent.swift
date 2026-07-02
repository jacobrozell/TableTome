import SwiftUI
import TabletomeDomain

struct GameSystemDetailContent: View {
    let gameSystemId: String
    let gameSystem: GameSystem
    let playContext: GameSystemPlayContext
    let featuredArmyRows: [GameGuideFeaturedArmyRow]
    let wrongGuideAlert: WrongGuideAlert?
    let showsStartHereCard: Bool
    let showsWhatYouNeedCard: Bool
    let onOpenSuggestedGuide: () -> Void
    let onDismissWrongGuideAlert: () -> Void

    var body: some View {
        List {
            if let wrongGuideAlert {
                Section {
                    WrongGuideBanner(
                        alert: wrongGuideAlert,
                        onOpenSuggestedGuide: onOpenSuggestedGuide,
                        onDismiss: onDismissWrongGuideAlert
                    )
                    .listHeroCardRow()
                }
            }

            if showsStartHereCard {
                Section {
                    GameGuideStartHereCard(gameSystem: gameSystem)
                        .listHeroCardRow()
                }
            }

            if showsWhatYouNeedCard {
                Section {
                    GameGuideWhatYouNeedCard(gameSystemId: gameSystemId)
                        .listHeroCardRow()
                }
            }

            if playContext.capabilities.deploymentChecklistStyle == .wh40k, !featuredArmyRows.isEmpty {
                GameGuideWh40kStarterArmiesSection(
                    gameSystemId: gameSystemId,
                    featuredArmyRows: featuredArmyRows
                )
            }

            if playContext.capabilities.showsBattleTacticDecks || playContext.capabilities.showsActivationBar || playContext.capabilities.usesPatrolFormatRules,
               !featuredArmyRows.isEmpty {
                GameGuideFeaturedArmiesSection(
                    gameSystemId: gameSystemId,
                    featuredArmyRows: featuredArmyRows,
                    sectionTitle: starterArmiesSectionTitle,
                    sectionFooter: starterArmiesSectionFooter
                )
            }

            GameGuidePlayLinksSection(
                gameSystemId: gameSystemId,
                gameSystem: gameSystem,
                playContext: playContext,
                showsStartHereCard: showsStartHereCard,
                gettingStartedDetail: gettingStartedDetail,
                editionMigrationLinkTitle: editionMigrationLinkTitle,
                editionMigrationLinkDetail: editionMigrationLinkDetail,
                guidedMatchDetail: guidedMatchDetail
            )

            if playContext.capabilities.showsBattleTacticDecks {
                GameGuideSpearheadTableReferenceSection(gameSystemId: gameSystemId)
            }

            if playContext.capabilities.deploymentChecklistStyle == .wh40k || playContext.capabilities.showsActivationBar {
                GameGuideWh40kTableReferenceSection(
                    gameSystemId: gameSystemId,
                    showsActivationBar: playContext.capabilities.showsActivationBar
                )
            }

            if playContext.capabilities.usesPatrolFormatRules {
                GameGuideCombatPatrolTableReferenceSection(gameSystemId: gameSystemId)
            }

            if let links = gameSystem.externalLinks, !links.isEmpty {
                GameGuideExternalResourcesSection(links: links)
            }
        }
        .floatingCardListStyle()
        .tabBarScrollInset()
    }

    private var gettingStartedDetail: String {
        if playContext.capabilities.usesPatrolFormatRules {
            return String(localized: "Pick a patrol box, a mission, and play five rounds")
        }
        if playContext.capabilities.deploymentChecklistStyle == .wh40k {
            return String(localized: "What you need, army building, and how a battle works")
        }
        if playContext.capabilities.showsActivationBar {
            return String(localized: "Minerals, supply, reserves, and five battle rounds")
        }
        return String(localized: "Five-minute read — what you need and how a battle works")
    }

    private var guidedMatchDetail: String {
        if playContext.capabilities.showsActivationBar {
            return String(localized: "Raynor vs Kerrigan starter — activations, Pass, and supply tracking")
        }
        return String(localized: "Interactive setup and battle tracker — start with Use Starter Matchup")
    }

    private var starterArmiesSectionTitle: String {
        playContext.capabilities.showsActivationBar
            ? String(localized: "Founders Edition Armies")
            : String(localized: "Starter Set Armies")
    }

    private var starterArmiesSectionFooter: String {
        if playContext.capabilities.showsActivationBar {
            return String(localized: "Rosters and battle tools for the Terran vs Zerg starter matchup.")
        }
        if playContext.capabilities.usesPatrolFormatRules {
            return String(localized: "Rosters and setup tools for Combat Patrol starter armies.")
        }
        return String(localized: "Unit profiles, abilities, and battle tools for the starter armies in your box.")
    }

    private var editionMigrationLinkTitle: String {
        playContext.capabilities.showsActivationBar
            ? String(localized: "RTS → Tabletop")
            : String(localized: "What's New in 11th Edition")
    }

    private var editionMigrationLinkDetail: String {
        playContext.capabilities.showsActivationBar
            ? String(localized: "Supply, fog of war, and activations for SC II veterans")
            : String(localized: "Upgrading from 10th — key rule changes at the table")
    }
}
