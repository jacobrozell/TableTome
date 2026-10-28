import SwiftUI

public struct TTEmptyState: View {
    private let title: String
    private let message: String
    private let systemImage: String
    private let primary: (String, () -> Void)?
    private let secondary: (String, () -> Void)?
    private let primaryAccessibilityIdentifier: String

    public init(
        title: String,
        message: String,
        systemImage: String,
        primary: (String, () -> Void)? = nil,
        secondary: (String, () -> Void)? = nil,
        primaryAccessibilityIdentifier: String = "emptyState.primary"
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.primary = primary
        self.secondary = secondary
        self.primaryAccessibilityIdentifier = primaryAccessibilityIdentifier
    }

    public var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            TTIconTile(systemImage: systemImage, tone: .brand, size: 72)
            Text(title)
                .font(TTFont.title)
                .foregroundStyle(TTColor.inkPrimary)
                .multilineTextAlignment(.center)
            Text(message)
                .font(TTFont.callout)
                .foregroundStyle(TTColor.inkSecondary)
                .multilineTextAlignment(.center)
            if let primary {
                Button(primary.0, action: primary.1)
                    .buttonStyle(.ttPrimaryInline)
                    .accessibilityIdentifier(primaryAccessibilityIdentifier)
            }
            if let secondary {
                Button(secondary.0, action: secondary.1)
                    .buttonStyle(.ttTertiary)
            }
        }
        .frame(maxWidth: 420)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
    }
}

#Preview("TTEmptyState") {
    TTPreviewMatrix {
        TTEmptyState(
            title: "No matches yet",
            message: "Finish a battle and it shows up here.",
            systemImage: "flag.checkered"
        )
    }
}
