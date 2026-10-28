import SwiftUI
import TabletomeDomain

struct MatchHistoryLink: Hashable {}

struct MatchHistoryDetailLink: Hashable {
    let recordId: UUID
}

struct MatchHistoryListView: View {
    @StateObject private var viewModel: MatchHistoryViewModel
    @Environment(AppRouter.self) private var router
    @State private var filters: [(id: String?, label: String)] = []
    @State private var recordPendingDelete: MatchRecord?

    init(viewModel: MatchHistoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading, viewModel.records.isEmpty {
                ProgressView(String(localized: "Loading match history…"))
                    .asyncContentShell()
            } else if let error = viewModel.errorMessage, viewModel.records.isEmpty {
                EmptyStateView(
                    title: String(localized: "Unable to Load"),
                    message: error,
                    systemImage: "exclamationmark.triangle",
                    actionTitle: String(localized: "Retry"),
                    action: { Task { await viewModel.load() } }
                )
                .asyncContentShell()
            } else if viewModel.records.isEmpty {
                if viewModel.filterGameSystemId != nil || viewModel.filterProfileId != nil {
                    centeredEmpty {
                        TTEmptyState(
                            title: String(localized: "No Matches for Filter"),
                            message: String(localized: "Try another filter or clear the current selection."),
                            systemImage: "line.3.horizontal.decrease.circle",
                            primary: (String(localized: "Show All"), clearFilters),
                            primaryAccessibilityIdentifier: "matchHistory.filter.showAll"
                        )
                    }
                } else {
                    centeredEmpty {
                        VStack(spacing: DesignTokens.Spacing.sm) {
                            TTEmptyState(
                                title: String(localized: "No battles yet"),
                                message: String(localized: "Finished battles show up here with scores and a turn-by-turn log."),
                                systemImage: "clock.arrow.circlepath",
                                primary: primaryLaunchOption.map { option in
                                    (String(localized: "Start a Battle"), { openGuidedMatch(gameSystemId: option.gameSystemId) })
                                },
                                primaryAccessibilityIdentifier: primaryLaunchIdentifier
                            )
                            if !secondaryLaunchOptions.isEmpty {
                                MatchHistoryEmptyLaunchActions(
                                    options: secondaryLaunchOptions,
                                    onLaunch: openGuidedMatch
                                )
                            }
                        }
                    }
                }
            } else {
                List {
                    ForEach(monthSections) { section in
                        Section {
                            ForEach(section.records) { record in
                                NavigationLink(value: MatchHistoryDetailLink(recordId: record.id)) {
                                    MatchHistoryRow(
                                        record: record,
                                        legacyBadgeLabel: legacyBadgeLabel(for: record)
                                    )
                                }
                                .accessibilityIdentifier("matchHistory.row.\(record.id.uuidString)")
                                .ttListRow()
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(String(localized: "Delete"), role: .destructive) {
                                        recordPendingDelete = record
                                    }
                                    .accessibilityIdentifier("matchHistory.delete.\(record.id.uuidString)")
                                    .accessibilityHint(String(localized: "Asks you to confirm before deleting this battle."))
                                }
                            }
                        } header: {
                            TTSectionHeader(section.title)
                                .textCase(nil)
                        }
                    }
                }
                .ttGroupedList()
                .textCase(nil)
                .tabBarScrollInset()
            }
        }
        .ttScreenBackground()
        .navigationTitle(String(localized: "History"))
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: MatchHistoryDetailLink.self) { link in
            MatchHistoryDetailView(recordId: link.recordId, viewModel: viewModel)
        }
        .toolbar {
            if ReleaseSurface.showsPlayersHub, viewModel.householdProfiles.count > 1 {
                ToolbarItem(placement: .topBarLeading) {
                    playerFilterMenu
                }
            }
            if showsGameFilter {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker(String(localized: "Filter"), selection: $viewModel.filterGameSystemId) {
                            ForEach(filters, id: \.id) { filter in
                                Text(filter.label).tag(filter.id)
                            }
                        }
                    } label: {
                        Label(String(localized: "Filter"), systemImage: "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityIdentifier("matchHistory.filter.\(viewModel.filterGameSystemId ?? "all")")
                    .accessibilityValue(selectedFilterLabel)
                }
            }
        }
        .accessibilityIdentifier("matchHistory.screen")
        .confirmationDialog(
            String(localized: "Delete this battle?"),
            isPresented: Binding(
                get: { recordPendingDelete != nil },
                set: { if !$0 { recordPendingDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(String(localized: "Delete"), role: .destructive) {
                guard let record = recordPendingDelete else { return }
                recordPendingDelete = nil
                Task { await viewModel.delete(record: record) }
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "This removes the score and the turn-by-turn log from this device."))
        }
        .task {
            filters = await viewModel.availableFilters()
            await viewModel.load()
        }
        .refreshable { await viewModel.load() }
    }

    private var monthSections: [HistoryMonthSection] {
        viewModel.sections.enumerated().map { index, section in
            HistoryMonthSection(
                title: section.title,
                records: section.records,
                id: "\(index)-\(section.title)"
            )
        }
    }

    private var showsGameFilter: Bool {
        ReleaseSurface.singleVisibleGameSystemId() == nil && filters.count > 2
    }

    private var selectedFilterLabel: String {
        filters.first { $0.id == viewModel.filterGameSystemId }?.label ?? String(localized: "All")
    }

    private var shippedGuidedMatchOptions: [GuidedMatchLaunchOption] {
        let candidates: [(GameSystemId, String)] = [
            (.aosSpearhead, String(localized: "Open Spearhead Guided Match")),
            (.wh40k11e, String(localized: "Open Warhammer 40,000 Guided Match")),
            (.wh40k10eCp, String(localized: "Open Combat Patrol Guided Match"))
        ]
        return candidates.compactMap { id, label in
            guard ReleaseSurface.showsGuidedMatch(for: id.rawValue) else { return nil }
            return GuidedMatchLaunchOption(gameSystemId: id.rawValue, label: label)
        }
    }

    private var activeGameGuidedMatchGameSystemId: String {
        let activeId = router.activeGameSystemId
        if ReleaseSurface.showsGuidedMatch(for: activeId) {
            return activeId
        }
        return OnboardingCompletion.spearheadGameSystemId
    }

    private var primaryLaunchOption: GuidedMatchLaunchOption? {
        let options = shippedGuidedMatchOptions
        if let single = ReleaseSurface.singleVisibleGameSystemId(),
           let match = options.first(where: { $0.gameSystemId == single }) {
            return match
        }
        if let active = options.first(where: { $0.gameSystemId == activeGameGuidedMatchGameSystemId }) {
            return active
        }
        return options.first
    }

    private var secondaryLaunchOptions: [GuidedMatchLaunchOption] {
        guard let primary = primaryLaunchOption else { return [] }
        return shippedGuidedMatchOptions.filter { $0.gameSystemId != primary.gameSystemId }
    }

    private var primaryLaunchIdentifier: String {
        if let gameSystemId = primaryLaunchOption?.gameSystemId {
            return "matchHistory.openGuidedMatch.\(gameSystemId)"
        }
        return "matchHistory.openGuidedMatch"
    }

    private func openGuidedMatch(gameSystemId: String) {
        router.openGuidedMatch(
            gameSystemId: gameSystemId,
            opensBattleTab: PlayContinuationResolver.shouldOpenBattleTab(gameSystemId: gameSystemId)
        )
    }

    private func clearFilters() {
        viewModel.filterGameSystemId = nil
        viewModel.filterProfileId = nil
    }

    private func centeredEmpty<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        let built = content()
        return GeometryReader { proxy in
            ScrollView {
                built
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.vertical, DesignTokens.Spacing.lg)
                    .readableContentWidth()
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .center)
            }
            .tabBarScrollInset()
        }
    }

    @ViewBuilder
    private var playerFilterMenu: some View {
        Menu {
            Picker(String(localized: "Player"), selection: $viewModel.filterProfileId) {
                Text(String(localized: "All players")).tag(UUID?.none)
                ForEach(viewModel.householdProfiles) { profile in
                    Text(profile.displayName).tag(Optional(profile.id))
                }
            }
        } label: {
            Label {
                Text(playerFilterLabel)
            } icon: {
                Image(systemName: viewModel.filterProfileId == nil
                    ? "person.2"
                    : "person.2.fill")
            }
        }
        .accessibilityIdentifier(
            "matchHistory.filter.player.\(viewModel.filterProfileId?.uuidString ?? "all")"
        )
    }

    private var playerFilterLabel: String {
        guard let filterProfileId = viewModel.filterProfileId,
              let profile = viewModel.householdProfiles.first(where: { $0.id == filterProfileId }) else {
            return String(localized: "All players")
        }
        return profile.displayName
    }

    private func legacyBadgeLabel(for record: MatchRecord) -> String? {
        guard ReleaseSurface.showsPlayersHub, !viewModel.householdProfiles.isEmpty else { return nil }
        let filtered = viewModel.filterProfileId.flatMap { id in
            viewModel.householdProfiles.first { $0.id == id }
        }
        return MatchHistoryLegacyBadgeLabel.label(
            for: record,
            filteredProfile: filtered,
            householdProfiles: viewModel.householdProfiles
        )
    }
}

extension MatchHistoryListView {
    struct GuidedMatchLaunchOption: Identifiable {
        let gameSystemId: String
        let label: String
        var id: String { gameSystemId }
    }
}

private struct HistoryMonthSection: Identifiable {
    let title: String
    let records: [MatchRecord]
    let id: String
}

private struct MatchHistoryEmptyLaunchActions: View {
    let options: [MatchHistoryListView.GuidedMatchLaunchOption]
    let onLaunch: (String) -> Void

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            ForEach(options) { option in
                Button(option.label) {
                    onLaunch(option.gameSystemId)
                }
                .buttonStyle(.ttTertiary)
                .accessibilityIdentifier("matchHistory.openGuidedMatch.\(option.gameSystemId)")
            }
        }
    }
}
