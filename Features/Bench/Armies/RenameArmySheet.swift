import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

/// Rename-army form.
struct RenameArmySheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFocused: Bool
    let army: Army?
    let overrides: [FactionPresetOverride]
    let current: String
    let onRename: (String) -> Bool

    @State private var name: String
    @State private var error = false

    init(
        army: Army? = nil,
        overrides: [FactionPresetOverride] = [],
        current: String,
        onRename: @escaping (String) -> Bool
    ) {
        self.army = army
        self.overrides = overrides
        self.current = current
        self.onRename = onRename
        _name = State(initialValue: current)
    }

    var body: some View {
        NavigationStack {
            Form {
                if let army {
                    Section {
                        HStack(spacing: 12) {
                            let pres = army.presentation(overrides: overrides)
                            CrestBadge(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(army.name)
                                    .font(.headline)
                                HStack(spacing: 5) {
                                    Image(systemName: HobbyGameSymbol.systemImage(for: army.game))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(Color.accentOnSurface)
                                        .symbolRenderingMode(.hierarchical)
                                        .accessibilityHidden(true)
                                    Text("\(SupportedGames.displayName(for: army.game)) · \(army.faction)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section {
                    FormNameField(title: String(localized: "Army name"), text: $name, focus: $nameFocused)
                } header: {
                    Text(String(localized: "Name"))
                } footer: {
                    if error {
                        FormValidationFooter(message: String(localized: "That name is taken."))
                    } else {
                        Text(FormHints.uniqueName)
                    }
                }
            }
            .formEditorScreenChrome()
            .navigationTitle(String(localized: "Rename army"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) { if onRename(name) { dismiss() } else { error = true } }
                        .fontWeight(.semibold)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .hidingToolbarGlassBackgroundIfAvailable()
            }
            .onAppear { nameFocused = true }
        }
    }
}
