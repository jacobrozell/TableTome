import SwiftUI
import TabletomeDomain

struct HomePlayersHubCard: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @State private var profiles: [PlayerProfile] = []
    @State private var primaryProfileId: UUID?

    var body: some View {
        NavigationLink(value: PlayersHubLink()) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Label(String(localized: "Players"), systemImage: "person.2.fill")
                    .font(.headline)
                    .foregroundStyle(Color.accentOnSurface)

                Text(String(localized: "Manage armies, stats, and Guided Match preferences for your household."))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if !profiles.isEmpty {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        ForEach(profiles.prefix(4)) { profile in
                            PlayerAvatarView(
                                name: profile.displayName,
                                accentColorName: profile.accentColorName,
                                size: 36
                            )
                            .overlay(alignment: .bottomTrailing) {
                                if primaryProfileId == profile.id {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.yellow)
                                        .offset(x: 2, y: 2)
                                }
                            }
                        }
                        if profiles.count > 4 {
                            Text("+\(profiles.count - 4)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .accentHighlightCard()
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("home.playersHubCard")
        .task {
            guard let household = try? await dependencies.playerProfileStore.loadHousehold() else { return }
            profiles = household.sortedProfiles
            primaryProfileId = household.defaultPlayerOneProfileId
        }
    }
}
