import SwiftUI

struct MatchVictoryHeadlineSection: View {
    let mode: MatchVictoryScreen.Mode
    let headlineTitle: String
    let headlineSymbol: String
    let headlineSymbolColor: Color
    let celebrateScale: CGFloat
    let isDraw: Bool
    let winnerName: String?
    let voiceOverSummary: String

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: headlineSymbol)
                .font(mode == .readOnly ? .title : .largeTitle)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(headlineSymbolColor)
                .scaleEffect(celebrateScale)
                .accessibilityHidden(true)

            Text(headlineTitle)
                .font(mode == .readOnly ? .title.bold() : .largeTitle.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(headlineSymbolColor)

            if isDraw {
                Text(String(localized: "Tied on victory points"))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else if let winnerName {
                Text(winnerName)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(voiceOverSummary)
    }
}
