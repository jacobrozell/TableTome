import SwiftUI
import TabletomeDomain

/// Round 2+ table-side reminder — priority roll picks first turn; underdog refreshes battle tactics (not first turn).
struct SpearheadRoundTwoPlusOpenerCard: View {
    let battleRound: Int
    let underdogPlayerName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(roundTitle, systemImage: "dice.fill")
                .font(.headline)

            Text(
                String(
                    localized: """
                    Roll off for priority — the winner picks who takes the first turn this round. That is separate from \
                    the underdog: whoever has fewer victory points refreshes their battle tactic hand.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            if let underdogPlayerName {
                Text(
                    String(
                        localized: "\(underdogPlayerName) is the underdog this round — draw a fresh battle tactic after the priority roll."
                    )
                )
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.accentOnSurface)
                .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(
                    String(
                        localized: "If victory points are tied, there is no underdog — both players keep their tactics."
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            Text(
                String(
                    localized: "Use the round opener checklist above when you are ready — twist card and tactic hands come next."
                )
            )
            .font(.caption)
            .foregroundStyle(.tertiary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .accentHighlightCard()
        .accessibilityIdentifier("battleTracker.roundTwoPlusOpener")
    }

    private var roundTitle: String {
        String(localized: "Round \(battleRound) — roll for priority")
    }
}
