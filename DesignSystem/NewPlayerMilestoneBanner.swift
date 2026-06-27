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

            Text(milestoneMessage)
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
        .accentHighlightCard()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("newPlayer.milestone.models")
    }

    private func dismiss() {
        onDismiss()
        isVisible = false
    }

    private var milestoneMessage: String {
        if ReleaseSurface.showsMusterTab, !FirstSessionStore.shouldHideHobbyTabs() {
            return String(
                localized: """
                When you're ready to track painted miniatures, open Models. Army lists on the Lists tab can \
                show which units you own.
                """
            )
        }
        return String(
            localized: """
            When you're ready to track painted miniatures, open the Models tab from the tab bar.
            """
        )
    }
}
