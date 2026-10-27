import SwiftUI
import TabletomeDomain

/// Profile picker for Guided Match army selection — household profiles plus Guest.
struct PlayerProfilePicker: View {
    let profiles: [PlayerProfile]
    let primaryProfileId: UUID?
    @Binding var selectedProfileId: UUID?
    @Binding var guestName: String
    let slotLabel: String

    private var isGuest: Bool { selectedProfileId == nil }

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        ForEach(profiles) { profile in
                            profileChip(profile)
                        }
                        guestChip
                    }
                    .padding(.vertical, 2)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("guidedMatch.profilePicker.\(slotLabel)")

            if isGuest {
                TextField(String(localized: "Guest name"), text: $guestName)
                    .textInputAutocapitalization(.words)
                    .accessibilityIdentifier("guidedMatch.playerNameField")
            } else if let profile = profiles.first(where: { $0.id == selectedProfileId }) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    PlayerAvatarView(
                        name: profile.displayName,
                        accentColorName: profile.accentColorName,
                        size: 32
                    )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(profile.displayName)
                            .font(.subheadline.weight(.semibold))
                        if !profile.ownedSpearheadArmyIds.isEmpty {
                            Text(
                                String(
                                    localized: "\(profile.ownedSpearheadArmyIds.count) owned armies in Players"
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(DesignTokens.Spacing.sm)
                .background(Color(.tertiarySystemFill), in: CardSurface.shape(radius: DesignTokens.Radius.inset))
            }
        } header: {
            Text(slotLabel.isEmpty ? String(localized: "Who is playing?") : slotLabel)
        } footer: {
            Text(
                String(
                    localized: "Pick a saved player or enter a guest name. Owned armies filter the list below."
                )
            )
        }
    }

    private func profileChip(_ profile: PlayerProfile) -> some View {
        let isSelected = selectedProfileId == profile.id
        return Button {
            selectedProfileId = profile.id
            guestName = profile.displayName
        } label: {
            VStack(spacing: DesignTokens.Spacing.xs) {
                PlayerAvatarView(
                    name: profile.displayName,
                    accentColorName: profile.accentColorName,
                    size: 44
                )
                .overlay {
                    if isSelected {
                        Circle()
                            .strokeBorder(Color.accentColor, lineWidth: 3)
                    }
                }
                Text(profile.displayName)
                    .font(.caption.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.accentOnSurface : Color.primary)
                    .lineLimit(1)
                    .frame(maxWidth: 72)
                if primaryProfileId == profile.id {
                    Text(String(localized: "Me"))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.xs)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(
                isSelected ? Color.accentColor.opacity(0.1) : Color(.tertiarySystemFill),
                in: CardSurface.shape(radius: DesignTokens.Radius.nested)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(profile.displayName)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var guestChip: some View {
        Button {
            selectedProfileId = nil
        } label: {
            VStack(spacing: DesignTokens.Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(Color(.tertiarySystemFill))
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .overlay {
                    if isGuest {
                        Circle()
                            .strokeBorder(Color.accentColor, lineWidth: 3)
                            .frame(width: 44, height: 44)
                    }
                }
                Text(String(localized: "Guest"))
                    .font(.caption.weight(isGuest ? .semibold : .regular))
                    .foregroundStyle(isGuest ? Color.accentOnSurface : Color.primary)
                Text(" ")
                    .font(.caption2)
            }
            .padding(.horizontal, DesignTokens.Spacing.xs)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(
                isGuest ? Color.accentColor.opacity(0.1) : Color(.tertiarySystemFill),
                in: CardSurface.shape(radius: DesignTokens.Radius.nested)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: "Guest player"))
        .accessibilityAddTraits(isGuest ? [.isSelected] : [])
    }
}
