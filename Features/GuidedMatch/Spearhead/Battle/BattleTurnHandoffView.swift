import SwiftUI

struct BattleTurnHandoffView: View {
    let nextIsPlayerOne: Bool
    let nextName: String
    let previousName: String
    let round: Int
    let scoredThisTurn: Int
    let playerOneScore: Int
    let playerTwoScore: Int
    let playerOneName: String
    let playerTwoName: String
    let onStart: () -> Void
    let onBack: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var titleFocused: Bool
    @State private var tokenScale: CGFloat = 0.6

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Spacer()
            TTPlayerToken(isPlayerOne: nextIsPlayerOne, size: 96, isActive: true)
                .scaleEffect(tokenScale)
                .accessibilityHidden(true)
            Text(String(localized: "\(nextName)'s turn"))
                .font(TTFont.display)
                .foregroundStyle(TTColor.player(nextIsPlayerOne))
                .multilineTextAlignment(.center)
                .accessibilityFocused($titleFocused)
            Text(String(localized: "Round \(round) · Pass the device"))
                .font(TTFont.subheadline)
                .foregroundStyle(TTColor.inkSecondary)
            if scoredThisTurn > 0 {
                Text(String(localized: "\(previousName) scored \(scoredThisTurn) this turn"))
                    .font(TTFont.body)
                    .foregroundStyle(TTColor.inkPrimary)
            }
            Text(String(localized: "Score: \(playerOneName) \(playerOneScore) – \(playerTwoScore) \(playerTwoName)"))
                .font(TTFont.footnote)
                .foregroundStyle(TTColor.inkSecondary)
            Spacer()
            Button(String(localized: "Start \(nextName)'s Turn"), action: onStart)
                .buttonStyle(.ttPlayer(isPlayerOne: nextIsPlayerOne))
                .accessibilityIdentifier("battleTracker.handoff.start")
            Button(String(localized: "Back to End of Turn"), action: onBack)
                .buttonStyle(.ttTertiary)
                .accessibilityIdentifier("battleTracker.handoff.back")
        }
        .padding(DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(TTColor.canvas)
        .onAppear {
            titleFocused = true
            tokenScale = reduceMotion ? 1 : 0.6
            withAnimation(TTMotion.emphasis(reduceMotion: reduceMotion)) {
                tokenScale = 1
            }
        }
        .accessibilityIdentifier("battleTracker.handoff")
    }
}
