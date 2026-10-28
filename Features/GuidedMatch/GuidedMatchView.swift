import SwiftUI
import TabletomeDomain
import TabletomeData

// swiftlint:disable file_length type_body_length
struct GuidedMatchView: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    @StateObject var matchSyncService = NearbyMatchSyncService()
    @EnvironmentObject var dependencies: AppDependencies
    let ruleSections: [RuleSection]

    var gameSystemId: GameSystemId { viewModel.gameSystemId }
    var featuredArmies: GuidedMatchFeaturedArmies { viewModel.featuredArmies }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dismiss) var dismiss
    @Environment(AppRouter.self) var router
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
    @State var padDetailNavigationPath = NavigationPath()
    @State private var didRecordGuidedMatchOpened = false
    @State var showsMatchHistory = false
    @State var showsPreBattleLoadoutSheet = false
    @State var householdPlayers: HouseholdPlayersState?
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
        self.viewModel = viewModel
        self.ruleSections = ruleSections
        self.initialHubTab = initialHubTab
        if let initialHubTab {
            _hubTab = State(initialValue: initialHubTab)
        } else {
            _hubTab = State(
                initialValue: Self.resolvedInitialHubTab(
                    gameSystemId: viewModel.gameSystemId,
                    hasBothArmies: viewModel.matchState.hasBothArmies
                )
            )
        }
    }

    private static func resolvedInitialHubTab(
        gameSystemId: GameSystemId,
        hasBothArmies: Bool
    ) -> GuidedMatchHubTab {
        if gameSystemId == .aosSpearhead {
            return SpearheadHubTabs.suggested(hasBothArmies: hasBothArmies, setupComplete: false)
        }
        return GuidedMatchHubTab.suggested(
            gameSystemId: gameSystemId,
            hasBothArmies: hasBothArmies,
            setupComplete: false
        )
    }

    var body: some View {
        ZStack {
            if usesPadSplitNavigation {
                if let catalog = viewModel.catalog {
                    regularLayout(catalog: catalog)
                } else {
                    Color(.systemBackground)
                }
            } else {
                compactLayout(catalog: viewModel.catalog)
            }

            if usesPadSplitNavigation, viewModel.catalog == nil {
                if let errorMessage = viewModel.errorMessage {
                    EmptyStateView(
                        title: String(localized: "Unavailable"),
                        message: errorMessage,
                        systemImage: "exclamationmark.triangle"
                    )
                    .adaptiveEmptyStateLayout()
                    .asyncContentShell()
                } else {
                    ProgressView(String(localized: "Loading guided match…"))
                        .asyncContentShell()
                }
            } else if !usesPadSplitNavigation, let errorMessage = viewModel.errorMessage {
                EmptyStateView(
                    title: String(localized: "Unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .adaptiveEmptyStateLayout()
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
        .sheet(isPresented: $showsMatchHistory) {
            NavigationStack {
                MatchHistoryListView(viewModel: dependencies.makeMatchHistoryViewModel())
            }
        }
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
            applySpearheadPadInitialDestinationIfNeeded()
            if ReleaseSurface.showsPlayersHub {
                if let household = try? await dependencies.playerProfileStore.loadHousehold() {
                    householdPlayers = household
                    viewModel.applyHouseholdDefaultsIfNeeded(household)
                }
            }
            if !didRecordGuidedMatchOpened, viewModel.catalog != nil {
                didRecordGuidedMatchOpened = true
                FirstSessionStore.recordGuidedMatchOpened()
            }
            if AppLaunchArguments.shouldSnapshotGuidedMatchArmies {
                if !viewModel.matchState.hasBothArmies {
                    viewModel.applyStarterMatchup(household: householdPlayers)
                }
                hubTab = .setup
                if usesPadSplitNavigation {
                    selectedDestination = .playerOne
                }
            } else if AppLaunchArguments.shouldOpenBattleTracker
                || AppLaunchArguments.shouldSnapshotBattleCombat {
                if !viewModel.matchState.hasBothArmies {
                    viewModel.applyStarterMatchup(household: householdPlayers)
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
                    viewModel.applyStarterMatchup(household: householdPlayers)
                }
                if AppLaunchArguments.shouldApplyStarterMatchup, usesPadSplitNavigation {
                    selectedDestination = .battleTracker
                }
            }
            applyGuidedMatchHubTabPolicyAfterLoad()
        }
        .task {
            configureMatchSyncAnalytics()
            showsMatchHistoryToolbar = await MatchHistoryVisibility.showsToolbar(
                repository: dependencies.matchHistoryRepository
            )
        }
        .accessibilityIdentifier("guidedMatch.screen")
        .glossaryEntryNavigation()
        .onReceive(NotificationCenter.default.publisher(for: .matchSyncStateDidChange)) { notification in
            let shouldBroadcast = notification.userInfo?[MatchSyncNotifications.shouldBroadcastToPeersKey] as? Bool ?? true
            guard !shouldBroadcast else { return }
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
        if usesPhoneLandscapeBattleImmersion || hidesGuidedMatchHubChromeWhenEmbedded {
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
    var profile: PlayerProfile?
    var isPrimaryProfile: Bool = false

    private var hasArmySelected: Bool {
        !selection.factionId.isEmpty && !selection.armyId.isEmpty
    }

    private var displayName: String {
        selection.playerName.isEmpty ? label : selection.playerName
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            if let profile {
                PlayerAvatarView(
                    name: profile.displayName,
                    accentColorName: profile.accentColorName,
                    size: 40
                )
            } else {
                PlayerAvatarView(name: displayName, size: 40)
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Text(displayName)
                        .font(.headline)
                    if isPrimaryProfile {
                        PlayerBadge(title: String(localized: "Me"), style: .accent)
                    }
                    if hasArmySelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.accentColor)
                            .accessibilityHidden(true)
                    }
                }
                Text(armySubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
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
