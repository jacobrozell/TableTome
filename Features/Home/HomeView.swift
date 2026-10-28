import SwiftUI
import TabletomeDomain

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject private var dependencies: AppDependencies
    @Environment(AppRouter.self) private var router
    @State private var showsMatchHistoryToolbar = false
    @State private var firstSessionRevision = 0
    /// Keeps the Play hero section stable while `learnPath` pushes Guided Match — swapping cards mid-push pops the stack.
    @State private var frozenHeroPresentation: HeroPresentation?

    private enum HeroPresentation: Equatable {
        case continuation(PlayContinuation)
        case chooser
    }

    private var showsAllGamesList: Bool {
        _ = firstSessionRevision
        guard router.learnPath.isEmpty else { return false }
        guard viewModel.gameSystems.count > 1 else { return false }
        if PlayContinuationResolver.current(activeGameSystemId: router.activeGameSystemId) != nil {
            return true
        }
        return !FirstSessionStore.shouldHideAllGamesList()
    }

    private var allGamesSectionHeader: String {
        if router.learnPath.isEmpty,
           PlayContinuationResolver.current(activeGameSystemId: router.activeGameSystemId) != nil {
            String(localized: "Or pick a different game")
        } else {
            String(localized: "All games")
        }
    }

    private var allGamesSectionFooter: String? {
        if router.learnPath.isEmpty,
           PlayContinuationResolver.current(activeGameSystemId: router.activeGameSystemId) != nil {
            String(localized: "Your in-progress match stays saved — you can resume anytime from Play.")
        } else {
            String(localized: "Not sure which to pick? Start with the chooser above.")
        }
    }

    private var heroPresentation: HeroPresentation? {
        if !router.learnPath.isEmpty {
            return frozenHeroPresentation
        }
        if let continuation = PlayContinuationResolver.current(activeGameSystemId: router.activeGameSystemId) {
            return .continuation(continuation)
        }
        return .chooser
    }

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.gameSystems.isEmpty {
                ProgressView(String(localized: "Loading guides…"))
                    .asyncContentShell()
                    .accessibilityIdentifier("home.loading")
            } else if let error = viewModel.errorMessage {
                EmptyStateView(
                    title: String(localized: "Unable to Load"),
                    message: error,
                    systemImage: "exclamationmark.triangle",
                    actionTitle: String(localized: "Retry"),
                    action: { Task { await viewModel.load() } }
                )
                .asyncContentShell()
            } else if viewModel.gameSystems.count == 1, let system = viewModel.gameSystems.first {
                SingleGameHomeView(gameSystem: system) {
                    await viewModel.load()
                }
            } else {
                multiGameList
            }
        }
        .navigationTitle(String(localized: "Play"))
        .navigationDestination(for: String.self) { systemId in
            GameSystemDetailView(gameSystemId: systemId)
        }
        .playNavigationDestinations()
        .glossaryEntryNavigation()
        .toolbar {
            if ReleaseSurface.showsPlayersHub {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: PlayersHubLink()) {
                        Label(String(localized: "Players"), systemImage: "person.2")
                    }
                    .accessibilityIdentifier("home.playersHub")
                    .accessibilityHint(String(localized: "Household players, owned armies, and match stats"))
                }
            }
            if ReleaseSurface.showsMatchHistory, showsMatchHistoryToolbar, viewModel.gameSystems.count != 1 {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: MatchHistoryLink()) {
                        Label(String(localized: "History"), systemImage: "clock.arrow.circlepath")
                    }
                    .accessibilityIdentifier("home.matchHistory")
                    .accessibilityHint(String(localized: "Past guided matches with scores and turn logs"))
                }
            }
        }
        .task {
            await viewModel.load()
            if viewModel.errorMessage == nil, !viewModel.gameSystems.isEmpty {
                dependencies.logger.info(
                    .ui,
                    eventName: "play_home_ready",
                    message: "Play home loaded.",
                    metadata: [
                        "eventCount": String(viewModel.gameSystems.count),
                        "source": ProcessInfo.processInfo.arguments.contains("-open_guided_match")
                            ? "automation"
                            : "launch"
                    ]
                )
            }
            showsMatchHistoryToolbar = await MatchHistoryVisibility.showsToolbar(
                repository: dependencies.matchHistoryRepository
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .firstSessionStoreDidChange)) { _ in
            firstSessionRevision += 1
        }
        .onChange(of: router.learnPath.count) { _, count in
            if count > 0, frozenHeroPresentation == nil {
                if let continuation = PlayContinuationResolver.current(
                    activeGameSystemId: router.activeGameSystemId
                ) {
                    frozenHeroPresentation = .continuation(continuation)
                } else {
                    frozenHeroPresentation = .chooser
                }
            } else if count == 0 {
                frozenHeroPresentation = nil
            }
        }
        .refreshable { await viewModel.load() }
    }

    private var multiGameList: some View {
        List {
            if !viewModel.gameSystems.isEmpty {
                if let heroPresentation {
                    Section {
                        switch heroPresentation {
                        case .continuation(let continuation):
                            HomeContinueCard(continuation: continuation)
                        case .chooser:
                            HomeNewPlayerChooserCard()
                        }
                    }
                }

                if ReleaseSurface.showsPlayersHub {
                    Section {
                        HomePlayersHubCard()
                    }
                }
            }

            if showsAllGamesList {
                Section {
                    ForEach(viewModel.gameSystems) { system in
                        NavigationLink(value: system.id) {
                            gameSystemRow(system)
                        }
                        .accessibilityIdentifier("home.gameSystem.\(system.id)")
                    }
                } header: {
                    TTSectionHeader(allGamesSectionHeader)
                } footer: {
                    if let allGamesSectionFooter {
                        Text(allGamesSectionFooter)
                    }
                }
            }
        }
        .ttCardList()
        .tabBarScrollInset()
        .accessibilityIdentifier("home.gameSystemList")
    }

    private func gameSystemRow(_ system: GameSystem) -> some View {
        TTRow(
            title: system.name,
            subtitle: newcomerTagline(for: system),
            systemImage: GameSystemSymbol.systemImage(for: system.id)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(homeRowAccessibilityLabel(for: system))
    }

    private func homeRowAccessibilityLabel(for system: GameSystem) -> String {
        var parts = [system.name]
        if system.id == GameSystemId.wh40k10eCp.rawValue {
            parts.append(String(localized: "10th Edition"))
        } else if ReleaseSurface.showsNewEditionBadge(for: system.id) {
            parts.append(String(localized: "New edition"))
        }
        parts.append(contentsOf: [newcomerTagline(for: system), system.edition])
        return parts.joined(separator: ". ")
    }

    private func newcomerTagline(for system: GameSystem) -> String {
        if system.id == "aos-spearhead" {
            return String(localized: "Your Spearhead starter box")
        }
        if system.id == "wh40k-11e" {
            return String(localized: "11th Edition — Armageddon box or your own lists")
        }
        if system.id == "wh40k-10e-cp" {
            return String(localized: "10th Edition patrol — box says Combat Patrol")
        }
        if system.id == "sc-tmg" {
            return String(localized: "StarCraft on the tabletop — Founders Edition")
        }
        return system.tagline
    }

    private func editionFootnote(for system: GameSystem) -> String? {
        if system.id == "aos-spearhead" {
            return nil
        }
        if system.id == "wh40k-10e-cp" {
            return String(localized: "Uses 10th Edition Combat Patrol rules")
        }
        if system.id == "wh40k-11e" {
            return String(localized: "Free core rules + Chapter Approved missions")
        }
        if system.id == "sc-tmg" {
            return String(localized: "Alternating activations — supply and objective scoring")
        }
        return nil
    }
}
