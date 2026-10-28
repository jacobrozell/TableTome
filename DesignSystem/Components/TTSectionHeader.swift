import SwiftUI

public struct TTSectionHeader<Trailing: View>: View {
    private let title: String
    private let systemImage: String?
    private let trailing: Trailing

    public init(
        _ title: String,
        systemImage: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.systemImage = systemImage
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(TTColor.inkTertiary)
                    .accessibilityHidden(true)
            }
            Text(title)
                .ttEyebrow()
            Spacer(minLength: 0)
            trailing
        }
        .padding(.top, DesignTokens.Spacing.sm)
        .padding(.bottom, DesignTokens.Spacing.xs)
        .accessibilityAddTraits(.isHeader)
    }
}

public extension TTSectionHeader where Trailing == EmptyView {
    init(_ title: String, systemImage: String? = nil) {
        self.init(title, systemImage: systemImage) { EmptyView() }
    }
}

#Preview("TTSectionHeader") {
    TTPreviewMatrix {
        TTSectionHeader("This phase", systemImage: "flag.checkered")
    }
}
