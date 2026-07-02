import SwiftUI
import TabletomeDomain

struct GameGuideSpearheadTableReferenceSection: View {
    let gameSystemId: String

    var body: some View {
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
}

struct GameGuideWh40kTableReferenceSection: View {
    let gameSystemId: String
    let showsActivationBar: Bool

    var body: some View {
        Section(String(localized: "Table Reference")) {
            NavigationLink(value: RulesGlossaryBrowseLink(gameSystemId: gameSystemId)) {
                Label(
                    GameSystemRulesLabels.glossaryTitle(gameSystemId: gameSystemId),
                    systemImage: "book.fill"
                )
                    .frame(minHeight: DesignTokens.minTouchTarget)
            }
            if showsActivationBar {
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
}

struct GameGuideCombatPatrolTableReferenceSection: View {
    let gameSystemId: String

    var body: some View {
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
}

struct GameGuideExternalResourcesSection: View {
    let links: [ExternalLink]

    var body: some View {
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
