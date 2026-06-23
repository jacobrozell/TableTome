import SwiftUI
import TabletomeDomain

struct BattleGuideCard: View {
    let step: BattleFlowGuideStep
    let onAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Do this now"), systemImage: "hand.point.right.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentOnSurface)

            Text(step.title)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(step.instruction)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            PrimaryButton(
                title: step.actionLabel,
                accessibilityId: step.kind == .battleComplete ? "battleGuide.complete" : "battleGuide.action"
            ) {
                onAction()
            }
        }
        .accentHighlightCard()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("battleGuide.card")
    }
}
