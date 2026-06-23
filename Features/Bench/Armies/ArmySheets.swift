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
                    Picker(String(localized: "Game"), selection: $game) {
                        ForEach(SupportedGames.all, id: \.self) { Text($0).tag($0) }
                    }
                    .formNavigationPickerStyle()
                    .onChange(of: game) { _, _ in faction = "" }

                    Picker(String(localized: "Faction"), selection: $faction) {
                        Text(String(localized: "Choose…")).tag("")
                        ForEach(factions, id: \.self) { Text($0).tag($0) }
                        Text(String(localized: "Custom…")).tag(customSentinel)
                    }
                    .formNavigationPickerStyle()
                    if faction == customSentinel {
                        TextField(String(localized: "Custom faction"), text: $customFaction)
                            .textInputAutocapitalization(.words)
                    }
                } header: {
                    Text(String(localized: "Game & faction"))
                }

                Section {
                    FormNameField(title: String(localized: "Army name"), text: $name, focus: $nameFocused)
                } header: {
                    Text(String(localized: "Name"))
                } footer: {
                    if error {
                        FormValidationFooter(message: String(localized: "That army name is already taken."))
                    } else {
                        Text(FormHints.uniqueName)
                    }
                }
            }
            .navigationTitle(String(localized: "New army"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Add")) {
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
    let onAdd: (_ name: String, _ qty: Int, _ source: String, _ state: String,
                _ trackPerModel: Bool, _ memberStates: [String]) -> Void

    @State private var name = ""
    @State private var qty = 1
    @State private var source = ""
    @State private var state: String
    @State private var trackPerModel = false
    @State private var memberStates: [String] = []

    private var modelCount: Int { ModelCount.of(name: name, qty: qty) }
    private var trackable: Bool { modelCount >= 2 }

    init(pipeline: [PipelineStage],
         onAdd: @escaping (String, Int, String, String, Bool, [String]) -> Void) {
        self.pipeline = pipeline
        self.onAdd = onAdd
        _state = State(initialValue: pipeline.first?.key ?? "Unassembled")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    FormNameField(title: String(localized: "Unit name"), text: $name, focus: $nameFocused)
                    QuantityStepper(label: String(localized: "Quantity"), value: $qty)
                    if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                        ModelCountSummary(name: name, qty: qty)
                    }
                } header: {
                    Text(String(localized: "Unit"))
                } footer: {
                    Text(FormHints.modelCount)
                }

                Section {
                    TextField(String(localized: "Source"), text: $source)
                        .textInputAutocapitalization(.words)
                    Picker(String(localized: "Starting state"), selection: $state) {
                        ForEach(pipeline) { Text($0.key).tag($0.key) }
                    }
                    .formNavigationPickerStyle()
                } header: {
                    Text(String(localized: "Details"))
                } footer: {
                    Text(FormHints.source)
                }

                if trackable {
                    Section {
                        Toggle(String(localized: "Track per model"), isOn: $trackPerModel)
                        if trackPerModel {
                            if !memberStateSummary.isEmpty {
                                Text(memberStateSummary)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            ForEach(0..<modelCount, id: \.self) { index in
                                AddUnitModelRow(
                                    index: index,
                                    modelCount: modelCount,
                                    state: memberStateBinding(for: index),
                                    pipeline: pipeline
                                )
                            }
                        }
                    } header: {
                        Text(String(localized: "Models"))
                    } footer: {
                        Text(trackPerModel ? FormHints.trackPerModel : FormHints.trackPerModelOff)
                    }
                }
            }
            .navigationTitle(String(localized: "Add unit"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Add")) {
                        onAdd(name, qty, source, state, trackPerModel, memberStates)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                nameFocused = true
                syncMemberStates()
            }
            .onChange(of: name) { _, _ in syncMemberStates() }
            .onChange(of: qty) { _, _ in syncMemberStates() }
            .onChange(of: state) { _, new in
                guard trackPerModel else { return }
                for i in memberStates.indices { memberStates[i] = new }
            }
            .onChange(of: trackPerModel) { _, enabled in
                if enabled { syncMemberStates() }
            }
            .onChange(of: modelCount) { _, count in
                if count < 2 { trackPerModel = false }
                syncMemberStates()
            }
        }
    }

    private var memberStateSummary: String {
        guard trackPerModel, memberStates.count > 1 else { return "" }
        guard Set(memberStates).count > 1 else { return "" }
        var counts: [String: Int] = [:]
        for s in memberStates { counts[s, default: 0] += 1 }
        return counts
            .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
            .map { "\($0.value)× \($0.key)" }
            .joined(separator: ", ")
    }

    private func syncMemberStates() {
        let target = modelCount
        if memberStates.count < target {
            memberStates.append(contentsOf: Array(repeating: state, count: target - memberStates.count))
        } else if memberStates.count > target {
            memberStates.removeLast(memberStates.count - target)
        }
    }

    private func memberStateBinding(for index: Int) -> Binding<String> {
        Binding(
            get: { memberStates.indices.contains(index) ? memberStates[index] : state },
            set: { newValue in
                guard memberStates.indices.contains(index) else { return }
                memberStates[index] = newValue
            }
        )
    }
}

