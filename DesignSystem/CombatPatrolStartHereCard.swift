import SwiftUI
import TabletomeDomain

struct CombatPatrolStartHereCard: View {
    let gameSystem: GameSystem
    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Start here"), systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            Text(
                String(
                    localized: """
                    New to Combat Patrol or 10th Edition? Follow this path for your first Leviathan box-set battle \
                    with guided setup, dice tools, and scoring.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                step(String(localized: "Getting Started"), String(localized: "Board size, phases, and the 8-step pre-battle sequence."))
                step(String(localized: "Preview a Turn"), String(localized: "Walk through Command → Fight on the Turn tab."))
                step(String(localized: "Guided Match"), String(localized: "Space Marines vs Tyranids — Clash of Patrols starter."))
            }

            NavigationLink {
                GettingStartedView(gameSystem: gameSystem)
            } label: {
                Label(String(localized: "Getting Started"), systemImage: "map")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("guide.combatPatrol.gettingStarted")

            NavigationLink {
                CombatPatrolSampleTurnWalkthroughView()
            } label: {
                Label(String(localized: "Preview a Turn"), systemImage: "arrow.triangle.2.circlepath")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("guide.combatPatrol.sampleTurn")

            NavigationLink {
                GuidedMatchView(
                    viewModel: dependencies.makeGuidedMatchViewModel(gameSystemId: .wh40k10eCp),
                    ruleSections: gameSystem.ruleSections
                )
            } label: {
                Label(String(localized: "Guided Match"), systemImage: "flag.checkered")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("guide.combatPatrol.guidedMatch")
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
        .accessibilityIdentifier("guide.combatPatrol.startHere")
    }

    private func step(_ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.accentColor)
                .font(.caption)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
