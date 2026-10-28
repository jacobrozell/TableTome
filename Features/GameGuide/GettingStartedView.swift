import SwiftUI
import TabletomeDomain

struct GettingStartedView: View {
    let gameSystem: GameSystem

    @State private var readSteps: Set<String> = []
    @ScaledMetric(relativeTo: .body) private var circleSize: CGFloat = 28

    private var sortedSteps: [GuideStep] {
        gameSystem.gettingStartedSteps.sorted { $0.order < $1.order }
    }

    private var capabilities: PlayCapabilities {
        GameSystemPlayContext.context(for: gameSystem.id).capabilities
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                if capabilities.usesPatrolFormatRules {
                    combatPatrolFirstGameSection
                    sampleRow(
                        value: CombatPatrolSampleTurnLink(),
                        title: String(localized: "Preview a Turn"),
                        subtitle: String(localized: "~2 minutes — each battle phase, dice, and scoring"),
                        identifier: "guide.gettingStarted.combatPatrolSampleTurn"
                    )
                }

                if capabilities.deploymentChecklistStyle == .wh40k {
                    Wh40k11eWhatYouNeedCard()
                    sampleRow(
                        value: Wh40k11eSampleTurnLink(),
                        title: String(localized: "Preview a 40k Turn"),
                        subtitle: String(localized: "~3 minutes — Command through Fight with 11e rules"),
                        identifier: "guide.gettingStarted.wh40k11eSampleTurn"
                    )
                }

                if capabilities.showsBattleTacticDecks {
                    sampleRow(
                        value: SampleTurnLink(),
                        title: String(localized: "Preview a Spearhead Turn"),
                        subtitle: String(localized: "2-minute walkthrough"),
                        identifier: "guide.gettingStarted.sampleTurn"
                    )
                }

                if gameSystem.id == GameSystemId.scTmg.rawValue {
                    ScWhatYouNeedCard()
                }

                TTSectionHeader(String(localized: "Your First Game"))
                timeline

                if ReleaseSurface.showsGuidedMatch(for: gameSystem.id) {
                    NavigationLink(value: GuidedMatchLink(gameSystemId: GameSystemId(resolving: gameSystem.id))) {
                        Text(String(localized: "Start a Battle"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.ttPrimary)
                    .accessibilityIdentifier("guide.gettingStarted.continueGuidedMatch")
                }
            }
            .padding(DesignTokens.Spacing.md)
            .readableContentWidth()
        }
        .ttScreenBackground()
        .tabBarScrollInset()
        .navigationTitle(String(localized: "Getting Started"))
        .accessibilityIdentifier("guide.stepList")
        .onAppear {
            readSteps = GuideProgressStore.readStepIds(gameSystemId: gameSystem.id)
        }
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(sortedSteps.enumerated()), id: \.element.id) { index, step in
                NavigationLink(value: GuideStepLink(gameSystemId: gameSystem.id, stepId: step.id)) {
                    timelineRow(index: index, step: step)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("guide.step.\(step.id)")
            }
        }
    }

    private func timelineRow(index: Int, step: GuideStep) -> some View {
        let isLast = index == sortedSteps.count - 1
        let isRead = readSteps.contains(step.id)
        return HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            VStack(spacing: 0) {
                stepCircle(number: index + 1, isRead: isRead)
                if !isLast {
                    Rectangle()
                        .fill(TTColor.stroke)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: circleSize)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(step.title)
                    .font(TTFont.headline)
                    .foregroundStyle(TTColor.inkPrimary)
                Text(step.summary)
                    .font(TTFont.subheadline)
                    .foregroundStyle(TTColor.inkSecondary)
                    .lineLimit(2)
            }
            .padding(.bottom, DesignTokens.Spacing.md)
            Spacer(minLength: 0)
        }
        .frame(minHeight: 64, alignment: .top)
        .contentShape(Rectangle())
    }

    private func stepCircle(number: Int, isRead: Bool) -> some View {
        ZStack {
            Circle().fill(isRead ? TTColor.successSoft : TTColor.brandFill)
            if isRead {
                Image(systemName: "checkmark")
                    .font(TTFont.caption.weight(.bold))
                    .foregroundStyle(TTColor.success)
            } else {
                Text("\(number)")
                    .font(TTFont.numericSmall)
                    .foregroundStyle(TTColor.inkOnBrand)
            }
        }
        .frame(width: circleSize, height: circleSize)
        .accessibilityHidden(true)
    }

    private func sampleRow<T: Hashable>(
        value: T,
        title: String,
        subtitle: String,
        identifier: String
    ) -> some View {
        TTCard(padding: 0) {
            NavigationLink(value: value) {
                TTRow(title: title, subtitle: subtitle, systemImage: "play.circle")
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(identifier)
        }
    }

    private var combatPatrolFirstGameSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            TTSectionHeader(String(localized: "Your first game"))
            CombatPatrolWhatYouNeedCard()
            if let firstStep = sortedSteps.first {
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
                GuidePathInfoStep(
                    number: 3,
                    title: String(localized: "Guided Match"),
                    detail: String(
                        localized: "Use Start a Battle below — then Use Starter Matchup."
                    ),
                    accessibilityId: "guide.combatPatrol.path.guidedMatch"
                )
            }
        }
    }
}
