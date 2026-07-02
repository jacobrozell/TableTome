import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

/// Move-unit destination picker. Mirrors the `move` action.
struct MoveUnitSheet: View {
    @Environment(\.dismiss) private var dismiss
    let unitName: String
    let destinationArmies: [Army]
    let overrides: [FactionPresetOverride]
    let onMove: (Army) -> Void

    @State private var selection: UUID?

    init(
        unitName: String,
        destinationArmies: [Army],
        overrides: [FactionPresetOverride] = [],
        onMove: @escaping (Army) -> Void
    ) {
        self.unitName = unitName
        self.destinationArmies = destinationArmies
        self.overrides = overrides
        self.onMove = onMove
        _selection = State(initialValue: destinationArmies.first?.id)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 10) {
                        Image(systemName: "figure.stand")
                            .font(.title3)
                            .foregroundStyle(Color.accentOnSurface)
                            .symbolRenderingMode(.hierarchical)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(unitName)
                                .font(.headline)
                            Text(String(localized: "Choose a destination army"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)
                }

                if destinationArmies.isEmpty {
                    Section {
                        ContentUnavailableView {
                            Label(String(localized: "No other armies"), systemImage: "shield")
                        } description: {
                            Text(String(localized: "Create another army in Collection to move this unit."))
                        }
                        .adaptiveEmptyStateLayout()
                    }
                } else {
                    Section {
                        Picker(String(localized: "Destination army"), selection: $selection) {
                            ForEach(destinationArmies) { army in
                                moveArmyRow(army).tag(Optional(army.id))
                            }
                        }
                        .formNavigationPickerStyle()
                    } header: {
                        Text(String(localized: "Move to"))
                    } footer: {
                        Text(String(localized: "\"\(unitName)\" will leave its current army."))
                    }
                }
            }
            .formEditorScreenChrome()
            .navigationTitle(String(localized: "Move unit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Move")) {
                        if let army = destinationArmies.first(where: { $0.id == selection }) {
                            onMove(army)
                        }
                        dismiss()
                    }
                    .disabled(selection == nil || destinationArmies.isEmpty)
                }
                .hidingToolbarGlassBackgroundIfAvailable()
            }
        }
    }

    @ViewBuilder
    private func moveArmyRow(_ army: Army) -> some View {
        let pres = army.presentation(overrides: overrides)
        HStack(spacing: 10) {
            CrestBadge(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
            VStack(alignment: .leading, spacing: 2) {
                Text(army.name)
                    .lineLimit(1)
                Text("\(SupportedGames.displayName(for: army.game)) · \(army.faction)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
