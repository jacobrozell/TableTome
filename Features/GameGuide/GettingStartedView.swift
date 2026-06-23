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
                    combatPatrolFirstGameSection
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                Section {
                    NavigationLink(value: CombatPatrolSampleTurnLink()) {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Label(String(localized: "Preview a Turn"), systemImage: "play.circle")
                                .font(.headline)
                            Text(String(localized: "~2 minutes — each battle phase, dice, and scoring"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .accessibilityIdentifier("guide.gettingStarted.combatPatrolSampleTurn")
                }
            }

            if gameSystem.id == "wh40k-11e" {
                Section {
                    Wh40k11eWhatYouNeedCard()
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                Section {
                    NavigationLink(value: Wh40k11eSampleTurnLink()) {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Label(String(localized: "Preview a 40k Turn"), systemImage: "play.circle")
                                .font(.headline)
                            Text(String(localized: "~3 minutes — Command through Fight with 11e rules"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .accessibilityIdentifier("guide.gettingStarted.wh40k11eSampleTurn")
                }
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
                        .contentShape(Rectangle())
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
                        .contentShape(Rectangle())
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

    private var combatPatrolFirstGameSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Your first game"), systemImage: "map")
                .font(.headline)

            CombatPatrolWhatYouNeedCard()

            if let firstStep = sortedSteps.first {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    TappableGuidePathStep(
                        number: 1,
                        title: String(localized: "Read the topics below"),
                        detail: firstStep.summary,
                        destination: GuideStepLink(gameSystemId: gameSystem.id, stepId: firstStep.id),
                        accessibilityId: "guide.combatPatrol.path.firstTopic"
                    )
                    TappableGuidePathStep(
                        number: 2,
                        title: String(localized: "Missions Reference"),
                        detail: String(localized: "Deployment maps and mission rules from your box."),
                        destination: CombatPatrolMissionsLink(gameSystemId: gameSystem.id),
                        accessibilityId: "guide.combatPatrol.path.missions"
                    )
                    TappableGuidePathStep(
                        number: 3,
                        title: String(localized: "Guided Match"),
                        detail: String(localized: "Tap Use Starter Matchup for built-in armies, or pick your patrol boxes."),
                        destination: GuidedMatchLink(gameSystemId: .wh40k10eCp),
                        accessibilityId: "guide.combatPatrol.path.guidedMatch"
                    )
                }
            }
        }
        .accentHighlightCard()
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
