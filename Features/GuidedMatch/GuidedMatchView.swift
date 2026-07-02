import SwiftUI
import TabletomeDomain
import TabletomeData

// swiftlint:disable file_length type_body_length
struct GuidedMatchView: View {
    @StateObject var viewModel: GuidedMatchViewModel
    @StateObject var matchSyncService = NearbyMatchSyncService()
    @EnvironmentObject var dependencies: AppDependencies
    let ruleSections: [RuleSection]

    var gameSystemId: GameSystemId { viewModel.gameSystemId }
    var featuredArmies: GuidedMatchFeaturedArmies { viewModel.featuredArmies }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dismiss) var dismiss
    @Environment(TabBarChrome.self) var tabBarChrome
    @State var selectedDestination: GuidedMatchDestination?
    @State var showsAllSetupSteps = NewPlayerTipsStore.hasExpandedGuidedMatchSetup
    @State var showsMatchSync = false
    @State var showsResetConfirmation = false
    @State var hubTab: GuidedMatchHubTab = .armies
    @State var hubTrackerTick = 0
    @State var showsOwnListsSection = false
    @State var showsMatchHistoryToolbar = false
    @State var hasAppliedInitialHubTab = false
    @State var dismissedSetupCompleteHandoff = false
    @State var showsStarterMatchupHandoff = false
    @State var dismissedStarterMatchupHandoff = false
    @State var showsLoadoutSheet = false
    @AppStorage(BattleTrackerChromeStorage.guidedMatchHubCollapsedKey) var isHubChromeCollapsed = false
    @AppStorage(SpearheadStarterBoxStorage.selectedBoxIdKey) var selectedSpearheadBoxId = SpearheadStarterBoxStorage.defaultBoxId
    @State var splitColumnVisibility: NavigationSplitViewVisibility = .all

    let initialHubTab: GuidedMatchHubTab?

    var usesCompactSetupLayout: Bool {
        setupIsComplete && !NewPlayerTipsStore.hasExpandedGuidedMatchSetup
    }
    init(
        viewModel: GuidedMatchViewModel,
        ruleSections: [RuleSection] = [],
        initialHubTab: GuidedMatchHubTab? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.ruleSections = ruleSections
        self.initialHubTab = initialHubTab
        if let initialHubTab {
            _hubTab = State(initialValue: initialHubTab)
        }
    }

    var body: some View {
        Group {
            if let catalog = viewModel.catalog {
                if usesPadSplitNavigation {
                    regularLayout(catalog: catalog)
                } else {
                    compactLayout(catalog: catalog)
                }
            } else if let errorMessage = viewModel.errorMessage {
                EmptyStateView(
                    title: String(localized: "Unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading guided match…"))
                    .asyncContentShell()
            }
        }
        .modifier(GuidedMatchNavigationChrome(
            usesPadSplitNavigation: usesPadSplitNavigation,
            title: guidedMatchNavigationTitle,
            displayMode: guidedMatchNavigationTitleDisplayMode,
            toolbar: { matchSyncToolbar }
        ))
        .sheet(isPresented: $showsMatchSync) { matchSyncSheet }
        .confirmationDialog(
            String(localized: "Reset Match"),
            isPresented: $showsResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Save and Reset"), role: .destructive) {
                Task { await resetMatch(saveToHistory: true) }
            }
            Button(String(localized: "Discard"), role: .destructive) {
                Task { await resetMatch(saveToHistory: false) }
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "Save this match to history before clearing, or discard it permanently."))
        }
        .alert(
            String(localized: "Match not saved"),
            isPresented: Binding(
                get: { viewModel.saveFailureNotice != nil },
                set: { if !$0 { viewModel.saveFailureNotice = nil } }
            ),
            presenting: viewModel.saveFailureNotice
        ) { _ in
            Button(String(localized: "OK"), role: .cancel) { viewModel.saveFailureNotice = nil }
        } message: { notice in
            Text(notice)
        }
        .task {
            await viewModel.load()
            if AppLaunchArguments.shouldSnapshotGuidedMatchArmies {
                if !viewModel.matchState.hasBothArmies {
                    viewModel.applyStarterMatchup()
                }
                hubTab = .setup
                if usesPadSplitNavigation {
                    selectedDestination = .playerOne
                }
            } else if AppLaunchArguments.shouldOpenBattleTracker
                || AppLaunchArguments.shouldSnapshotBattleCombat {
                if !viewModel.matchState.hasBothArmies {
                    viewModel.applyStarterMatchup()
                }
                if AppLaunchArguments.shouldSnapshotBattleCombat {
                    viewModel.seedMarketingBattleSnapshot()
                } else {
                    viewModel.completeSetupForAutomation()
                }
                selectedDestination = .battleTracker
                hubTab = .battle
                if MarketingSnapshotBootstrap.hidesGuidedMatchSidebar {
                    splitColumnVisibility = .detailOnly
                }
            } else {
                let wantsStarterArmies = AppLaunchArguments.shouldApplyStarterMatchup
                if wantsStarterArmies, !viewModel.matchState.hasBothArmies {
                    viewModel.applyStarterMatchup()
                }
                if AppLaunchArguments.shouldApplyStarterMatchup, usesPadSplitNavigation {
                    selectedDestination = .battleTracker
                }
            }
        }
        .task {
            configureMatchSyncAnalytics()
            showsMatchHistoryToolbar = await MatchHistoryVisibility.showsToolbar(
                repository: dependencies.matchHistoryRepository
            )
        }
        .accessibilityIdentifier("guidedMatch.screen")
        .glossaryEntryNavigation()
        .onReceive(NotificationCenter.default.publisher(for: .matchSyncStateDidChange)) { _ in
            viewModel.reloadFromStore()
            hubTrackerTick += 1
        }
    }

    var layoutContext: TabletomeLayoutContext {
        TabletomeLayout.context(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    var usesPadSplitNavigation: Bool {
        layoutContext.usesPadSplitNavigation && !dynamicTypeSize.needsLayoutAdaptation
    }

    var guidedMatchNavigationTitle: String {
        if usesPhoneLandscapeBattleImmersion {
            return ""
        }
        return GameSystemRulesLabels.guidedMatchTitle(gameSystemId: gameSystemId)
    }

    /// Large titles collapse when the embedded battle tracker scrolls and draw over hub chrome on phone.
    var guidedMatchNavigationTitleDisplayMode: NavigationBarItem.TitleDisplayMode {
        if usesPadSplitNavigation || layoutContext.isCompactHeight || layoutContext == .phonePortrait {
            return .inline
        }
        return .large
    }

    var isPadLandscape: Bool {
        layoutContext == .padLandscape
    }
}

struct PlayerArmyRow: View {
    let label: String
    let selection: PlayerArmySelection
    let catalog: SpearheadCatalog

    private var hasArmySelected: Bool {
        !selection.factionId.isEmpty && !selection.armyId.isEmpty
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: hasArmySelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(hasArmySelected ? Color.accentColor : Color(.tertiaryLabel))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(selection.playerName.isEmpty ? label : selection.playerName)
                    .font(.headline)
                Text(armySubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
        .contentShape(Rectangle())
    }

    private var armySubtitle: String {
        guard let faction = catalog.factions.first(where: { $0.id == selection.factionId }),
              let army = faction.armies.first(where: { $0.id == selection.armyId }) else {
            return String(localized: "Tap to choose faction and army")
        }
        return "\(faction.name) — \(army.name)"
    }
}

// swiftlint:enable type_body_length

private struct GuidedMatchNavigationChrome<Toolbar: ToolbarContent>: ViewModifier {
    let usesPadSplitNavigation: Bool
    let title: String
    let displayMode: NavigationBarItem.TitleDisplayMode
    @ToolbarContentBuilder let toolbar: () -> Toolbar

    func body(content: Content) -> some View {
        if usesPadSplitNavigation {
            content
                .toolbar(.hidden, for: .navigationBar)
        } else {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(displayMode)
                .toolbar(content: toolbar)
        }
    }
}

struct GuidedMatchDetailWidth: ViewModifier {
    let destination: GuidedMatchDestination?

    private var usesFullDetailWidth: Bool {
        switch destination {
        case .battleTracker, .playerOne, .playerTwo:
            true
        default:
            false
        }
    }

    func body(content: Content) -> some View {
        if usesFullDetailWidth {
            content.frame(maxWidth: .infinity, alignment: .leading)
        } else {
            content.readableContentWidth()
        }
    }
}
