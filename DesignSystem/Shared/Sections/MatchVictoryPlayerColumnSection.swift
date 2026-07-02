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
            Text(name.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(isWinner || highlightTie ? Color.primary : .secondary)

            Text(army)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(victoryPoints)")
                .font(isWinner || highlightTie ? .largeTitle.bold() : .title2)
                .foregroundStyle(isWinner || highlightTie ? Color.primary : .secondary)
                .accessibilityLabel(
                    String(localized: "\(victoryPoints) victory points")
                )

            if isWinner {
                Label(String(localized: "Winner"), systemImage: "star.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.accentColor)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignTokens.Spacing.md)
        .background(
            (isWinner || highlightTie ? Color.accentColor.opacity(0.12) : Color(.secondarySystemBackground)),
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
        )
        .overlay {
            if isWinner || highlightTie {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .strokeBorder(Color.accentColor, lineWidth: 2)
            }
        }
        .accessibilityIdentifier(
            isPlayerOne ? "matchVictory.winner.playerOne" : "matchVictory.winner.playerTwo"
        )
    }
}
