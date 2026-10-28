import SwiftUI

struct MatchVictoryPlayerColumnSection: View {
    let name: String
    let army: String
    let victoryPoints: Int
    let isWinner: Bool
    let highlightTie: Bool
    let isPlayerOne: Bool

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                TTPlayerToken(isPlayerOne: isPlayerOne, size: 22)
                Text(name)
                    .font(TTFont.headline)
                    .foregroundStyle(TTColor.inkPrimary)
                    .lineLimit(1)
            }
            Text("\(victoryPoints)")
                .font(TTFont.numericHero)
                .foregroundStyle(isWinner || highlightTie ? TTColor.player(isPlayerOne) : TTColor.inkSecondary)
                .accessibilityLabel(String(localized: "\(victoryPoints) victory points"))
            Text(army)
                .font(TTFont.footnote)
                .foregroundStyle(TTColor.inkSecondary)
                .multilineTextAlignment(.center)
            if isWinner {
                TTBadge(String(localized: "Winner"), tone: .brand, style: .solid, systemImage: "crown.fill")
            }
        }
        .frame(maxWidth: .infinity)
        .surfaceCard()
        .overlay(alignment: .top) {
            if isWinner || highlightTie {
                Rectangle()
                    .fill(highlightTie ? TTColor.brandFill : TTColor.player(isPlayerOne))
                    .frame(height: 4)
            }
        }
        .accessibilityIdentifier(
            isPlayerOne ? "matchVictory.winner.playerOne" : "matchVictory.winner.playerTwo"
        )
    }
}
