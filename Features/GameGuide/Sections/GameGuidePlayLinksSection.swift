import SwiftUI
import TabletomeDomain

struct GameGuidePlayLinksSection: View {
    let gameSystemId: String
    let gameSystem: GameSystem
    let playContext: GameSystemPlayContext
    let showsStartHereCard: Bool
    let gettingStartedDetail: String
    let editionMigrationLinkTitle: String
    let editionMigrationLinkDetail: String
    let guidedMatchDetail: String

    var body: some View {
        Section {
            if !showsStartHereCard {
                NavigationLink(value: GettingStartedLink(gameSystemId: gameSystemId)) {
                    GameGuideNavigationRow(
                        title: String(localized: "Getting Started"),
                        symbol: "map",
                        detail: gettingStartedDetail
                    )
                }
                .accessibilityIdentifier("guide.gettingStarted.\(gameSystemId)")

                if playContext.capabilities.usesPatrolFormatRules {
                    NavigationLink(value: CombatPatrolSampleTurnLink()) {
                        GameGuideNavigationRow(
                            title: String(localized: "Preview a Turn"),
                            symbol: "play.circle",
                            detail: String(localized: "~2 minutes — each battle phase, dice, and scoring")
                        )
                    }
                    .accessibilityIdentifier("guide.combatPatrolSampleTurn.\(gameSystemId)")
                }

                if !gameSystem.editionMigrationSteps.isEmpty {
                    NavigationLink(value: EditionMigrationLink(gameSystemId: gameSystemId)) {
                        GameGuideNavigationRow(
                            title: editionMigrationLinkTitle,
                            symbol: playContext.capabilities.showsActivationBar ? "gamecontroller" : "arrow.triangle.2.circlepath",
                            detail: editionMigrationLinkDetail
                        )
                    }
                    .accessibilityIdentifier("guide.whatsNew.\(gameSystemId)")
                }

                if ReleaseSurface.showsGuidedMatch(for: gameSystemId), !showsStartHereCard {
                    NavigationLink(value: GuidedMatchLink(gameSystemId: GameSystemId(resolving: gameSystemId))) {
                        GameGuideNavigationRow(
                            title: String(localized: "Guided Match"),
                            symbol: "flag.checkered",
                            detail: guidedMatchDetail
                        )
                    }
                    .accessibilityIdentifier("guide.guidedMatch.\(gameSystemId)")
                }
            }

            if !gameSystem.ruleSections.isEmpty, !playContext.capabilities.showsActivationBar {
                NavigationLink(value: GameSystemRulesReferenceLink(gameSystemId: gameSystemId)) {
                    GameGuideNavigationRow(
                        title: GameSystemRulesLabels.rulesReferenceLinkTitle(gameSystemId: gameSystemId),
                        symbol: "doc.text.fill",
                        detail: String(localized: "Search phases, combat, terrain, and glossary")
                    )
                }
                .accessibilityIdentifier("guide.rulesReference.\(gameSystemId)")
            }

            if ReleaseSurface.showsCombatResolver(for: gameSystemId) {
                NavigationLink(value: CombatResolverLink(gameSystemId: gameSystemId)) {
                    GameGuideNavigationRow(
                        title: String(localized: "Combat Resolver"),
                        symbol: "dice.fill",
                        detail: playContext.capabilities.usesPatrolFormatRules
                            ? String(localized: "Resolve hit, wound, and save rolls at the table")
                            : String(localized: "Practice attack dice math between games")
                    )
                }
                .accessibilityIdentifier("guide.combatResolver.\(gameSystemId)")
            }
        } header: {
            Text(showsStartHereCard ? String(localized: "More") : String(localized: "Play"))
        } footer: {
            Text(sectionFooter)
        }
    }

    private var sectionFooter: String {
        if showsStartHereCard {
            return String(localized: "Use Start here above for your first path. These links are for rules lookup and optional tools.")
        }
        if playContext.capabilities.showsBattleTacticDecks {
            return String(localized: "New to a term? Open AoS Glossary under Table Reference.")
        }
        if playContext.capabilities.deploymentChecklistStyle == .wh40k {
            return String(
                localized: """
                Use Guided Match for the Armageddon starter matchup, or browse all factions \
                in army selection.
                """
            )
        }
        if playContext.capabilities.usesPatrolFormatRules {
            return String(
                localized: """
                Start with Getting Started, then open Missions Reference before your first game. \
                Guided Match walks through setup and includes a starter matchup.
                """
            )
        }
        if playContext.capabilities.showsActivationBar {
            return String(localized: "Start with Use Starter Matchup for the 2-Player Founders Edition.")
        }
        return ""
    }
}
