import SwiftUI
import TabletomeDomain

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject private var dependencies: AppDependencies
    @Environment(AppRouter.self) private var router
    @State private var showsMatchHistoryToolbar = false
    @State private var firstSessionRevision = 0

    private var showsAllGamesList: Bool {
        _ = firstSessionRevision
        if PlayContinuationResolver.current(activeGameSystemId: router.activeGameSystemId) != nil {
            return true
        }
        return !FirstSessionStore.shouldHideAllGamesList()
    }

    private var allGamesSectionHeader: String {
        if PlayContinuationResolver.current(activeGameSystemId: router.activeGameSystemId) != nil {
            String(localized: "Or pick a different game")
        } else {
            String(localized: "All games")
        }
    }

    private var allGamesSectionFooter: String? {
        if PlayContinuationResolver.current(activeGameSystemId: router.activeGameSystemId) != nil {
            String(localized: "Your in-progress match stays saved — you can resume anytime from Play.")
        } else {
            String(localized: "Not sure which to pick? Start with the chooser above.")
        }
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
                    systemImage: "wifi.exclamationmark",
                    actionTitle: String(localized: "Retry"),
                    action: { Task { await viewModel.load() } }
                )
                .asyncContentShell()
            } else {
                List {
                    if !viewModel.gameSystems.isEmpty {
                        if let continuation = PlayContinuationResolver.current(
                            activeGameSystemId: router.activeGameSystemId
                        ) {
                            Section {
                                HomeContinueCard(continuation: continuation)
                                    .listHeroCardRow()
                            }
                        } else {
                            Section {
                                HomeNewPlayerChooserCard()
                                    .listHeroCardRow()
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
                            Text(allGamesSectionHeader)
                        } footer: {
                            if let allGamesSectionFooter {
                                Text(allGamesSectionFooter)
                            }
                        }
                    }
                }
                .floatingCardListStyle()
                .tabBarScrollInset()
                .accessibilityIdentifier("home.gameSystemList")
            }
        }
        .navigationTitle(String(localized: "Play"))
        .navigationDestination(for: String.self) { systemId in
            GameSystemDetailView(gameSystemId: systemId)
        }
        .playNavigationDestinations()
        .glossaryEntryNavigation()
        .toolbar {
            if ReleaseSurface.showsMatchHistory, showsMatchHistoryToolbar {
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
        .refreshable { await viewModel.load() }
    }

    private func gameSystemRow(_ system: GameSystem) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: GameSystemSymbol.systemImage(for: system.id))
                .font(.title2)
                .foregroundStyle(Color.accentOnSurface)
                .symbolRenderingMode(.hierarchical)
                .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                    Text(system.name)
                        .font(.headline)
                    if system.id == GameSystemId.wh40k10eCp.rawValue {
                        GuideBadge(style: .custom(String(localized: "10th Edition")))
                    } else if ReleaseSurface.showsNewEditionBadge(for: system.id) {
                        NewEditionBadge()
                    }
                }
                Text(newcomerTagline(for: system))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let footnote = editionFootnote(for: system) {
                    Text(footnote)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                Text(system.edition)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
        .contentShape(Rectangle())
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
            return String(localized: "Fantasy starter box — box says Spearhead")
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
            return String(localized: "Starter-box format — realm boards and battle tactics from your set")
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
