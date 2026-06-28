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
                    systemImage: "wifi.exclamationmark",
                    actionTitle: String(localized: "Retry"),
                    action: { Task { await viewModel.load() } }
                )
                .asyncContentShell()
            } else if viewModel.records.isEmpty {
                if viewModel.filterGameSystemId != nil {
                    ContentUnavailableView {
                        Label(String(localized: "No Matches for Filter"), systemImage: "line.3.horizontal.decrease.circle")
                    } description: {
                        Text(String(localized: "Try another game system or clear the filter."))
                    } actions: {
                        Button(String(localized: "Show All")) {
                            viewModel.filterGameSystemId = nil
                        }
                    }
                } else {
                    ContentUnavailableView {
                        Label(String(localized: "No Matches Yet"), systemImage: "clock.arrow.circlepath")
                    } description: {
                        Text(
                            String(
                                localized: """
                                Finished guided matches are saved here with scores and a turn-by-turn log. \
                                Complete a game in Guided Match to see your first entry.
                                """
                            )
                        )
                    } actions: {
                        MatchHistoryEmptyLaunchActions(
                            options: shippedGuidedMatchOptions,
                            activeGameSystemId: activeGameGuidedMatchGameSystemId,
                            onLaunch: { gameSystemId in
                                router.openGuidedMatch(
                                    gameSystemId: gameSystemId,
                                    opensBattleTab: PlayContinuationResolver.shouldOpenBattleTab(
                                        gameSystemId: gameSystemId
                                    )
                                )
                            }
                        )
                    }
                }
            } else {
                List {
                    ForEach(viewModel.records) { record in
                        NavigationLink(value: MatchHistoryDetailLink(recordId: record.id)) {
                            MatchHistoryRow(record: record)
                        }
                        .accessibilityIdentifier("matchHistory.row.\(record.id.uuidString)")
                    }
                    .onDelete { indexSet in
                        Task {
                            for index in indexSet {
                                await viewModel.delete(record: viewModel.records[index])
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .tabBarScrollInset()
            }
        }
        .navigationTitle(String(localized: "Match History"))
        .navigationDestination(for: MatchHistoryDetailLink.self) { link in
            MatchHistoryDetailView(recordId: link.recordId, viewModel: viewModel)
        }
        .toolbar {
            if filters.count > 2 {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker(String(localized: "Filter"), selection: $viewModel.filterGameSystemId) {
                            ForEach(filters, id: \.id) { filter in
                                Text(filter.label).tag(filter.id)
                            }
                        }
                    } label: {
                        Label {
                            Text(String(localized: "Filter"))
                        } icon: {
                            Image(systemName: viewModel.filterGameSystemId == nil
                                ? "line.3.horizontal.decrease.circle"
                                : "line.3.horizontal.decrease.circle.fill")
                        }
                    }
                    .accessibilityIdentifier(
                        "matchHistory.filter.\(viewModel.filterGameSystemId ?? "all")"
                    )
                }
            }
        }
        .accessibilityIdentifier("matchHistory.screen")
        .task {
            filters = await viewModel.availableFilters()
            await viewModel.load()
        }
        .refreshable { await viewModel.load() }
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
}

private struct MatchHistoryEmptyLaunchActions: View {
    let options: [MatchHistoryListView.GuidedMatchLaunchOption]
    let activeGameSystemId: String
    let onLaunch: (String) -> Void

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(options) { option in
                MatchHistoryLaunchButton(
                    label: option.label,
                    gameSystemId: option.gameSystemId,
                    isPrimary: option.gameSystemId == activeGameSystemId,
                    onLaunch: onLaunch
                )
            }
        }
    }
}

private struct MatchHistoryLaunchButton: View {
    let label: String
    let gameSystemId: String
    let isPrimary: Bool
    let onLaunch: (String) -> Void

    var body: some View {
        Group {
            if isPrimary {
                Button(label) {
                    onLaunch(gameSystemId)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button(label) {
                    onLaunch(gameSystemId)
                }
                .buttonStyle(.bordered)
            }
        }
        .accessibilityIdentifier("matchHistory.openGuidedMatch.\(gameSystemId)")
    }
}

extension MatchHistoryListView {
    struct GuidedMatchLaunchOption: Identifiable {
        let gameSystemId: String
        let label: String
        var id: String { gameSystemId }
    }
}

private struct MatchHistoryRow: View {
    let record: MatchRecord

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack {
                Text(record.gameSystemName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.accentOnSurface)
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(MatchHistoryDisplayFormatter.relativeDateLabel(for: record.endedAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if Calendar.current.isDateInToday(record.endedAt) {
                        Text(record.endedAt, style: .time)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Text("\(record.players.playerOneName) vs \(record.players.playerTwoName)")
                .font(.headline)

            Text("\(record.players.playerOneArmyLabel) vs \(record.players.playerTwoArmyLabel)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: DesignTokens.Spacing.sm) {
                Text(
                    "\(record.result.playerOneVictoryPoints) – \(record.result.playerTwoVictoryPoints) VP"
                )
                .font(.callout.weight(.semibold))

                if let winnerName = record.winnerPlayerName {
                    Text(winnerName)
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                } else if record.result.winner == .tie {
                    Text(String(localized: "Draw"))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }

                if record.status == .abandoned {
                    Text(String(localized: "Abandoned"))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
        .contentShape(Rectangle())
    }
}
