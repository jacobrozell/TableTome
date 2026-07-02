import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

struct LinkArmySheet: View {
    @Environment(\.dismiss) private var dismiss
    let roster: Roster
    let armies: [Army]
    let overrides: [FactionPresetOverride]
    let onSelect: (UUID?) -> Void

    @State private var selection: UUID?

    var body: some View {
        NavigationStack {
            Form {
                if armies.isEmpty {
                    Section {
                        ContentUnavailableView {
                            Label(String(localized: "No matching armies"), systemImage: "shield")
                        } description: {
                            Text(
                                String(
                                    localized: """
                                    Add a \(roster.faction) army in Collection first, then link it here.
                                    """
                                )
                            )
                        }
                        .adaptiveEmptyStateLayout()
                    }
                } else {
                    Section {
                        Picker(String(localized: "Collection army"), selection: $selection) {
                            Text(String(localized: "None")).tag(UUID?.none)
                            ForEach(armies) { army in
                                LinkArmyPickerRow(army: army, overrides: overrides).tag(Optional(army.id))
                            }
                        }
                        .formNavigationPickerStyle()
                    } header: {
                        Text(String(localized: "Link to Models"))
                    } footer: {
                        Text(FormHints.rosterLink)
                    }
                }
            }
            .formEditorScreenChrome()
            .navigationTitle(String(localized: "Link army"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        onSelect(selection)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(armies.isEmpty)
                }
                .hidingToolbarGlassBackgroundIfAvailable()
            }
            .onAppear { selection = roster.linkedArmyId }
        }
    }
}

struct LinkArmyPickerRow: View {
    let army: Army
    let overrides: [FactionPresetOverride]

    var body: some View {
        let pres = army.presentation(overrides: overrides)
        HStack(spacing: 10) {
            CrestBadge(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
            VStack(alignment: .leading, spacing: 2) {
                Text(army.name)
                    .lineLimit(1)
                Text(army.faction)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
