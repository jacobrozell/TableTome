import SwiftUI
import TabletomeDomain

/// Step-by-step guide for players upgrading from 10th Edition to 11th.
struct EditionMigrationView: View {
    let gameSystem: GameSystem

    private var sortedSteps: [GuideStep] {
        gameSystem.editionMigrationSteps.sorted { $0.order < $1.order }
    }

    private var introText: String {
        switch gameSystem.id {
        case "sc-tmg":
            String(
                localized: """
                Coming from StarCraft II? These five cards map RTS habits — supply, fog of war, APM — to the tabletop rules.
                """
            )
        default:
            String(
                localized: """
                Your codexes still work — this guide covers what changed at the table in 11th Edition. \
                Summaries only; confirm details in the official core rules PDF.
                """
            )
        }
    }

    private var navigationTitleText: String {
        switch gameSystem.id {
        case "sc-tmg": String(localized: "RTS → Tabletop")
        default: String(localized: "What's New in 11e")
        }
    }

    var body: some View {
        List {
            Section {
                Text(introText)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

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
                        accessibilityId: "guide.migration.\(step.id)"
                    )
                }
                .listRowInsets(GuideStepCard.listRowInsets)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .readableContentWidth()
        .navigationTitle(navigationTitleText)
        .accessibilityIdentifier("guide.migrationList")
    }
}
