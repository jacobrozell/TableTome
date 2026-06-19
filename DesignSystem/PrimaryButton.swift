import SwiftUI

public struct PrimaryButton: View {
    let title: String
    let accessibilityId: String
    let accessibilityHint: String?
    let action: () -> Void

    public init(
        title: String,
        accessibilityId: String,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.accessibilityId = accessibilityId
        self.accessibilityHint = accessibilityHint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
        }
        .buttonStyle(.borderedProminent)
        .accessibilityLabel(title)
        .accessibilityIdentifier(accessibilityId)
        .modifier(OptionalAccessibilityHint(hint: accessibilityHint))
    }
}

private struct OptionalAccessibilityHint: ViewModifier {
    let hint: String?

    func body(content: Content) -> some View {
        if let hint {
            content.accessibilityHint(hint)
        } else {
            content
        }
    }
}
