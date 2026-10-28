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
        TTEmptyState(
            title: title,
            message: message,
            systemImage: systemImage ?? "tray",
            primary: actionTitle.flatMap { title in
                action.map { run in (title, run) }
            },
            primaryAccessibilityIdentifier: "emptyState.retry"
        )
        .padding(DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: shouldScroll ? nil : .infinity)
    }
}
