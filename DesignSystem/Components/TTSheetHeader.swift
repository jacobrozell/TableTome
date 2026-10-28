import SwiftUI

public struct TTSheetHeader: View {
    private let title: String
    private let subtitle: String?
    private let tone: TTTone?
    private let onClose: () -> Void

    public init(title: String, subtitle: String? = nil, tone: TTTone? = nil, onClose: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.tone = tone
        self.onClose = onClose
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let tone {
                Rectangle()
                    .fill(tone.solid)
                    .frame(height: 4)
                    .accessibilityHidden(true)
            }
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    Text(title)
                        .font(TTFont.title)
                        .foregroundStyle(TTColor.inkPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(TTFont.callout)
                            .foregroundStyle(TTColor.inkSecondary)
                    }
                }
                Spacer(minLength: 0)
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .frame(width: 44, height: 44)
                        .background(TTColor.sunken, in: Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(TTColor.inkPrimary)
                .accessibilityLabel(String(localized: "Close"))
            }
            .padding(DesignTokens.Spacing.md)
        }
    }
}
