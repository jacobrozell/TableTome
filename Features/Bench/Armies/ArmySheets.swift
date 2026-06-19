import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

/// New-army form. Mirrors `createArmyFlow` (`js/render/armies.js`).
struct AddArmySheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFocused: Bool
    let onCreate: (_ game: String, _ faction: String, _ name: String) -> Bool

    @State private var game = "40k"
    @State private var faction = ""
    @State private var customFaction = ""
    @State private var name = ""
    @State private var error = false

    private var factions: [String] { FactionResolver.canonicalByGame[game]?.sorted() ?? [] }
    private var resolvedFaction: String { faction == customSentinel ? customFaction : faction }

    private let customSentinel = "\u{0}custom"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Game", selection: $game) {
                        ForEach(SupportedGames.all, id: \.self) { Text($0).tag($0) }
                    }
                    .formNavigationPickerStyle()
                    .onChange(of: game) { _, _ in faction = "" }

                    Picker("Faction", selection: $faction) {
                        Text("Choose…").tag("")
                        ForEach(factions, id: \.self) { Text($0).tag($0) }
                        Text("Custom…").tag(customSentinel)
                    }
                    .formNavigationPickerStyle()
                    if faction == customSentinel {
                        TextField("Custom faction", text: $customFaction)
                            .textInputAutocapitalization(.words)
                    }
                } header: {
                    Text("Game & faction")
                }

                Section {
                    FormNameField(title: "Army name", text: $name, focus: $nameFocused)
                } header: {
                    Text("Name")
                } footer: {
                    if error {
                        FormValidationFooter(message: "That army name is already taken.")
                    } else {
                        Text(FormHints.uniqueName)
                    }
                }
            }
            .navigationTitle("New army")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let f = resolvedFaction.isEmpty ? "Custom" : resolvedFaction
                        if onCreate(game, f, name) { dismiss() } else { error = true }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { nameFocused = true }
        }
    }
}

/// Add-unit form. Mirrors the `add` action.
struct AddUnitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFocused: Bool
    let pipeline: [PipelineStage]
    let onAdd: (_ name: String, _ qty: Int, _ source: String, _ state: String) -> Void

    @State private var name = ""
    @State private var qty = 1
    @State private var source = ""
    @State private var state: String

    init(pipeline: [PipelineStage],
         onAdd: @escaping (String, Int, String, String) -> Void) {
        self.pipeline = pipeline
        self.onAdd = onAdd
        _state = State(initialValue: pipeline.first?.key ?? "Unassembled")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    FormNameField(title: "ArmyUnit name", text: $name, focus: $nameFocused)
                    QuantityStepper(label: "Quantity", value: $qty)
                } header: {
                    Text("ArmyUnit")
                }

                Section {
                    TextField("Source", text: $source)
                        .textInputAutocapitalization(.words)
                    Picker("Starting state", selection: $state) {
                        ForEach(pipeline) { Text($0.key).tag($0.key) }
                    }
                    .formNavigationPickerStyle()
                } header: {
                    Text("Details")
                } footer: {
                    Text(FormHints.source)
                }
            }
            .navigationTitle("Add unit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { onAdd(name, qty, source, state); dismiss() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { nameFocused = true }
        }
    }
}

/// Rename-army form.
struct RenameArmySheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFocused: Bool
    let current: String
    let onRename: (String) -> Bool

    @State private var name: String
    @State private var error = false

    init(current: String, onRename: @escaping (String) -> Bool) {
        self.current = current
        self.onRename = onRename
        _name = State(initialValue: current)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    FormNameField(title: "Army name", text: $name, focus: $nameFocused)
                } footer: {
                    if error {
                        FormValidationFooter(message: "That name is taken.")
                    } else {
                        Text(FormHints.uniqueName)
                    }
                }
            }
            .navigationTitle("Rename army")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { if onRename(name) { dismiss() } else { error = true } }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { nameFocused = true }
        }
    }
}

/// Per-army pipeline editor. Mirrors `openArmyPipelineSettings` (`settings-panel.js`).
struct ArmyPipelineEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var army: Army
    let globalPipeline: [PipelineStage]?

    enum Mode: String, CaseIterable { case global, custom }

    @State private var mode: Mode = .global
    @State private var stages: [PipelineStage] = []

    private var resolvedGlobal: [PipelineStage] { Pipeline.resolve(globalPipeline) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Pipeline", selection: $mode) {
                        Text("Use global pipeline").tag(Mode.global)
                        Text("Custom for this army").tag(Mode.custom)
                    }
                    .pickerStyle(.segmented)
                } footer: {
                    if mode == .global {
                        Text("Uses the stages from Settings → Pipeline.")
                    }
                }

                if mode == .custom {
                    Section {
                        ForEach(Array(stages.enumerated()), id: \.offset) { index, _ in
                            HStack {
                                TextField("Stage name", text: $stages[index].key)
                                ColorPicker("", selection: Binding(
                                    get: { Color(hex: stages[index].hex) },
                                    set: { stages[index].hex = $0.hexString }))
                                .labelsHidden()
                            }
                        }
                        .onDelete { stages.remove(atOffsets: $0) }
                        .onMove { stages.move(fromOffsets: $0, toOffset: $1) }

                        Button("Add stage", systemImage: "plus") {
                            stages.append(PipelineStage(key: "New", hex: "#888888"))
                        }
                        Button("Reset to default") { stages = DefaultPipeline.stages }
                    } header: {
                        Text("Stages")
                    } footer: {
                        Text("Drag to reorder. Swipe left to delete.")
                    }
                }
            }
            .navigationTitle("Army pipeline")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save(); dismiss() } }
                if mode == .custom { ToolbarItem(placement: .topBarLeading) { EditButton() } }
            }
            .onAppear {
                let custom = army.customPipeline
                mode = (custom?.isEmpty == false) ? .custom : .global
                stages = Pipeline.resolve(custom ?? resolvedGlobal)
            }
        }
    }

    private func save() {
        if mode == .global {
            army.customPipeline = nil
        } else {
            let cleaned = stages
                .filter { !$0.key.trimmingCharacters(in: .whitespaces).isEmpty }
                .map { PipelineStage(key: $0.key, hex: safeColor($0.hex)) }
            army.customPipeline = cleaned.isEmpty ? nil : cleaned
        }
        try? context.save()
    }
}

/// Move-unit destination picker. Mirrors the `move` action.
struct MoveUnitSheet: View {
    @Environment(\.dismiss) private var dismiss
    let unitName: String
    let destinations: [String]
    let onMove: (String) -> Void

    @State private var selection: String

    init(unitName: String, destinations: [String], onMove: @escaping (String) -> Void) {
        self.unitName = unitName
        self.destinations = destinations
        self.onMove = onMove
        _selection = State(initialValue: destinations.first ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Destination army", selection: $selection) {
                        ForEach(destinations, id: \.self) { Text($0).tag($0) }
                    }
                    .formNavigationPickerStyle()
                } header: {
                    Text("Move to")
                } footer: {
                    Text("\"\(unitName)\" will leave its current army.")
                }
            }
            .navigationTitle("Move unit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Move") { onMove(selection); dismiss() }
                        .disabled(selection.isEmpty)
                }
            }
        }
    }
}
