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
    @AppStorage(BattleTrackerChromeStorage.guidedMatchHubCollapsedKey) var isHubChromeCollapsed = false

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
        .navigationTitle(
            usesPhoneLandscapeBattleImmersion
                ? ""
                : GameSystemRulesLabels.guidedMatchTitle(gameSystemId: gameSystemId)
        )
        .navigationBarTitleDisplayMode(guidedMatchNavigationTitleDisplayMode)
        .toolbar { matchSyncToolbar }
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
        .task {
            await viewModel.load()
            let wantsStarterArmies = AppLaunchArguments.shouldApplyStarterMatchup
                || AppLaunchArguments.shouldOpenBattleTracker
            if wantsStarterArmies, !viewModel.matchState.hasBothArmies {
                viewModel.applyStarterMatchup()
            }
            if AppLaunchArguments.shouldOpenBattleTracker {
                viewModel.completeSetupForAutomation()
                selectedDestination = .battleTracker
                hubTab = .battle
            } else if AppLaunchArguments.shouldApplyStarterMatchup, usesPadSplitNavigation {
                selectedDestination = .battleTracker
            }
        }
        .task {
            showsMatchHistoryToolbar = await MatchHistoryVisibility.showsToolbar(
                repository: dependencies.matchHistoryRepository
            )
        }
        .accessibilityIdentifier("guidedMatch.screen")
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

    /// Large titles collapse when the embedded battle tracker scrolls and draw over hub chrome on phone.
    var guidedMatchNavigationTitleDisplayMode: NavigationBarItem.TitleDisplayMode {
        if layoutContext.isCompactHeight || layoutContext == .phonePortrait {
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

struct GuidedMatchDetailWidth: ViewModifier {
    let destination: GuidedMatchDestination?

    func body(content: Content) -> some View {
        if destination == .battleTracker {
            content.frame(maxWidth: .infinity, alignment: .leading)
        } else {
            content.readableContentWidth()
        }
    }
}
