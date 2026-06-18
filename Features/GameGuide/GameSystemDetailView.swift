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

                    if gameSystemId == "aos-spearhead", !featuredArmies.isEmpty {
                        Section {
                            ForEach(featuredArmies) { army in
                                NavigationLink {
                                    ArmyRosterView(army: army, ruleSections: gameSystem.ruleSections)
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
                            Text(String(localized: "Full warscrolls, abilities, and battle tools for the Skaventide starter armies."))
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

                        if !gameSystem.editionMigrationSteps.isEmpty {
                            NavigationLink {
                                EditionMigrationView(gameSystem: gameSystem)
                            } label: {
                                guideRow(
                                    title: String(localized: "What's New in 11th Edition"),
                                    symbol: "arrow.triangle.2.circlepath",
                                    detail: String(localized: "Upgrading from 10th — key rule changes at the table")
                                )
                            }
                            .accessibilityIdentifier("guide.whatsNew.\(gameSystemId)")
                        }

                        if !gameSystem.ruleSections.isEmpty {
                            NavigationLink {
                                GameSystemRulesReferenceView(gameSystem: gameSystem)
                            } label: {
                                guideRow(
                                    title: String(localized: "Rules Reference"),
                                    symbol: "doc.text.fill",
                                    detail: String(localized: "Search phases, combat, terrain, and glossary")
                                )
                            }
                            .accessibilityIdentifier("guide.rulesReference.\(gameSystemId)")
                        }

                        if ReleaseSurface.showsGuidedMatch(for: gameSystemId) {
                            NavigationLink {
                                GuidedMatchView(
                                    viewModel: dependencies.makeGuidedMatchViewModel(),
                                    ruleSections: gameSystem.ruleSections
                                )
                            } label: {
                                guideRow(
                                    title: String(localized: "Guided Match"),
                                    symbol: "flag.checkered",
                                    detail: String(localized: "Interactive setup and battle tracker — start with Use Starter Matchup")
                                )
                            }
                            .accessibilityIdentifier("guide.guidedMatch.\(gameSystemId)")
                        }

                        if ReleaseSurface.showsCombatResolver(for: gameSystemId) {
                            NavigationLink {
                                UnitMatchupEvaluatorView(ruleSections: gameSystem.ruleSections)
                            } label: {
                                guideRow(
                                    title: String(localized: "Combat Resolver"),
                                    symbol: "dice.fill",
                                    detail: String(localized: "Practice attack dice math between games")
                                )
                            }
                            .accessibilityIdentifier("guide.combatResolver.\(gameSystemId)")
                        }
                    } header: {
                        Text(String(localized: "Play"))
                    } footer: {
                        if gameSystemId == "aos-spearhead" {
                            Text(String(localized: "New to a term? Open Rules Glossary under Table Reference."))
                        } else if gameSystemId == "wh40k-11e" {
                            Text(String(localized: "Guided Match for Armageddon arrives in a future update. Use Getting Started and Rules Reference for now."))
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
                                RulesGlossaryView()
                            } label: {
                                Label(String(localized: "Rules Glossary"), systemImage: "book.fill")
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
        return gameSystem.name
    }

    private var gettingStartedDetail: String {
        switch gameSystemId {
        case "wh40k-11e":
            String(localized: "What you need, army building, and how a battle works")
        default:
            String(localized: "Five-minute read — what you need and how a battle works")
        }
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
            if gameSystemId == "aos-spearhead" {
                let catalog = try await dependencies.spearheadCatalogRepository.loadCatalog()
                featuredArmies = SpearheadFeaturedArmies.armyIds.compactMap { armyId in
                    catalog.factions.flatMap(\.armies).first { $0.id == armyId }
                }
            }
        } catch {
            errorMessage = String(localized: "This game guide could not be loaded.")
        }
    }
}
