import SwiftUI
import TabletomeDomain

struct VictoryPointsCard: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneVP: Int
    let playerTwoVP: Int
    var battleRound: Int = 1
    var maxBattleRounds: Int = 0
    var victoryPointsByRound: [Int: RoundVictoryPoints] = [:]
    var activePlayerIsOne: Bool = true
    var completedTurnPlayerOnes: Set<Bool> = []
    var scoreLeaderIsPlayerOne: Bool?
    var highlightsScoring: Bool = false
    var gameSystemId: GameSystemId = .default
    var defaultsExpandedPerTurnBreakdown: Bool = false
    let onAdjust: (Bool, Int, MatchVictoryPointsReason) -> Void
    let onQuickAdd: (Bool, Int, MatchVictoryPointsReason) -> Void
    var onSetRoundVictoryPoints: ((Int, Bool, Int) -> Void)?
    var turnIsComplete: ((Int, Bool) -> Bool)?
    var turnIsActive: ((Int, Bool) -> Bool)?

    @State private var showsPerTurnDetails: Bool

    init(
        playerOneName: String,
        playerTwoName: String,
        playerOneVP: Int,
        playerTwoVP: Int,
        battleRound: Int = 1,
        maxBattleRounds: Int = 0,
        victoryPointsByRound: [Int: RoundVictoryPoints] = [:],
        activePlayerIsOne: Bool = true,
        completedTurnPlayerOnes: Set<Bool> = [],
        scoreLeaderIsPlayerOne: Bool? = nil,
        highlightsScoring: Bool = false,
        gameSystemId: GameSystemId = .default,
        defaultsExpandedPerTurnBreakdown: Bool = false,
        onAdjust: @escaping (Bool, Int, MatchVictoryPointsReason) -> Void,
        onQuickAdd: @escaping (Bool, Int, MatchVictoryPointsReason) -> Void,
        onSetRoundVictoryPoints: ((Int, Bool, Int) -> Void)? = nil,
        turnIsComplete: ((Int, Bool) -> Bool)? = nil,
        turnIsActive: ((Int, Bool) -> Bool)? = nil
    ) {
        self.playerOneName = playerOneName
        self.playerTwoName = playerTwoName
        self.playerOneVP = playerOneVP
        self.playerTwoVP = playerTwoVP
        self.battleRound = battleRound
        self.maxBattleRounds = maxBattleRounds
        self.victoryPointsByRound = victoryPointsByRound
        self.activePlayerIsOne = activePlayerIsOne
        self.completedTurnPlayerOnes = completedTurnPlayerOnes
        self.scoreLeaderIsPlayerOne = scoreLeaderIsPlayerOne
        self.highlightsScoring = highlightsScoring
        self.gameSystemId = gameSystemId
        self.defaultsExpandedPerTurnBreakdown = defaultsExpandedPerTurnBreakdown
        self.onAdjust = onAdjust
        self.onQuickAdd = onQuickAdd
        self.onSetRoundVictoryPoints = onSetRoundVictoryPoints
        self.turnIsComplete = turnIsComplete
        self.turnIsActive = turnIsActive
        _showsPerTurnDetails = State(initialValue: defaultsExpandedPerTurnBreakdown)
    }

    init(
        playerOneName: String,
        playerTwoName: String,
        playerOneVP: Int,
        playerTwoVP: Int,
        battleRound: Int = 1,
        maxBattleRounds: Int = 0,
        victoryPointsByRound: [Int: RoundVictoryPoints] = [:],
        activePlayerIsOne: Bool = true,
        completedTurnPlayerOnes: Set<Bool> = [],
        scoreLeaderIsPlayerOne: Bool? = nil,
        highlightsScoring: Bool = false,
        gameSystemId: String,
        defaultsExpandedPerTurnBreakdown: Bool = false,
        onAdjust: @escaping (Bool, Int, MatchVictoryPointsReason) -> Void,
        onQuickAdd: @escaping (Bool, Int, MatchVictoryPointsReason) -> Void,
        onSetRoundVictoryPoints: ((Int, Bool, Int) -> Void)? = nil,
        turnIsComplete: ((Int, Bool) -> Bool)? = nil,
        turnIsActive: ((Int, Bool) -> Bool)? = nil
    ) {
        self.init(
            playerOneName: playerOneName,
            playerTwoName: playerTwoName,
            playerOneVP: playerOneVP,
            playerTwoVP: playerTwoVP,
            battleRound: battleRound,
            maxBattleRounds: maxBattleRounds,
            victoryPointsByRound: victoryPointsByRound,
            activePlayerIsOne: activePlayerIsOne,
            completedTurnPlayerOnes: completedTurnPlayerOnes,
            scoreLeaderIsPlayerOne: scoreLeaderIsPlayerOne,
            highlightsScoring: highlightsScoring,
            gameSystemId: GameSystemId(resolving: gameSystemId),
            defaultsExpandedPerTurnBreakdown: defaultsExpandedPerTurnBreakdown,
            onAdjust: onAdjust,
            onQuickAdd: onQuickAdd,
            onSetRoundVictoryPoints: onSetRoundVictoryPoints,
            turnIsComplete: turnIsComplete,
            turnIsActive: turnIsActive
        )
    }

    private var scoring: VictoryPointsScoring {
        GameSystemPlayContext.context(for: gameSystemId).victoryPointsScoring
    }

    private var activePlayerName: String {
        activePlayerIsOne ? playerOneName : playerTwoName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .firstTextBaseline) {
                Text(String(localized: "Victory Points"))
                    .font(.headline)
                Spacer(minLength: DesignTokens.Spacing.sm)
                if playerOneVP > 0 || playerTwoVP > 0 {
                    Text(String(localized: "Total \(playerOneVP + playerTwoVP)"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }

            if highlightsScoring {
                Label(
                    scoring.highlightText,
                    systemImage: "star.circle.fill"
                )
                .font(.caption)
                .foregroundStyle(Color.accentOnSurface)
                .fixedSize(horizontal: false, vertical: true)
            }

            VictoryPointsTotalsRowSection(
                playerOneName: playerOneName,
                playerTwoName: playerTwoName,
                playerOneVP: playerOneVP,
                playerTwoVP: playerTwoVP,
                scoreLeaderIsPlayerOne: scoreLeaderIsPlayerOne,
                onAdjust: onAdjust
            )

            if highlightsScoring {
                VictoryPointsActivePlayerScoringStripSection(
                    activePlayerName: activePlayerName,
                    activePlayerIsOne: activePlayerIsOne,
                    scoring: scoring,
                    onQuickAdd: onQuickAdd
                )
            }

            if showsPerTurnBreakdown, let onSetRoundVictoryPoints {
                VictoryPointsPerTurnBreakdownSection(
                    showsPerTurnDetails: $showsPerTurnDetails,
                    visibleRounds: visibleRounds,
                    battleRound: battleRound,
                    victoryPointsByRound: victoryPointsByRound,
                    playerOneName: playerOneName,
                    playerTwoName: playerTwoName,
                    turnIsComplete: turnIsComplete,
                    turnIsActive: turnIsActive,
                    onSetRoundVictoryPoints: onSetRoundVictoryPoints
                )
            }
        }
        .surfaceCard()
        .overlay {
            if highlightsScoring {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                    .strokeBorder(Color.accentColor.opacity(0.35), lineWidth: 1.5)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: playerOneVP)
        .animation(.easeInOut(duration: 0.2), value: playerTwoVP)
        .id("victoryPoints")
        .accessibilityIdentifier("battleTracker.victoryPoints")
    }

    private var showsPerTurnBreakdown: Bool {
        maxBattleRounds > 1 && onSetRoundVictoryPoints != nil
    }

    private var visibleRounds: [Int] {
        guard maxBattleRounds > 0 else { return [] }
        return (1...maxBattleRounds).filter { round in
            round <= battleRound || roundHasScoring(round)
        }
    }

    private func roundHasScoring(_ round: Int) -> Bool {
        guard let entry = victoryPointsByRound[round] else { return false }
        return entry.playerOne > 0 || entry.playerTwo > 0
    }
}
