import SwiftUI

public struct TTBadge: View {
    public enum Style: Equatable {
        case soft, solid, outline
    }

    private let text: String
    private let tone: TTTone
    private let style: Style
    private let systemImage: String?

    public init(
        _ text: String,
        tone: TTTone = .neutral,
        style: Style = .soft,
        systemImage: String? = nil
    ) {
        self.text = text
        self.tone = tone
        self.style = style
        self.systemImage = systemImage
    }

    public var body: some View {
        HStack(spacing: DesignTokens.Spacing.xxs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .accessibilityHidden(true)
            }
            Text(text)
        }
        .font(TTFont.caption.weight(.semibold))
        .foregroundStyle(foreground)
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, 3)
        .background(background, in: Capsule())
        .overlay {
            if style == .outline {
                Capsule().strokeBorder(tone.foreground, lineWidth: 1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }

    private var foreground: Color {
        style == .solid ? tone.onSolid : tone.foreground
    }

    private var background: Color {
        switch style {
        case .soft: tone.soft
        case .solid: tone.solid
        case .outline: .clear
        }
    }
}

#Preview("TTBadge") {
    TTPreviewMatrix {
        HStack {
            TTBadge("Active", tone: .playerOne, style: .solid)
            TTBadge("Destroyed", tone: .danger)
            TTBadge("Attacker", style: .outline)
        }
    }
}
