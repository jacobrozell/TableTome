import SwiftUI
import SpearheadDomain

struct GameSystemDetailView: View {
    let gameSystemId: String
    @EnvironmentObject private var dependencies: AppDependencies
    @State private var gameSystem: GameSystem?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let gameSystem {
                List {
                    Section(String(localized: "Getting Started")) {
                        NavigationLink {
                            GettingStartedView(gameSystem: gameSystem)
                        } label: {
                            Label(String(localized: "Walkthrough"), systemImage: "map")
                                .frame(minHeight: DesignTokens.minTouchTarget)
                        }
                        .accessibilityIdentifier("guide.gettingStarted.\(gameSystemId)")
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
        } catch {
            errorMessage = String(localized: "This game guide could not be loaded.")
        }
    }
}
