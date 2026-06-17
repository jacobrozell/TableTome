import SwiftUI

public struct GuideStepCard: View {
    public static let listRowInsets = EdgeInsets(
        top: DesignTokens.Spacing.xs,
        leading: DesignTokens.Spacing.md,
        bottom: DesignTokens.Spacing.xs,
        trailing: DesignTokens.Spacing.md
    )

    let stepNumber: Int
    let title: String
    let summary: String
    let isComplete: Bool
    let showsDisclosureIndicator: Bool
    let accessibilityId: String

    @ScaledMetric(relativeTo: .subheadline) private var stepCircleSize: CGFloat = 36

    public init(
        stepNumber: Int,
        title: String,
        summary: String,
        isComplete: Bool,
        showsDisclosureIndicator: Bool = true,
        accessibilityId: String
    ) {
        self.stepNumber = stepNumber
        self.title = title
        self.summary = summary
        self.isComplete = isComplete
        self.showsDisclosureIndicator = showsDisclosureIndicator
        self.accessibilityId = accessibilityId
    }

    public var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            ZStack {
                Circle()
                    .fill(isComplete ? Color.green.opacity(0.2) : Color.accentColor.opacity(0.15))
                    .frame(width: stepCircleSize, height: stepCircleSize)
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                        .accessibilityHidden(true)
                } else {
                    Text("\(stepNumber)")
                        .font(.subheadline.bold())
                        .accessibilityHidden(true)
                }
            }
            .accessibilityLabel(isComplete ? "Step \(stepNumber) complete" : "Step \(stepNumber)")

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            if showsDisclosureIndicator {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.quaternary)
                    .accessibilityHidden(true)
            }
        }
        .surfaceCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(summary)")
        .accessibilityHint(isComplete ? "Completed step" : "Opens step details")
        .accessibilityIdentifier(accessibilityId)
    }
}
