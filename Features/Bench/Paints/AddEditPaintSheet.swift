import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

/// Add/edit paint form. Mirrors `paintForm` (`js/render/paints.js`).
struct AddEditPaintSheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFocused: Bool

    let existing: HobbyPaint?
    let extraTypes: [String]
    /// Returns true on success; false on duplicate-name conflict.
    let onSave: (_ name: String, _ type: String, _ brand: String, _ source: String,
                 _ qty: Int, _ notes: String, _ low: Bool,
                 _ swatchHex: String, _ usesCustomSwatch: Bool) -> Bool

    @State private var name: String
    @State private var type: String
    @State private var brand: String
    @State private var source: String
    @State private var qty: Int
    @State private var notes: String
    @State private var low: Bool
    @State private var swatchHex: String
    @State private var usesCustomSwatch: Bool
    @State private var error = false
    @State private var dismissedCatalogSuggestions = false

    init(existing: HobbyPaint?, extraTypes: [String],
         onSave: @escaping (String, String, String, String, Int, String, Bool, String, Bool) -> Bool) {
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
        _swatchHex = State(initialValue: existing?.swatchHex ?? PaintType.swatchHex(for: existing?.type ?? ""))
        _usesCustomSwatch = State(initialValue: existing?.usesCustomSwatch ?? false)
    }

    private var typeOptions: [String] {
        var seen = Set<String>()
        return (PaintType.known + extraTypes).filter { seen.insert($0).inserted }
    }

    var body: some View {
        NavigationStack {
            Form {
                if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                    Section {
                        HStack(spacing: 14) {
                            PaintSwatch(hex: swatchHex, size: 48, cornerRadius: 10)
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(name)
                                        .font(.headline)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    if low {
                                        Text(String(localized: "LOW"))
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(.orange.opacity(0.2), in: Capsule())
                                            .foregroundStyle(.orange)
                                    }
                                }
                                let meta = [type, brand].filter { !$0.isEmpty }.joined(separator: " · ")
                                if !meta.isEmpty {
                                    Text(meta)
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
                    FormNameField(title: String(localized: "Name"), text: $name, focus: $nameFocused)
                        .accessibilityIdentifier("paint.name")
                        .onChange(of: name) { _, _ in
                            dismissedCatalogSuggestions = false
                        }
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
                    } else if existing == nil {
                        Text(type == "Basing" ? FormHints.basingCatalogSearch : FormHints.paintCatalogSearch)
                    }
                }

                PaintCatalogSuggestionsSection(
                    name: name,
                    type: type,
                    isActive: existing == nil && !dismissedCatalogSuggestions,
                    onSelect: applyCatalogEntry
                )

                PaintColorSection(
                    swatchHex: $swatchHex,
                    usesCustomSwatch: $usesCustomSwatch,
                    name: name,
                    brand: brand,
                    type: type
                )

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
            .formEditorScreenChrome()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        if onSave(name, type, brand, source, qty, notes, low, swatchHex, usesCustomSwatch) {
                            dismiss()
                        } else {
                            error = true
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("paint.save")
                }
                .hidingToolbarGlassBackgroundIfAvailable()
            }
            .onAppear {
                if existing == nil {
                    nameFocused = true
                } else if !usesCustomSwatch {
                    swatchHex = PaintSwatchResolver.defaultSwatch(name: name, brand: brand, type: type)
                }
            }
        }
    }

    private func applyCatalogEntry(_ entry: PaintCatalogEntry) {
        name = entry.name
        if let brand = entry.brand { self.brand = brand }
        if let type = entry.type, !type.isEmpty { self.type = type }
        swatchHex = entry.hex
        usesCustomSwatch = false
        dismissedCatalogSuggestions = true
        error = false
    }
}
