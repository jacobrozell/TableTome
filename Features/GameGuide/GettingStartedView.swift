import SwiftUI
import TabletomeDomain

struct GettingStartedView: View {
    let gameSystem: GameSystem

    private var sortedSteps: [GuideStep] {
        gameSystem.gettingStartedSteps.sorted { $0.order < $1.order }
    }

    var body: some View {
        List {
            ForEach(Array(sortedSteps.enumerated()), id: \.element.id) { index, step in
                NavigationLink {
                    GuideStepDetailView(
                        gameSystemId: gameSystem.id,
                        step: step,
                        ruleSections: gameSystem.ruleSections
                    )
                } label: {
                    GuideStepCard(
                        stepNumber: index + 1,
                        title: step.title,
                        summary: step.summary,
                        isComplete: GuideProgressStore.isComplete(gameSystemId: gameSystem.id, stepId: step.id),
                        showsDisclosureIndicator: false,
                        accessibilityId: "guide.step.\(step.id)"
                    )
                }
                .listRowInsets(GuideStepCard.listRowInsets)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .readableContentWidth()
        .navigationTitle(String(localized: "Getting Started"))
        .accessibilityIdentifier("guide.stepList")
    }
}
