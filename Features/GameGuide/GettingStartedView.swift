import SwiftUI
import TabletomeDomain

struct GettingStartedView: View {
    let gameSystem: GameSystem

    private var sortedSteps: [GuideStep] {
        gameSystem.gettingStartedSteps.sorted { $0.order < $1.order }
    }

    var body: some View {
        List {
            if gameSystem.id == "wh40k-10e-cp" {
                Section {
                    combatPatrolPathCard
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            if gameSystem.id == "aos-spearhead" {
                Section {
                    WhatYouNeedCard()
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                Section {
                    NavigationLink(value: SampleTurnLink()) {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Label(String(localized: "Preview a Spearhead Turn"), systemImage: "play.circle")
                                .font(.headline)
                            Text(String(localized: "~2 minutes — movement, shooting, dice, and scoring"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    }
                    .accessibilityIdentifier("guide.gettingStarted.sampleTurn")
                }
            }

            Section {
                ForEach(Array(sortedSteps.enumerated()), id: \.element.id) { index, step in
                    NavigationLink(value: GuideStepLink(gameSystemId: gameSystem.id, stepId: step.id)) {
                        GuideStepCard(
                            stepNumber: index + 1,
                            title: step.title,
                            summary: step.summary,
                            isComplete: false,
                            showsDisclosureIndicator: false,
                            accessibilityId: "guide.step.\(step.id)"
                        )
                    }
                    .listRowInsets(GuideStepCard.listRowInsets)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            } footer: {
                Text(
                    gameSystem.id == "wh40k-10e-cp"
                        ? String(localized: "Follow the numbered path above, then read topics in any order.")
                        : String(localized: "Read in any order — reference topics, not a checklist.")
                )
                .font(.callout)
            }

            if ReleaseSurface.showsGuidedMatch(for: gameSystem.id) {
                Section {
                    NavigationLink(value: GuidedMatchLink(gameSystemId: GameSystemId(resolving: gameSystem.id))) {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Label(String(localized: "Continue to Guided Match"), systemImage: "flag.checkered")
                                .font(.headline)
                            Text(guidedMatchContinueDetail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    }
                    .accessibilityIdentifier("guide.gettingStarted.continueGuidedMatch")
                } footer: {
                    Text(String(localized: "When you're ready to pick armies and walk through setup at the table."))
                }
            }
        }
        .listStyle(.plain)
        .readableContentWidth()
        .navigationTitle(String(localized: "Getting Started"))
        .playNavigationDestinations()
        .accessibilityIdentifier("guide.stepList")
    }

    private var combatPatrolPathCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "Your first game"), systemImage: "map")
                .font(.headline)
            Text(
                String(
                    localized: """
                    1. Read the topics below  2. Open Missions Reference  3. Run Guided Match and tap Use Starter Matchup
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    private var guidedMatchContinueDetail: String {
        switch gameSystem.id {
        case GameSystemId.aosSpearhead.rawValue:
            String(localized: "Use Starter Matchup to fill both starter armies automatically.")
        case GameSystemId.wh40k10eCp.rawValue:
            String(localized: "Starter matchup, setup steps, and battle tracker")
        case GameSystemId.wh40k11e.rawValue:
            String(localized: "Armageddon starter matchup and setup steps")
        case GameSystemId.scTmg.rawValue:
            String(localized: "Raynor vs Kerrigan Founders Edition matchup")
        default:
            String(localized: "Interactive setup and battle tracker")
        }
    }
}
