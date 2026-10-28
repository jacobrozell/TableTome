import SwiftUI

struct OnboardingIllustrationView: View {
    let kind: OnboardingIllustration

    var body: some View {
        Group {
            switch kind {
            case .crest:
                crest
            case .phaseRail:
                phaseRail
            case .scoreboard:
                scoreboard
            }
        }
        .accessibilityHidden(true)
    }

    private var crest: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [TTColor.parchment.opacity(0.18), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 90
                    )
                )
            Circle()
                .stroke(TTColor.brand.opacity(0.25), lineWidth: 1)
                .padding(8)
            Circle()
                .stroke(TTColor.brand.opacity(0.25), lineWidth: 1)
                .padding(22)
            BrandCrest(size: 160)
        }
        .frame(width: 220, height: 220)
    }

    private var phaseRail: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            TTBadge("Hero", tone: .brand, style: .solid)
            TTBadge("Move", tone: .neutral, style: .soft)
            TTBadge("Shoot", tone: .neutral, style: .soft)
            TTBadge("Charge", tone: .neutral, style: .soft)
            TTBadge("Combat", tone: .neutral, style: .soft)
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(TTColor.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                .strokeBorder(TTColor.stroke, lineWidth: 1)
        }
    }

    private var scoreboard: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            TTPlayerToken(isPlayerOne: true, isActive: true)
            Text("3")
                .font(TTFont.numericHero)
                .foregroundStyle(TTColor.playerOne)
            Text("2")
                .font(TTFont.numericHero)
                .foregroundStyle(TTColor.inkSecondary)
            Text("2")
                .font(TTFont.numericHero)
                .foregroundStyle(TTColor.playerTwo)
            TTPlayerToken(isPlayerOne: false)
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(TTColor.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
    }
}
