import SwiftUI
import TabletomeDomain

struct GameSystemDetailView: View {
    let gameSystemId: String
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
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
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                Label(String(localized: "Getting Started"), systemImage: "map")
                                Text(String(localized: "Five-minute read — what you need and how a battle works"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                        }
                        .accessibilityIdentifier("guide.gettingStarted.\(gameSystemId)")

                        NavigationLink {
                            GuidedMatchView(
                                viewModel: dependencies.makeGuidedMatchViewModel(),
                                ruleSections: gameSystem.ruleSections
                            )
                        } label: {
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                Label(String(localized: "Guided Match"), systemImage: "flag.checkered")
                                Text(String(localized: "Interactive setup and battle tracker — start with Use Starter Matchup"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                        }
                        .accessibilityIdentifier("guide.guidedMatch.\(gameSystemId)")

                        if ReleaseSurface.showsRollEvaluator {
                            NavigationLink {
                                UnitMatchupEvaluatorView(ruleSections: gameSystem.ruleSections)
                            } label: {
                                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                    Label(String(localized: "Combat Resolver"), systemImage: "dice.fill")
                                    Text(String(localized: "Practice attack dice math between games"))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                            }
                            .accessibilityIdentifier("guide.combatResolver.\(gameSystemId)")
                        }
                    } header: {
                        Text(String(localized: "Play"))
                    } footer: {
                        if gameSystemId == "aos-spearhead" {
                            Text(String(localized: "New to a term? Open Rules Glossary under Table Reference."))
                        }
                    }

                    if gameSystemId == "aos-spearhead" {
                        Section(String(localized: "Table Reference")) {
                            NavigationLink {
                                BattleTacticsReferenceView(ruleSections: gameSystem.ruleSections)
                            } label: {
                                Label(String(localized: "Battle Tactics & Twists"), systemImage: "rectangle.stack")
                                    .frame(minHeight: DesignTokens.minTouchTarget)
                            }
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
        .navigationTitle(gameSystem?.name ?? String(localized: "Game Guide"))
        .navigationBarTitleDisplayMode(horizontalSizeClass == .regular ? .large : .inline)
        .task { await load() }
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
