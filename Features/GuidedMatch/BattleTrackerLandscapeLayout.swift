import SwiftUI
import TabletomeDomain

/// iPad landscape body: controls | combat + abilities | army health sidebar.
struct BattleTrackerLandscapeLayout<
    Coach: View,
    Banners: View,
    Guide: View,
    Deployment: View,
    RoundAndScore: View,
    Control: View,
    Combat: View,
    Abilities: View,
    Army: View,
    Secondary: View
>: View {
    let coach: Coach
    let banners: Banners
    let guide: Guide
    let deployment: Deployment
    let roundAndScore: RoundAndScore
    let control: Control
    let combat: Combat
    let abilities: Abilities
    let army: Army
    let secondary: Secondary

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.battleTrackerLandscapeSectionSpacing) {
            coach
            banners
            guide
            HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignTokens.battleTrackerLandscapeSectionSpacing) {
                    deployment
                    roundAndScore
                    control
                    secondary
                }
                .frame(
                    minWidth: 0,
                    maxWidth: DesignTokens.battleTrackerLandscapeControlColumnMaxWidth,
                    alignment: .leading
                )

                VStack(alignment: .leading, spacing: DesignTokens.battleTrackerLandscapeSectionSpacing) {
                    combat
                    abilities
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

                army
                    .frame(
                        minWidth: DesignTokens.battleTrackerLandscapeArmyColumnMaxWidth * 0.85,
                        maxWidth: DesignTokens.battleTrackerLandscapeArmyColumnMaxWidth,
                        alignment: .leading
                    )
                    .layoutPriority(0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("battleTracker.landscapeLayout")
    }
}

/// Compact horizontal cluster for transient battle tracker notices in landscape.
struct BattleTrackerLandscapeBannerRow<TurnHandoff: View, DamageUndo: View>: View {
    let turnHandoff: TurnHandoff
    let damageUndo: DamageUndo

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                turnHandoff
                damageUndo
            }
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                turnHandoff
                damageUndo
            }
        }
    }
}
