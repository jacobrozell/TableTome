import SwiftUI
import TabletomeDomain

struct VictoryPointsCard: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneVP: Int
    let playerTwoVP: Int
    var highlightsScoring: Bool = false
    var gameSystemId: GameSystemId = .default
    let onAdjust: (Bool, Int, MatchVictoryPointsReason) -> Void
    let onQuickAdd: (Bool, Int, MatchVictoryPointsReason) -> Void

    init(
        playerOneName: String,
        playerTwoName: String,
        playerOneVP: Int,
        playerTwoVP: Int,
        highlightsScoring: Bool = false,
        gameSystemId: GameSystemId = .default,
        onAdjust: @escaping (Bool, Int, MatchVictoryPointsReason) -> Void,
        onQuickAdd: @escaping (Bool, Int, MatchVictoryPointsReason) -> Void
    ) {
        self.playerOneName = playerOneName
        self.playerTwoName = playerTwoName
        self.playerOneVP = playerOneVP
        self.playerTwoVP = playerTwoVP
        self.highlightsScoring = highlightsScoring
        self.gameSystemId = gameSystemId
        self.onAdjust = onAdjust
        self.onQuickAdd = onQuickAdd
    }

    init(
        playerOneName: String,
        playerTwoName: String,
        playerOneVP: Int,
        playerTwoVP: Int,
        highlightsScoring: Bool = false,
        gameSystemId: String,
        onAdjust: @escaping (Bool, Int, MatchVictoryPointsReason) -> Void,
        onQuickAdd: @escaping (Bool, Int, MatchVictoryPointsReason) -> Void
    ) {
        self.init(
            playerOneName: playerOneName,
            playerTwoName: playerTwoName,
            playerOneVP: playerOneVP,
            playerTwoVP: playerTwoVP,
            highlightsScoring: highlightsScoring,
            gameSystemId: GameSystemId(resolving: gameSystemId),
            onAdjust: onAdjust,
            onQuickAdd: onQuickAdd
        )
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var scoring: VictoryPointsScoring {
        GameSystemPlayContext.context(for: gameSystemId).victoryPointsScoring
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(String(localized: "Victory Points"))
                .font(.headline)

            if highlightsScoring {
                Label(
                    scoring.highlightText,
                    systemImage: "star.circle.fill"
                )
                .font(.caption)
                .foregroundStyle(Color.accentOnSurface)
                .fixedSize(horizontal: false, vertical: true)
            }

            Group {
                if dynamicTypeSize.needsLayoutAdaptation {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                        vpColumn(name: playerOneName, vp: playerOneVP, isPlayerOne: true)
                        Divider()
                        vpColumn(name: playerTwoName, vp: playerTwoVP, isPlayerOne: false)
                    }
                } else {
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                        vpColumn(name: playerOneName, vp: playerOneVP, isPlayerOne: true)
                        Divider()
                        vpColumn(name: playerTwoName, vp: playerTwoVP, isPlayerOne: false)
                    }
                }
            }

            Text(String(localized: "Quick add (end of turn scoring)"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .surfaceCard()
        .overlay {
            if highlightsScoring {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                    .strokeBorder(Color.accentColor.opacity(0.35), lineWidth: 1.5)
            }
        }
        .id("victoryPoints")
        .accessibilityIdentifier("battleTracker.victoryPoints")
    }

    private func vpColumn(name: String, vp: Int, isPlayerOne: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .adaptiveLineLimit(2)
                .minimumScaleFactor(dynamicTypeSize.needsLayoutAdaptation ? 1 : 0.85)

            Text("\(vp)")
                .font(.title2.bold())
                .monospacedDigit()
                .contentTransition(.numericText())
                .accessibilityLabel(String(localized: "\(vp) victory points"))

            Stepper(
                String(localized: "Adjust"),
                onIncrement: { onAdjust(isPlayerOne, 1, .manual) },
                onDecrement: { onAdjust(isPlayerOne, -1, .manual) }
            )
            .labelsHidden()
            .accessibilityLabel(String(localized: "\(name), \(vp) victory points"))
            .accessibilityIdentifier(isPlayerOne ? "battleTracker.vp.playerOne" : "battleTracker.vp.playerTwo")

            HStack(spacing: DesignTokens.Spacing.xs) {
                quickButton(
                    label: scoring.primaryQuickAddLabel,
                    isPlayerOne: isPlayerOne,
                    amount: scoring.primaryQuickAddAmount,
                    reason: .objective
                )
                quickButton(
                    label: scoring.secondaryQuickAddLabel,
                    isPlayerOne: isPlayerOne,
                    amount: scoring.secondaryQuickAddAmount,
                    reason: .tactic
                )
            }
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
        .font(.caption)
        .minimumTouchTarget(alignment: .leading)
    }
}
