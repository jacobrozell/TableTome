import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    var regularPortraitLayout: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            deploymentSection
            armyTrackerSection(wideLayout: true, compactSidebar: false)
            HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    turnHandoffSection
                    scoringReminderSection
                    roundOpenerSection
                    coachSection
                    quickActionsSection
                    guideSection
                    shootingPhaseHelper
                    startOfRoundHelper
                    roundAndScoreSection
                    BattleTrackerControlPanel(viewModel: viewModel)
                    secondarySections
                }
                .frame(minWidth: 0, maxWidth: DesignTokens.battleTrackerControlColumnMaxWidth, alignment: .leading)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    damageUndoSection
                    combatPhaseHelper
                    shootInCombatPhaseHelper
                    combatResolverSection()
                    trackerContent
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: DesignTokens.battleTrackerRegularMaxWidth)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var landscapeLayout: some View {
        BattleTrackerLandscapeLayout(
            coach: EmptyView(),
            banners: EmptyView(),
            guide: guideSection,
            deployment: deploymentSection,
            roundAndScore: roundAndScoreSection,
            control: VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                turnHandoffSection
                scoringReminderSection
                roundOpenerSection
                coachSection
                shootingPhaseHelper
                startOfRoundHelper
                BattleTrackerControlPanel(viewModel: viewModel)
            },
            combat: VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                damageUndoSection
                combatPhaseHelper
                shootInCombatPhaseHelper
                combatResolverSection()
            },
            abilities: trackerContent,
            army: armyTrackerSection(wideLayout: false, compactSidebar: true),
            secondary: secondarySections
        )
    }

    var emptyState: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Battle tracker isn't available for this army yet."))
                .font(.headline)
            Text(
                "Ability reminders for this army aren't in Tabletome yet. Use the GW Spearhead PDF link on the army picker for full rules."
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard()
    }
}
