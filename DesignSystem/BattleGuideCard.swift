import SwiftUI
import TabletomeDomain

struct BattleGuideCard: View {
    let step: BattleFlowGuideStep
    let onAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Do this now"), systemImage: "hand.point.right.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentColor)

            Text(step.title)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Text(step.instruction)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            if step.kind != .battleComplete {
                PrimaryButton(
                    title: step.actionLabel,
                    accessibilityId: "battleGuide.action"
                ) {
                    onAction()
                }
            } else {
                PrimaryButton(
                    title: String(localized: "Got it"),
                    accessibilityId: "battleGuide.complete"
                ) {
                    onAction()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Spacing.md)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.35), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("battleGuide.card")
    }
}
