import SwiftUI

/// Soft nudge after setup or the first battle round — optional Models tab cross-link.
struct NewPlayerMilestoneBanner: View {
    @Environment(AppRouter.self) private var router

    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "Nice — you're playing"), systemImage: "party.popper.fill")
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            Text(
                String(
                    localized: """
                    When you're ready to track painted miniatures, open Models. Army lists on the Lists tab can \
                    show which units you own.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: DesignTokens.Spacing.sm) {
                if ReleaseSurface.showsBenchTab {
                    Button(String(localized: "Open Models")) {
                        router.tab = .armies
                        onDismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .accessibilityIdentifier("milestone.openModels")
                }

                Button(String(localized: "Later")) {
                    onDismiss()
                }
                .buttonStyle(.bordered)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("milestone.dismiss")
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("newPlayer.milestone.models")
    }
}
