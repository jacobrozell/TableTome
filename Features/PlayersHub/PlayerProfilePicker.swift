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
        Section(slotLabel) {
            Picker(String(localized: "Player"), selection: Binding(
                get: { selectedProfileId?.uuidString ?? "guest" },
                set: { newValue in
                    if newValue == "guest" {
                        selectedProfileId = nil
                    } else if let id = UUID(uuidString: newValue) {
                        selectedProfileId = id
                        if let profile = profiles.first(where: { $0.id == id }) {
                            guestName = profile.displayName
                        }
                    }
                }
            )) {
                ForEach(profiles) { profile in
                    HStack {
                        Text(profile.displayName)
                        if primaryProfileId == profile.id {
                            Text(String(localized: "Me"))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tag(profile.id.uuidString)
                }
                Text(String(localized: "Guest…")).tag("guest")
            }
            .pickerStyle(.navigationLink)
            .accessibilityIdentifier("guidedMatch.profilePicker.\(slotLabel)")

            if isGuest {
                TextField(String(localized: "Name"), text: $guestName)
                    .textInputAutocapitalization(.words)
                    .accessibilityIdentifier("guidedMatch.playerNameField")
            }
        }
    }
}
