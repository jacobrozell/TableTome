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
    let onAdjust: (Bool, Int, MatchVictoryPointsReason) -> Void
    let onQuickAdd: (Bool, Int, MatchVictoryPointsReason) -> Void
    var onSetRoundVictoryPoints: ((Int, Bool, Int) -> Void)?
    var turnIsComplete: ((Int, Bool) -> Bool)?
    var turnIsActive: ((Int, Bool) -> Bool)?

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
        self.onAdjust = onAdjust
        self.onQuickAdd = onQuickAdd
        self.onSetRoundVictoryPoints = onSetRoundVictoryPoints
        self.turnIsComplete = turnIsComplete
        self.turnIsActive = turnIsActive
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
            onAdjust: onAdjust,
            onQuickAdd: onQuickAdd,
            onSetRoundVictoryPoints: onSetRoundVictoryPoints,
            turnIsComplete: turnIsComplete,
            turnIsActive: turnIsActive
        )
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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

            totalsRow

            if highlightsScoring {
                activePlayerScoringStrip
            }

            if showsPerTurnBreakdown {
                perTurnBreakdown
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

    private var totalsRow: some View {
        Group {
            if dynamicTypeSize.needsLayoutAdaptation {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    totalColumn(name: playerOneName, vp: playerOneVP, isPlayerOne: true)
                    Divider()
                    totalColumn(name: playerTwoName, vp: playerTwoVP, isPlayerOne: false)
                }
            } else {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                    totalColumn(name: playerOneName, vp: playerOneVP, isPlayerOne: true)
                    Divider()
                    totalColumn(name: playerTwoName, vp: playerTwoVP, isPlayerOne: false)
                }
            }
        }
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

    private var perTurnBreakdown: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: String(localized: "Score by turn"), systemImage: "list.number")

            ForEach(visibleRounds, id: \.self) { round in
                turnRows(for: round)
            }
        }
    }

    private func turnRows(for round: Int) -> some View {
        let entry = victoryPointsByRound[round] ?? RoundVictoryPoints()
        let isCurrentRound = round == battleRound
        let roundTotal = entry.playerOne + entry.playerTwo

        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text(String(localized: "Round \(round)"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isCurrentRound ? Color.accentColor : .secondary)
                if isCurrentRound {
                    Text(String(localized: "Now"))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.12), in: Capsule())
                }
                Spacer(minLength: 0)
                if roundTotal > 0 {
                    Text(String(localized: "+\(roundTotal)"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }

            turnPlayerRow(
                name: playerOneName,
                value: entry.playerOne,
                round: round,
                isPlayerOne: true
            )
            turnPlayerRow(
                name: playerTwoName,
                value: entry.playerTwo,
                round: round,
                isPlayerOne: false
            )
        }
        .padding(DesignTokens.Spacing.sm)
        .background(
            isCurrentRound ? Color.accentColor.opacity(0.08) : Color(.tertiarySystemFill),
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
        )
    }

    private func turnPlayerRow(
        name: String,
        value: Int,
        round: Int,
        isPlayerOne: Bool
    ) -> some View {
        let complete = turnIsComplete?(round, isPlayerOne) ?? false
        let active = turnIsActive?(round, isPlayerOne) ?? false

        return HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: complete ? "checkmark.circle.fill" : (active ? "circle.inset.filled" : "circle"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(complete ? .green : (active ? Color.accentColor : Color.secondary.opacity(0.35)))
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.caption.weight(active ? .semibold : .regular))
                    .foregroundStyle(active ? .primary : .secondary)
                    .lineLimit(1)
                if active {
                    Text(String(localized: "Scoring this turn"))
                        .font(.caption2)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

            Text("\(value)")
                .font(.body.bold())
                .monospacedDigit()
                .contentTransition(.numericText())
                .frame(minWidth: 28, alignment: .trailing)

            Stepper(
                String(localized: "Adjust \(name), round \(round)"),
                onIncrement: { onSetRoundVictoryPoints?(round, isPlayerOne, value + 1) },
                onDecrement: { onSetRoundVictoryPoints?(round, isPlayerOne, max(0, value - 1)) }
            )
            .labelsHidden()
            .accessibilityLabel(String(localized: "\(name), round \(round) turn, \(value) victory points"))
        }
        .padding(.vertical, 2)
        .opacity(complete ? 0.88 : 1)
    }

    private var activePlayerScoringStrip: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(String(localized: "Quick add for \(activePlayerName)"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: DesignTokens.Spacing.sm) {
                quickButton(
                    label: scoring.primaryQuickAddLabel,
                    isPlayerOne: activePlayerIsOne,
                    amount: scoring.primaryQuickAddAmount,
                    reason: .objective
                )
                quickButton(
                    label: scoring.secondaryQuickAddLabel,
                    isPlayerOne: activePlayerIsOne,
                    amount: scoring.secondaryQuickAddAmount,
                    reason: .tactic
                )
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.06), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
    }

    private func totalColumn(name: String, vp: Int, isPlayerOne: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                Text(name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .adaptiveLineLimit(2)
                    .minimumScaleFactor(dynamicTypeSize.needsLayoutAdaptation ? 1 : 0.85)
                if scoreLeaderIsPlayerOne == isPlayerOne {
                    Image(systemName: "crown.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .accessibilityLabel(String(localized: "Leading"))
                }
            }

            Text("\(vp)")
                .font(.title2.bold())
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(scoreLeaderIsPlayerOne == isPlayerOne ? .primary : .secondary)
                .accessibilityLabel(String(localized: "\(vp) victory points"))

            Stepper(
                String(localized: "Adjust"),
                onIncrement: { onAdjust(isPlayerOne, 1, .manual) },
                onDecrement: { onAdjust(isPlayerOne, -1, .manual) }
            )
            .labelsHidden()
            .accessibilityLabel(String(localized: "\(name), \(vp) victory points"))
            .accessibilityIdentifier(isPlayerOne ? "battleTracker.vp.playerOne" : "battleTracker.vp.playerTwo")
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }

    private func quickButton(
        label: String,
        isPlayerOne: Bool,
        amount: Int,
        reason: MatchVictoryPointsReason
    ) -> some View {
        Button(label) {
            onQuickAdd(isPlayerOne, amount, reason)
        }
        .buttonStyle(.bordered)
        .controlSize(dynamicTypeSize.needsLayoutAdaptation ? .regular : .small)
        .font(.caption.weight(.semibold))
        .minimumTouchTarget(alignment: .leading)
    }

    private func roundHasScoring(_ round: Int) -> Bool {
        guard let entry = victoryPointsByRound[round] else { return false }
        return entry.playerOne > 0 || entry.playerTwo > 0
    }
}
