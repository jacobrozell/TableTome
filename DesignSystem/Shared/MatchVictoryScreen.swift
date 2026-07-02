import SwiftUI
import TabletomeDomain

public struct MatchVictoryPresentation: Equatable {
    public let gameSystemId: String
    public let gameSystemName: String
    public let playerOneName: String
    public let playerTwoName: String
    public let playerOneArmyLabel: String
    public let playerTwoArmyLabel: String
    public let playerOneVictoryPoints: Int
    public let playerTwoVictoryPoints: Int
    public let startedAt: Date?
    public let endedAt: Date
    public let status: MatchArchiveStatus

    public init(
        gameSystemId: String,
        gameSystemName: String,
        playerOneName: String,
        playerTwoName: String,
        playerOneArmyLabel: String,
        playerTwoArmyLabel: String,
        playerOneVictoryPoints: Int,
        playerTwoVictoryPoints: Int,
        startedAt: Date?,
        endedAt: Date = Date(),
        status: MatchArchiveStatus = .completed
    ) {
        self.gameSystemId = gameSystemId
        self.gameSystemName = gameSystemName
        self.playerOneName = playerOneName
        self.playerTwoName = playerTwoName
        self.playerOneArmyLabel = playerOneArmyLabel
        self.playerTwoArmyLabel = playerTwoArmyLabel
        self.playerOneVictoryPoints = playerOneVictoryPoints
        self.playerTwoVictoryPoints = playerTwoVictoryPoints
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.status = status
    }

    public init(record: MatchRecord) {
        self.init(
            gameSystemId: record.gameSystemId,
            gameSystemName: record.gameSystemName,
            playerOneName: record.players.playerOneName,
            playerTwoName: record.players.playerTwoName,
            playerOneArmyLabel: record.players.playerOneArmyLabel,
            playerTwoArmyLabel: record.players.playerTwoArmyLabel,
            playerOneVictoryPoints: record.result.playerOneVictoryPoints,
            playerTwoVictoryPoints: record.result.playerTwoVictoryPoints,
            startedAt: record.createdAt,
            endedAt: record.endedAt,
            status: record.status
        )
    }

    public var winner: MatchWinner {
        MatchWinnerResolver.resolve(
            playerOneVP: playerOneVictoryPoints,
            playerTwoVP: playerTwoVictoryPoints
        )
    }

    public var duration: TimeInterval {
        let start = startedAt ?? endedAt
        return max(0, endedAt.timeIntervalSince(start))
    }

    public var durationLabel: String {
        MatchDurationFormatter.label(for: duration)
    }
}

public struct MatchVictoryScreen: View {
    public enum Mode: Equatable {
        case interactive
        case readOnly
    }

    let presentation: MatchVictoryPresentation
    let mode: Mode
    let onDone: (() -> Void)?
    let onRematch: (() -> Void)?
    let onVictoryPointsChange: ((Int, Int) -> Void)?

