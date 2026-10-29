import SwiftUI
import TabletomeDomain

struct HomePlayersHubCard: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @State private var profiles: [PlayerProfile] = []

    var body: some View {
        NavigationLink(value: PlayersHubLink()) {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.md) {
                Image(systemName: "person.2.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentOnSurface)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Players"))
                        .font(.headline)
                    Text(householdSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                if !profiles.isEmpty {
                    HStack(spacing: -8) {
                        ForEach(profiles.prefix(3)) { profile in
                            PlayerAvatarView(
                                name: profile.displayName,
                                accentColorName: profile.accentColorName,
                                size: 32
                            )
                            .overlay {
                                Circle()
                                    .strokeBorder(TTColor.canvas, lineWidth: 2)
                            }
                        }
                    }
                    .accessibilityHidden(true)
                }
            }
            .padding(.vertical, DesignTokens.Spacing.xs)
            .contentShape(Rectangle())
        }
        .accessibilityIdentifier("home.playersHubCard")
        .task {
            guard let household = try? await dependencies.playerProfileStore.loadHousehold() else { return }
            profiles = household.sortedProfiles
        }
    }

    private var householdSubtitle: String {
        if profiles.isEmpty {
            return String(localized: "Manage armies, stats, and Guided Match preferences")
        }
        if profiles.count == 1 {
            return String(localized: "1 player on this device")
        }
        return String(localized: "\(profiles.count) players on this device")
    }
}
