import SwiftUI

/// Native sheet for creating a household player profile.
struct AddPlayerSheet: View {
    @Binding var name: String
    let onCancel: () -> Void
    let onAdd: (String) -> Void

    @FocusState private var isNameFocused: Bool

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Name"), text: $name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .focused($isNameFocused)
                        .accessibilityIdentifier("playersHub.addPlayer.nameField")
                } footer: {
                    Text(String(localized: "Shown in Guided Match and match history on this device."))
                }
            }
            .navigationTitle(String(localized: "Add Player"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel"), action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Add")) {
                        onAdd(trimmedName)
                    }
                    .disabled(trimmedName.isEmpty)
                    .accessibilityIdentifier("playersHub.addPlayer.confirm")
                }
            }
            .onAppear { isNameFocused = true }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
