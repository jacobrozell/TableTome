import SwiftUI

/// Ten-second primer for players who have never played a tabletop battle game.
struct WargamePrimerCard: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Label(String(localized: "New to wargames?"), systemImage: "questionmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(Color.accentOnSurface)
                Spacer(minLength: 0)
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "Dismiss"))
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                primerRow(
                    symbol: "figure.walk",
                    text: String(localized: "Two players move miniatures on a table — distances are in inches.")
                )
                primerRow(
                    symbol: "dice.fill",
                    text: String(localized: "You roll physical dice for attacks; the phone tracks phases and score.")
                )
                primerRow(
                    symbol: "flag.checkered",
                    text: String(localized: "Hold objectives and complete mission goals to earn victory points.")
                )
                primerRow(
                    symbol: "clock.fill",
                    text: String(localized: "A first game usually takes about 60–90 minutes.")
                )
            }

            Button(String(localized: "Got it — show me the turn"), action: onDismiss)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("wargamePrimer.continue")
        }
        .accentHighlightCard()
        .accessibilityIdentifier("wargamePrimer.card")
    }

    private func primerRow(symbol: String, text: String) -> some View {
        Label {
            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: symbol)
                .foregroundStyle(Color.accentOnSurface)
                .symbolRenderingMode(.hierarchical)
        }
    }
}
