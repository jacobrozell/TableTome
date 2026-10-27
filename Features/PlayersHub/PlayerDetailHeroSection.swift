import SwiftUI
import TabletomeDomain

struct PlayerDetailHeroSection: View {
    let profile: PlayerProfile
    let stats: PlayerMatchStats
    let isPrimary: Bool

    var body: some View {
        Section {
            VStack(spacing: DesignTokens.Spacing.md) {
                PlayerAvatarView(
                    name: profile.displayName,
                    accentColorName: profile.accentColorName,
                    size: 72
                )
                .overlay(alignment: .bottomTrailing) {
                    if isPrimary {
                        Image(systemName: "star.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.yellow, Color(.systemBackground))
                            .offset(x: 4, y: 4)
                            .accessibilityLabel(String(localized: "Primary player on this device"))
                    }
                }

                VStack(spacing: DesignTokens.Spacing.xs) {
                    Text(profile.displayName)
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)

                    HStack(spacing: DesignTokens.Spacing.sm) {
                        if stats.gamesPlayed > 0 {
                            heroChip(
                                title: stats.recordLabel,
                                systemImage: "trophy.fill",
                                tint: .accentColor
                            )
                        } else {
                            heroChip(
                                title: String(localized: "No games yet"),
                                systemImage: "flag.checkered",
                                tint: .secondary
                            )
                        }

                        heroChip(
                            title: armyCountLabel,
                            systemImage: "shield.lefthalf.filled",
                            tint: .secondary
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.sm)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }

    private var armyCountLabel: String {
        let count = profile.ownedSpearheadArmyIds.count
        if count == 1 { return String(localized: "1 army owned") }
        return String(localized: "\(count) armies owned")
    }

    private func heroChip(title: String, systemImage: String, tint: Color) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .monospacedDigit()
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(tint.opacity(0.12), in: Capsule())
            .foregroundStyle(tint == .secondary ? Color.secondary : Color.accentOnSurface)
    }
}
