import SwiftUI
import TabletomeDomain

struct GuideStepDetailView: View {
    let gameSystemId: String
    let step: GuideStep
    @State private var isComplete = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(step.body)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                if !step.tips.isEmpty {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text(String(localized: "Tips"))
                            .font(.headline)
                        ForEach(step.tips, id: \.self) { tip in
                            Label(tip, systemImage: "lightbulb")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(DesignTokens.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
                }

                Toggle(isOn: $isComplete) {
                    Text(String(localized: "Mark step complete"))
                        .font(.headline)
                }
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("guide.stepComplete.\(step.id)")
                .onChange(of: isComplete) { _, newValue in
                    GuideProgressStore.setComplete(newValue, gameSystemId: gameSystemId, stepId: step.id)
                }
            }
            .padding(DesignTokens.Spacing.md)
        }
        .navigationTitle(step.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isComplete = GuideProgressStore.isComplete(gameSystemId: gameSystemId, stepId: step.id)
        }
        .animation(reduceMotion ? nil : .default, value: isComplete)
    }
}
