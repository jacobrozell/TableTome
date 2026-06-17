import SwiftUI
import TabletomeDomain

struct GameSystemDetailView: View {
    let gameSystemId: String
    @EnvironmentObject private var dependencies: AppDependencies
    @State private var gameSystem: GameSystem?
    @State private var featuredArmies: [SpearheadArmy] = []
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let gameSystem {
                List {
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

                    Section(String(localized: "Play")) {
                        NavigationLink {
                            GuidedMatchView(
                                viewModel: dependencies.makeGuidedMatchViewModel(),
                                ruleSections: gameSystem.ruleSections
                            )
                        } label: {
                            Label(String(localized: "Guided Match"), systemImage: "flag.checkered")
                                .frame(minHeight: DesignTokens.minTouchTarget)
                        }
                        .accessibilityIdentifier("guide.guidedMatch.\(gameSystemId)")

                        NavigationLink {
                            GettingStartedView(gameSystem: gameSystem)
                        } label: {
                            Label(String(localized: "Getting Started"), systemImage: "map")
                                .frame(minHeight: DesignTokens.minTouchTarget)
                        }
                        .accessibilityIdentifier("guide.gettingStarted.\(gameSystemId)")

                        if ReleaseSurface.showsRollEvaluator {
                            NavigationLink {
                                CombatRollEvaluatorView(ruleSections: gameSystem.ruleSections)
                            } label: {
                                Label(String(localized: "Roll Evaluator"), systemImage: "dice.fill")
                                    .frame(minHeight: DesignTokens.minTouchTarget)
                            }
                            .accessibilityIdentifier("guide.rollEvaluator.\(gameSystemId)")

                            NavigationLink {
                                UnitMatchupEvaluatorView(ruleSections: gameSystem.ruleSections)
                            } label: {
                                Label(String(localized: "Unit Matchup"), systemImage: "arrow.left.arrow.right")
                                    .frame(minHeight: DesignTokens.minTouchTarget)
                            }
                            .accessibilityIdentifier("guide.unitMatchup.\(gameSystemId)")
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
            } else if let errorMessage {
                EmptyStateView(title: String(localized: "Not Found"), message: errorMessage)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(gameSystem?.name ?? String(localized: "Game Guide"))
        .navigationBarTitleDisplayMode(.large)
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
