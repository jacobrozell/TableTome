import SwiftUI
import TabletomeDomain

struct Wh40kDeploymentChecklistCard: View {
    let completedSteps: Set<String>
    let focusedStep: Wh40kDeploymentChecklistStep?
    let onToggle: (Wh40kDeploymentChecklistStep, Bool) -> Void
    var gameSystemId: String = GameSystemId.wh40k11e.rawValue
    var ruleSections: [RuleSection] = []

    private var glossaryText: String {
        Wh40kDeploymentChecklistStep.allCases.map(\.detail).joined(separator: " ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: String(localized: "Deployment Checklist"), systemImage: "map")
            ForEach(Wh40kDeploymentChecklistStep.allCases) { step in
                let isComplete = Wh40kDeploymentChecklist.isComplete(step: step, completedSteps: completedSteps)
                let isFocused = focusedStep == step
                Button {
                    onToggle(step, !isComplete)
                } label: {
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                        Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isComplete ? Color.accentColor : Color(.tertiaryLabel))
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text(step.title)
                                .font(.subheadline.weight(isFocused ? .semibold : .regular))
                                .foregroundStyle(.primary)
                            Text(step.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("guidedMatch.wh40kDeployment.\(step.rawValue)")
            }

            GlossaryChipsRow(
                text: glossaryText,
                gameSystemId: gameSystemId,
                ruleSections: ruleSections
            )

            if let reservesSection = ruleSections.first(where: { $0.id == "11e-reserves" }) {
                ReferenceLinksGroup {
                    NavigationLink(value: RuleSectionLink(gameSystemId: gameSystemId, sectionId: reservesSection.id)) {
                        ReferenceLinkRow(
                            title: reservesSection.title,
                            systemImage: "doc.text"
                        )
                    }
                    .accessibilityIdentifier("guidedMatch.wh40kDeployment.reservesReference")
                }
            }
        }
        .surfaceCard()
    }
}
