import SwiftUI

public struct PrimaryButton: View {
    let title: String
    let accessibilityId: String
    let action: () -> Void

    public init(title: String, accessibilityId: String, action: @escaping () -> Void) {
        self.title = title
        self.accessibilityId = accessibilityId
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
    }
}
