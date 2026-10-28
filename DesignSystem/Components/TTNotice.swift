import SwiftUI

public struct TTNotice: View {
    private let title: String
    private let message: String?
    private let systemImage: String
    private let tone: TTTone
    private let action: (title: String, run: () -> Void)?
    private let onDismiss: (() -> Void)?

    public init(
        title: String,
        message: String? = nil,
        systemImage: String,
        tone: TTTone = .brand,
        action: (title: String, run: () -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.tone = tone
        self.action = action
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: systemImage)
                .foregroundStyle(tone.foreground)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(title)
                    .font(TTFont.headline)
                    .foregroundStyle(TTColor.inkPrimary)
                if let message {
                    Text(message)
                        .font(TTFont.callout)
                        .foregroundStyle(TTColor.inkSecondary)
                        .lineLimit(3)
                }
                if let action {
                    Button(action.title, action: action.run)
                        .buttonStyle(.ttTertiary)
                }
            }
            Spacer(minLength: 0)
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "Dismiss"))
            }
        }
        .accentHighlightCard(tone: tone)
        .accessibilityElement(children: .contain)
    }
}

public struct TTToast: View {
    private let message: String
    private let systemImage: String?
    private let tone: TTTone
    private let actionTitle: String?
    private let action: (() -> Void)?
    private let onDismiss: () -> Void

    public init(
        message: String,
        systemImage: String? = nil,
        tone: TTTone = .neutral,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        onDismiss: @escaping () -> Void
    ) {
        self.message = message
        self.systemImage = systemImage
        self.tone = tone
        self.actionTitle = actionTitle
        self.action = action
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(tone.foreground)
                    .accessibilityHidden(true)
            }
            Text(message)
                .font(TTFont.subheadline)
                .foregroundStyle(TTColor.inkPrimary)
                .lineLimit(1)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.ttTertiary)
            }
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "Dismiss"))
        }
        .padding(.leading, DesignTokens.Spacing.md)
        .padding(.trailing, DesignTokens.Spacing.xs)
        .background(TTColor.raised, in: Capsule())
        .ttElevation(.raised)
        .accessibilityElement(children: .combine)
    }
}

#Preview("TTNotice") {
    TTPreviewMatrix {
        TTNotice(title: "Draw your battle tactic cards", systemImage: "info.circle")
    }
}
