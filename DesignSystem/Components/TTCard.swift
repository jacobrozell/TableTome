import SwiftUI

public struct TTCard<Content: View>: View {
    private let tone: TTTone?
    private let padding: CGFloat
    private let content: Content

    public init(
        tone: TTTone? = nil,
        padding: CGFloat = DesignTokens.Spacing.md,
        @ViewBuilder content: () -> Content
    ) {
        self.tone = tone
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        if let tone {
            content.accentHighlightCard(tone: tone)
        } else {
            content.surfaceCard(padding: padding)
        }
    }
}

public struct TTHeroCard<Actions: View>: View {
    private let eyebrow: String?
    private let title: String
    private let subtitle: String?
    private let systemImage: String?
    private let tone: TTTone
    private let actions: Actions

    public init(
        eyebrow: String? = nil,
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        tone: TTTone = .brand,
        @ViewBuilder actions: () -> Actions
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tone = tone
        self.actions = actions()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    if let systemImage {
                        TTIconTile(systemImage: systemImage, tone: tone, size: DesignTokens.Size.iconTileLarge)
                    }
                    if let eyebrow {
                        Text(eyebrow).ttEyebrow()
                    }
                    Text(title)
                        .font(TTFont.title)
                        .foregroundStyle(TTColor.inkPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(TTFont.callout)
                            .foregroundStyle(TTColor.inkSecondary)
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 0)
            }
            actions
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.xl, style: .continuous)
                .fill(TTColor.surface)
            RoundedRectangle(cornerRadius: DesignTokens.Radius.xl, style: .continuous)
                .strokeBorder(TTColor.stroke, lineWidth: 1)
            Image(systemName: "book.closed.fill")
                .font(.system(size: 96))
                .foregroundStyle(TTColor.brand.opacity(0.10))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 12, y: -8)
                .accessibilityHidden(true)
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.xl, style: .continuous))
        .ttElevation(.card)
    }
}

public extension TTHeroCard where Actions == EmptyView {
    init(
        eyebrow: String? = nil,
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        tone: TTTone = .brand
    ) {
        self.init(
            eyebrow: eyebrow,
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            tone: tone
        ) { EmptyView() }
    }
}

#Preview("TTHeroCard") {
    TTPreviewMatrix {
        TTHeroCard(title: "Continue your battle", subtitle: "Round 2 · Movement", systemImage: "flag.checkered")
    }
}
