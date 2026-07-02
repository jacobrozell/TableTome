import SwiftUI
import TabletomeDomain

struct SampleTurnSection: View {
    let gameSystemId: GameSystemId

    var body: some View {
        switch gameSystemId {
        case .aosSpearhead:
            Section {
                NavigationLink(value: SampleTurnLink()) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Label(String(localized: "Preview a Spearhead Turn"), systemImage: "play.circle")
                            .font(.headline)
                        Text(String(localized: "Optional — two-minute tour of movement, shooting, dice, and scoring"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .accessibilityIdentifier("guidedMatch.sampleTurn")
            }
        case .wh40k11e:
            Section {
                NavigationLink(value: Wh40k11eSampleTurnLink()) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Label(String(localized: "Preview a 40k Turn"), systemImage: "play.circle")
                            .font(.headline)
                        Text(String(localized: "Command through Fight — 11e charge and pile-in rules"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .accessibilityIdentifier("guidedMatch.wh40k11eSampleTurn")
            }
        case .wh40k10eCp:
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
                .accessibilityIdentifier("guidedMatch.combatPatrolSampleTurn")
            }
        default:
            EmptyView()
        }
    }
}
