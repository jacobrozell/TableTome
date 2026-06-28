import SwiftUI
import TabletomeDomain

struct Wh40kDeploymentChecklistCard: View {
    let completedSteps: Set<String>
    let focusedStep: Wh40kDeploymentChecklistStep?
    let onToggle: (Wh40kDeploymentChecklistStep, Bool) -> Void
    var compactMode: Bool = false
    var gameSystemId: String = GameSystemId.wh40k11e.rawValue
    var ruleSections: [RuleSection] = []

    private var visibleSteps: [Wh40kDeploymentChecklistStep] {
        if !compactMode {
            return Wh40kDeploymentChecklistStep.allCases
        }
        if let focusedStep {
            return [focusedStep]
        }
        if let next = Wh40kDeploymentChecklistStep.allCases.first(where: {
            !Wh40kDeploymentChecklist.isComplete(step: $0, completedSteps: completedSteps)
        }) {
            return [next]
        }
        return []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: String(localized: "Deployment Checklist"), systemImage: "map")
            ForEach(visibleSteps) { step in
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
                            InlineGlossaryText(
                                text: step.detail,
                                gameSystemId: gameSystemId,
                                ruleSections: ruleSections,
                                font: .caption,
                                foregroundStyle: .secondary
                            )
                            .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("guidedMatch.wh40kDeployment.\(step.rawValue)")
            }

            if focusedStep == .confirmReserves {
                Label {
                    Text(
                        String(
                            localized: """
                            Units still off the board after battle round 3 are destroyed — including Strategic Reserves \
                            and Deep Strike.
                            """
                        )
                    )
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
                .padding(DesignTokens.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
                .accessibilityIdentifier("guidedMatch.wh40kDeployment.reservesReminder")
            }

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
