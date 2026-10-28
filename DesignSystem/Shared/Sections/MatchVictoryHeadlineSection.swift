import SwiftUI

struct MatchVictoryHeadlineSection: View {
    let mode: MatchVictoryScreen.Mode
    let headlineTitle: String
    let headlineSymbol: String
    let headlineSymbolColor: Color
    let celebrateScale: CGFloat
    let subtitle: String
    let voiceOverSummary: String

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: headlineSymbol)
                .font(.system(size: mode == .readOnly ? 36 : 56))
                .foregroundStyle(headlineSymbolColor)
                .scaleEffect(celebrateScale)
                .accessibilityHidden(true)

            Text(headlineTitle)
                .font(mode == .readOnly ? TTFont.title : TTFont.display)
                .multilineTextAlignment(.center)
                .foregroundStyle(headlineSymbolColor)

            Text(subtitle)
                .font(TTFont.subheadline)
                .foregroundStyle(TTColor.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(voiceOverSummary)
    }
}