    @State private var playerOneVP: Int
    @State private var playerTwoVP: Int
    @State private var showsAdjustScore = false
    @State private var celebrateScale: CGFloat = 1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        presentation: MatchVictoryPresentation,
        mode: Mode = .interactive,
        onDone: (() -> Void)? = nil,
        onRematch: (() -> Void)? = nil,
        onVictoryPointsChange: ((Int, Int) -> Void)? = nil
    ) {
        self.presentation = presentation
        self.mode = mode
        self.onDone = onDone
        self.onRematch = onRematch
        self.onVictoryPointsChange = onVictoryPointsChange
        _playerOneVP = State(initialValue: presentation.playerOneVictoryPoints)
        _playerTwoVP = State(initialValue: presentation.playerTwoVictoryPoints)
    }

    private var winner: MatchWinner {
        MatchWinnerResolver.resolve(playerOneVP: playerOneVP, playerTwoVP: playerTwoVP)
    }

    private var isDraw: Bool {
        winner == .tie
    }

    public var body: some View {
        Group {
            if mode == .readOnly {
                victoryContent
            } else {
                NavigationStack {
                    ScrollView {
                        victoryContent
                    }
                    .background(Color(.systemGroupedBackground))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(String(localized: "Done")) {
                                onDone?()
                            }
                            .accessibilityIdentifier("matchVictory.done.toolbar")
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("matchVictory.screen")
        .onAppear {
            guard mode == .interactive else { return }
            runCelebrateAnimation()
        }
        .sheet(isPresented: $showsAdjustScore) {
            adjustScoreSheet
        }
    }

    private var victoryContent: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            MatchVictoryHeaderMetaSection(
                gameSystemName: presentation.gameSystemName,
                status: presentation.status,
                durationLabel: presentation.durationLabel
            )
            MatchVictoryHeadlineSection(
                mode: mode,
                headlineTitle: headlineTitle,
                headlineSymbol: headlineSymbol,
                headlineSymbolColor: headlineSymbolColor,
                celebrateScale: celebrateScale,
                isDraw: isDraw,
                winnerName: winnerName,
                voiceOverSummary: voiceOverSummary
            )
            MatchVictoryScoreboardSection(
                playerOneName: presentation.playerOneName,
                playerTwoName: presentation.playerTwoName,
                playerOneArmyLabel: presentation.playerOneArmyLabel,
                playerTwoArmyLabel: presentation.playerTwoArmyLabel,
                playerOneVP: playerOneVP,
                playerTwoVP: playerTwoVP,
                winner: winner
            )
            if mode == .interactive {
                MatchVictoryInteractiveActionsSection(
                    onAdjustScore: { showsAdjustScore = true },
                    onRematch: { onRematch?() },
                    onDone: { onDone?() }
                )
            }
        }
        .padding(DesignTokens.Spacing.md)
        .readableContentWidth()
        .frame(maxWidth: .infinity)
        .background {
            if mode == .readOnly {
                Color(.secondarySystemBackground)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .padding(.horizontal, mode == .readOnly ? DesignTokens.Spacing.md : 0)
    }

    private var adjustScoreSheet: some View {
        NavigationStack {
            VictoryPointsCard(
                playerOneName: presentation.playerOneName,
                playerTwoName: presentation.playerTwoName,
                playerOneVP: playerOneVP,
                playerTwoVP: playerTwoVP,
                gameSystemId: presentation.gameSystemId,
                onAdjust: { isPlayerOne, delta, _ in
                    if isPlayerOne {
                        playerOneVP = max(0, playerOneVP + delta)
                    } else {
                        playerTwoVP = max(0, playerTwoVP + delta)
                    }
                    onVictoryPointsChange?(playerOneVP, playerTwoVP)
                },
                onQuickAdd: { isPlayerOne, amount, _ in
                    if isPlayerOne {
                        playerOneVP += amount
                    } else {
                        playerTwoVP += amount
                    }
                    onVictoryPointsChange?(playerOneVP, playerTwoVP)
                }
            )
            .padding(DesignTokens.Spacing.md)
            .navigationTitle(String(localized: "Final Score"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) {
                        showsAdjustScore = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var headlineTitle: String {
        if presentation.status == .abandoned {
            return String(localized: "Match Saved")
        }
        return isDraw ? String(localized: "Draw") : String(localized: "Victory")
    }

    private var headlineSymbol: String {
        if presentation.status == .abandoned {
            return "archivebox.fill"
        }
        if isDraw {
            return "equal.circle.fill"
        }
        return "crown.fill"
    }

    private var headlineSymbolColor: Color {
        if presentation.status == .abandoned {
            return .orange
        }
        return .accentColor
    }

    private var winnerName: String? {
        switch winner {
        case .playerOne: presentation.playerOneName
        case .playerTwo: presentation.playerTwoName
        case .tie, .undecided: nil
        }
    }

    private var voiceOverSummary: String {
        if isDraw {
            return String(
                localized: "Draw. \(presentation.playerOneName) \(playerOneVP) victory points. \(presentation.playerTwoName) \(playerTwoVP) victory points."
            )
        }
        if let winnerName {
            let loserName = winner == .playerOne ? presentation.playerTwoName : presentation.playerOneName
            let winnerVP = winner == .playerOne ? playerOneVP : playerTwoVP
            let loserVP = winner == .playerOne ? playerTwoVP : playerOneVP
            return String(
                localized: "\(winnerName) wins with \(winnerVP) victory points over \(loserName) with \(loserVP)."
            )
        }
        return headlineTitle
    }

    private func runCelebrateAnimation() {
        guard !reduceMotion, presentation.status == .completed, !isDraw else { return }
        celebrateScale = 0.85
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
            celebrateScale = 1
        }
    }
}
