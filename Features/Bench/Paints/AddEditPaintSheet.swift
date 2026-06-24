import SwiftUI
import TabletomeHobbyData

/// Add/edit paint form. Mirrors `paintForm` (`js/render/paints.js`).
struct AddEditPaintSheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFocused: Bool

    let existing: HobbyPaint?
    let extraTypes: [String]
    /// Returns true on success; false on duplicate-name conflict.
    let onSave: (_ name: String, _ type: String, _ brand: String, _ source: String,
                 _ qty: Int, _ notes: String, _ low: Bool) -> Bool

    @State private var name: String
    @State private var type: String
    @State private var brand: String
    @State private var source: String
    @State private var qty: Int
    @State private var notes: String
    @State private var low: Bool
    @State private var error = false

    init(existing: HobbyPaint?, extraTypes: [String],
         onSave: @escaping (String, String, String, String, Int, String, Bool) -> Bool) {
        self.existing = existing
        self.extraTypes = extraTypes
        self.onSave = onSave
        _name = State(initialValue: existing?.name ?? "")
        _type = State(initialValue: existing?.type ?? "")
        _brand = State(initialValue: existing?.brand ?? "")
        _source = State(initialValue: existing?.source ?? "")
        _qty = State(initialValue: existing?.qty ?? 1)
        _notes = State(initialValue: existing?.notes ?? "")
        _low = State(initialValue: existing?.low ?? false)
    }

    private var typeOptions: [String] {
        var seen = Set<String>()
        return (PaintType.known + extraTypes).filter { seen.insert($0).inserted }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    FormNameField(title: String(localized: "Name"), text: $name, focus: $nameFocused)
                    Picker(String(localized: "Type"), selection: $type) {
                        ForEach(typeOptions, id: \.self) { Text($0.isEmpty ? "—" : $0).tag($0) }
                    }
                    .formNavigationPickerStyle()
                    TextField(String(localized: "Brand"), text: $brand)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text(String(localized: "Paint"))
                } footer: {
                    if error {
                        FormValidationFooter(
                            message: String(localized: "A paint with that name already exists.")
                        )
                    }
                }

                Section {
                    QuantityStepper(label: String(localized: "Quantity"), value: $qty)
                    Toggle(String(localized: "Running low"), isOn: $low)
                } header: {
                    Text(String(localized: "Inventory"))
                } footer: {
                    Text(FormHints.paintLow)
                }

                Section {
                    TextField(String(localized: "Source"), text: $source)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text(String(localized: "Collection link"))
                } footer: {
                    Text(FormHints.paintSource)
                }

                Section {
                    FormNotesField(title: String(localized: "Notes"), text: $notes, lineLimit: 2...6)
                } header: {
                    Text(String(localized: "Notes"))
                }
            }
            .navigationTitle(
                existing == nil
                    ? String(localized: "Add paint")
                    : String(localized: "Edit paint")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        if onSave(name, type, brand, source, qty, notes, low) { dismiss() }
                        else { error = true }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { if existing == nil { nameFocused = true } }
        }
    }
}
