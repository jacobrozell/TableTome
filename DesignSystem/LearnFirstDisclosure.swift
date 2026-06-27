import SwiftUI

/// Secondary learn links grouped under one disclosure — used on start-here cards.
struct LearnFirstDisclosure<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        DisclosureGroup(String(localized: "Learn first")) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                content()
            }
            .padding(.top, DesignTokens.Spacing.xs)
        }
        .font(.subheadline.weight(.semibold))
    }
}
