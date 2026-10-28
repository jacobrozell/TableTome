import SwiftUI

public struct TTKeyValueRow: View {
    private let key: String
    private let value: String
    private let systemImage: String?

    public init(_ key: String, value: String, systemImage: String? = nil) {
        self.key = key
        self.value = value
        self.systemImage = systemImage
    }

    public var body: some View {
        LabeledContent {
            Text(value)
                .font(TTFont.bodyEmphasis)
                .foregroundStyle(TTColor.inkPrimary)
        } label: {
            HStack(spacing: DesignTokens.Spacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(TTColor.brand)
                        .accessibilityHidden(true)
                }
                Text(key)
                    .font(TTFont.subheadline)
                    .foregroundStyle(TTColor.inkSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
