import SwiftUI
import TabletomeDomain

struct PlayHeroCard: View {
    @Environment(AppRouter.self) private var router
    @EnvironmentObject private var dependencies: AppDependencies

    let gameSystem: GameSystem
    let hasMatchHistory: Bool
    let lastRecord: MatchRecord?

    @State private var showsBoxHelper = false
    @State private var setupCompleted = 0
    @State private var setupTotal = 0
    @State private var refreshToken = 0

    var body: some View {
        TTHeroCard(eyebrow: gameSystem.name, title: title, subtitle: subtitle) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                if showsScoreboard {
                    scoreboard
                    Text(phaseLine)
                        .font(TTFont.callout)
                        .foregroundStyle(TTColor.inkSecondary)
                }
                if showsSetupProgress, setupTotal > 0 {
                    TTProgressBar(
                        fraction: Double(setupCompleted) / Double(setupTotal),
                        tone: .brand,
                        criticalThreshold: nil
                    )
                    .frame(height: 8)
                    Text(String(localized: "Setup: \(setupCompleted) of \(setupTotal)"))
                        .font(TTFont.caption)
                        .foregroundStyle(TTColor.inkSecondary)
                }
                Button(primaryTitle) { openPrimary() }
                    .buttonStyle(.ttPrimary)
                    .accessibilityIdentifier(primaryIdentifier)
                if showsBoxHelperButton {
                    Button(String(localized: "Not sure it's a Spearhead box?")) {
                        showsBoxHelper = true
                    }
                    .buttonStyle(.ttTertiary)
                    .accessibilityIdentifier("home.chooser.boxHelper")
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .firstSessionStoreDidChange)) { _ in
            refreshToken += 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .matchSyncStateDidChange)) { _ in
            refreshToken += 1
        }
        .task(id: refreshToken) { await loadSetupProgress() }
        .sheet(isPresented: $showsBoxHelper) {
            BoxIdentificationSheet()
        }
    }

    private var continuation: PlayContinuation? {
        PlayContinuationResolver.current(activeGameSystemId: gameSystem.id)
    }

    private var battleInProgress: Bool {
        continuation?.destination == .guidedMatch && continuation?.opensBattleTab == true
    }

    private var setupInProgress: Bool {
        continuation?.destination == .guidedMatch && continuation?.opensBattleTab == false
    }

    private var showsScoreboard: Bool { battleInProgress }
    private var showsSetupProgress: Bool { setupInProgress }
    private var showsBoxHelperButton: Bool { continuation == nil && !hasMatchHistory }

    private var setupIsComplete: Bool {
        setupTotal > 0 && setupCompleted >= setupTotal
    }

    private var title: String {
        if battleInProgress { return String(localized: "Battle in progress") }
        if setupIsComplete { return String(localized: "Ready to battle") }
        if setupInProgress { return String(localized: "Finish setting up") }
        if hasMatchHistory { return String(localized: "Ready for another battle?") }
        return String(localized: "Your first battle")
    }

    private var subtitle: String? {
        if battleInProgress || setupInProgress { return nil }
        if let lastRecord, hasMatchHistory {
            return lastBattleDetail(lastRecord)
        }
        return String(localized: "Setup and every phase, about 90 minutes.")
    }

    private var primaryTitle: String {
        if battleInProgress { return String(localized: "Resume Battle") }
        if setupIsComplete { return String(localized: "Start Battle") }
        if setupInProgress { return String(localized: "Continue Setup") }
        return String(localized: "Start a Battle")
    }

    private var primaryIdentifier: String {
        continuation == nil ? "home.startBattle" : "home.continueGuidedMatch"
    }

    private var tracker: BattleTrackerState {
        BattleTrackerStore.load(gameSystemId: gameSystem.id)
    }

    private var matchState: GuidedMatchState {
        MatchSetupStore.load(gameSystemId: gameSystem.id)
    }

    private var scoreboard: some View {
        let roundCount = GameSystemPlayContext.context(for: gameSystem.id).playEngine.battleRoundCount()
        return HStack(spacing: DesignTokens.Spacing.sm) {
            TTPlayerToken(isPlayerOne: true, isActive: tracker.activePlayerIsOne)
            Text(playerName(matchState.playerOne.playerName, fallback: String(localized: "Player 1")))
                .font(TTFont.subheadline)
            Text("\(tracker.playerOneVictoryPoints)")
                .font(TTFont.numericMedium)
                .foregroundStyle(TTColor.playerOne)
            Spacer(minLength: 0)
            Text(String(localized: "Round \(tracker.battleRound) of \(roundCount)"))
                .font(TTFont.caption)
                .foregroundStyle(TTColor.inkSecondary)
            Spacer(minLength: 0)
            Text("\(tracker.playerTwoVictoryPoints)")
                .font(TTFont.numericMedium)
                .foregroundStyle(TTColor.playerTwo)
            Text(playerName(matchState.playerTwo.playerName, fallback: String(localized: "Player 2")))
                .font(TTFont.subheadline)
            TTPlayerToken(isPlayerOne: false, isActive: !tracker.activePlayerIsOne)
        }
    }

    private var phaseLine: String {
        let name = tracker.activePlayerIsOne
            ? playerName(matchState.playerOne.playerName, fallback: String(localized: "Player 1"))
            : playerName(matchState.playerTwo.playerName, fallback: String(localized: "Player 2"))
        return String(localized: "\(tracker.currentPhase.title) · \(name)'s turn")
    }

    private func openPrimary() {
        if let continuation, continuation.destination == .guidedMatch {
            router.openGuidedMatch(
                gameSystemId: gameSystem.id,
                opensBattleTab: continuation.opensBattleTab || setupIsComplete
            )
        } else {
            router.openGuidedMatch(gameSystemId: gameSystem.id)
        }
    }

    private func loadSetupProgress() async {
        guard setupInProgress else {
            setupCompleted = 0
            setupTotal = 0
            return
        }
        let state = MatchSetupStore.load(gameSystemId: gameSystem.id)
        guard let catalog = try? await dependencies.catalogRepository(
            for: GameSystemId(resolving: gameSystem.id)
        ).loadCatalog() else { return }
        let steps = catalog.matchSteps.sorted { $0.order < $1.order }
        setupTotal = steps.count
        setupCompleted = steps.filter { state.completedStepIds.contains($0.id) }.count
    }

    private func playerName(_ raw: String, fallback: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }

    private func lastBattleDetail(_ record: MatchRecord) -> String {
        let score = "\(record.result.playerOneVictoryPoints)–\(record.result.playerTwoVictoryPoints)"
        switch record.result.winner {
        case .playerOne:
            return String(localized: "Last time: \(record.players.playerOneName) won \(score).")
        case .playerTwo:
            return String(localized: "Last time: \(record.players.playerTwoName) won \(score).")
        case .tie, .undecided:
            return String(localized: "Last time ended \(score).")
        }
    }
}
