import SwiftUI

/// Renders a component in light, dark, and AX3 so previews cover the release matrix.
public struct TTPreviewMatrix<Content: View>: View {
    @ViewBuilder private var content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                sample("Light", scheme: .light, size: .large)
                sample("Dark", scheme: .dark, size: .large)
                sample("AX3", scheme: .light, size: .accessibility3)
            }
            .padding(DesignTokens.Spacing.md)
        }
        .background(TTColor.canvas)
    }

    private func sample(_ title: String, scheme: ColorScheme, size: DynamicTypeSize) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(title).ttEyebrow()
            content()
                .environment(\.colorScheme, scheme)
                .environment(\.dynamicTypeSize, size)
                .padding(DesignTokens.Spacing.md)
                .background(TTColor.canvas)
        }
    }
}
