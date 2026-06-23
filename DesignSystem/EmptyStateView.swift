import SwiftUI

public struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String?
    let actionTitle: String?
    let action: (() -> Void)?

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public init(
        title: String,
        message: String,
        systemImage: String? = "tray",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        Group {
            if shouldScroll {
                ScrollView {
                    content
                }
            } else {
                content
            }
        }
    }

    private var shouldScroll: Bool {
        verticalSizeClass == .compact || dynamicTypeSize.isAccessibilitySize
    }

    private var content: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)
            }
            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                PrimaryButton(
                    title: actionTitle,
                    accessibilityId: "emptyState.retry",
                    accessibilityHint: String(localized: "Tries loading this content again."),
                    action: action
                )
                .padding(.top, DesignTokens.Spacing.sm)
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: shouldScroll ? nil : .infinity)
        .accessibilityElement(children: .contain)
    }
}
