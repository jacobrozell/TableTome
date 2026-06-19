import SwiftUI

/// Soft nudge after setup or the first battle round — optional Models tab cross-link.
struct NewPlayerMilestoneBanner: View {
    @Environment(AppRouter.self) private var router
    @State private var isVisible = true

    let onDismiss: () -> Void

    var body: some View {
        if isVisible {
            bannerContent
        }
    }

    private var bannerContent: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "Nice — you're playing"), systemImage: "party.popper.fill")
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)

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
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .accessibilityIdentifier("milestone.openModels")
                    .accessibilityHint(String(localized: "Switches to the Models tab to track miniatures."))
                }

                Button(String(localized: "Later")) {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("milestone.dismiss")
                .accessibilityHint(String(localized: "Dismisses this reminder for now."))
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

    private func dismiss() {
        onDismiss()
        isVisible = false
    }
}