/// Per-model starting state row in the add-unit sheet.
private struct AddUnitModelRow: View {
    let index: Int
    let modelCount: Int
    @Binding var state: String
    let pipeline: [PipelineStage]

    var body: some View {
        HStack(spacing: 8) {
            Text(String(localized: "Model \(index + 1)"))
                .font(.subheadline)
            Spacer(minLength: 8)
            StateMenu(state: state, pipeline: pipeline) { state = $0 }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            String(localized: "Model \(index + 1) of \(modelCount), state \(state)")
        )
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
                    FormNameField(title: String(localized: "Army name"), text: $name, focus: $nameFocused)
                } footer: {
                    if error {
                        FormValidationFooter(message: String(localized: "That name is taken."))
                    } else {
                        Text(FormHints.uniqueName)
                    }
                }
            }
            .navigationTitle(String(localized: "Rename army"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) { if onRename(name) { dismiss() } else { error = true } }
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
                    Picker(String(localized: "Pipeline"), selection: $mode) {
                        Text(String(localized: "Use global pipeline")).tag(Mode.global)
                        Text(String(localized: "Custom for this army")).tag(Mode.custom)
                    }
                    .pickerStyle(.segmented)
                } footer: {
                    if mode == .global {
                        Text(String(localized: "Uses the stages from Settings → Pipeline."))
                    }
                }

                if mode == .custom {
                    Section {
                        ForEach(Array(stages.enumerated()), id: \.offset) { index, _ in
                            HStack {
                                TextField(String(localized: "Stage name"), text: $stages[index].key)
                                ColorPicker("", selection: Binding(
                                    get: { Color(hex: stages[index].hex) },
                                    set: { stages[index].hex = $0.hexString }))
                                .labelsHidden()
                            }
                        }
                        .onDelete { stages.remove(atOffsets: $0) }
                        .onMove { stages.move(fromOffsets: $0, toOffset: $1) }

                        Button(String(localized: "Add stage"), systemImage: "plus") {
                            stages.append(PipelineStage(key: "New", hex: "#888888"))
                        }
                        Button(String(localized: "Reset to default")) { stages = DefaultPipeline.stages }
                    } header: {
                        Text(String(localized: "Stages"))
                    } footer: {
                        Text(String(localized: "Drag to reorder. Swipe left to delete."))
                    }
                }
            }
            .navigationTitle(String(localized: "Army pipeline"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) { save(); dismiss() }
                }
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
                    Picker(String(localized: "Destination army"), selection: $selection) {
                        ForEach(destinations, id: \.self) { Text($0).tag($0) }
                    }
                    .formNavigationPickerStyle()
                } header: {
                    Text(String(localized: "Move to"))
                } footer: {
                    Text(String(localized: "\"\(unitName)\" will leave its current army."))
                }
            }
            .navigationTitle(String(localized: "Move unit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Move")) { onMove(selection); dismiss() }
                        .disabled(selection.isEmpty)
                }
            }
        }
    }
}
