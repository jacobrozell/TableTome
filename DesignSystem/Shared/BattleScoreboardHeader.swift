import SwiftUI

struct BattleScoreboardHeader: View {
    struct Side: Equatable {
        let name: String
        let armyName: String
        let victoryPoints: Int
        let isActive: Bool
        let isUnderdog: Bool
        let isPlayerOne: Bool
    }

    let playerOne: Side
    let playerTwo: Side
    let round: Int
    let roundCount: Int
    var compact: Bool = false
    let onTapScore: (_ isPlayerOne: Bool) -> Void
    let onTapRound: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if compact || dynamicTypeSize.needsLayoutAdaptation {
                VStack(spacing: DesignTokens.Spacing.xs) {
                    sideButton(playerOne)
                    roundButton
                    sideButton(playerTwo)
                }
            } else {
                HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                    sideButton(playerOne)
                    roundButton
                    sideButton(playerTwo)
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .frame(minHeight: DesignTokens.Size.scoreboardHeight)
        .background(TTColor.surface)
        .overlay(alignment: .bottom) {
            Rectangle().fill(TTColor.stroke).frame(height: 1)
        }
        .animation(TTMotion.emphasis(reduceMotion: reduceMotion), value: playerOne.isActive)
    }

    private func sideButton(_ side: Side) -> some View {
        Button {
            onTapScore(side.isPlayerOne)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    TTPlayerToken(isPlayerOne: side.isPlayerOne, size: 22, isActive: side.isActive)
                    Text(side.name)
                        .font(TTFont.headline)
                        .foregroundStyle(TTColor.inkPrimary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text("\(side.victoryPoints)")
                        .font(TTFont.numericHero)
                        .foregroundStyle(side.isActive ? TTColor.player(side.isPlayerOne) : TTColor.inkPrimary)
                        .contentTransition(.numericText(value: Double(side.victoryPoints)))
                }
                Text(side.armyName)
                    .font(TTFont.caption)
                    .foregroundStyle(TTColor.inkSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                if side.isUnderdog {
                    TTBadge(
                        String(localized: "Underdog"),
                        tone: .warning,
                        systemImage: "arrow.down.circle.fill"
                    )
                }
            }
            .padding(.vertical, DesignTokens.Spacing.xs)
            .padding(.horizontal, DesignTokens.Spacing.xs)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(side.isActive ? TTColor.playerSoft(side.isPlayerOne) : .clear)
            .overlay(alignment: .bottom) {
                if side.isActive {
                    Rectangle()
                        .fill(TTColor.player(side.isPlayerOne))
                        .frame(height: 3)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(sideLabel(side))
        .accessibilityHint(String(localized: "Opens scoring"))
        .accessibilityIdentifier(
            side.isPlayerOne ? "battleTracker.scoreboard.playerOne" : "battleTracker.scoreboard.playerTwo"
        )
    }

    private var roundButton: some View {
        Button(action: onTapRound) {
            VStack(spacing: 2) {
                Text(String(localized: "Round"))
                    .ttEyebrow()
                Text("\(round) / \(roundCount)")
                    .font(TTFont.numericMedium)
                    .foregroundStyle(TTColor.inkPrimary)
                HStack(spacing: 3) {
                    ForEach(1...max(roundCount, 1), id: \.self) { index in
                        Circle()
                            .fill(index <= round ? TTColor.brandFill : TTColor.stroke)
                            .frame(width: 4, height: 4)
                    }
                }
                .accessibilityHidden(true)
            }
            .frame(minWidth: 64)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: "Round \(round) of \(roundCount)"))
        .accessibilityIdentifier("battleTracker.scoreboard.round")
    }

    private func sideLabel(_ side: Side) -> String {
        var parts = [
            side.name,
            side.armyName,
            String(localized: "\(side.victoryPoints) victory points")
        ]
        if side.isActive { parts.append(String(localized: "active turn")) }
        if side.isUnderdog { parts.append(String(localized: "underdog")) }
        return parts.joined(separator: ", ")
    }
}
