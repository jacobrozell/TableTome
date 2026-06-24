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
    private var displayFaction: String {
        let f = resolvedFaction.trimmingCharacters(in: .whitespaces)
        return f.isEmpty ? "Custom" : f
    }
    private var factionPreview: (crest: String, colorHex: String) {
        let r = FactionResolver.resolve(faction: displayFaction, game: game, overrides: [])
        return (r.crest, r.color)
    }

    private let customSentinel = "\u{0}custom"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(String(localized: "Game"), selection: $game) {
                        ForEach(SupportedGames.all, id: \.self) { g in
                            HStack(spacing: 8) {
                                Image(systemName: HobbyGameSymbol.systemImage(for: g))
                                    .foregroundStyle(Color.accentOnSurface)
                                    .symbolRenderingMode(.hierarchical)
                                    .frame(width: 20)
                                    .accessibilityHidden(true)
                                Text(g)
                            }
                            .tag(g)
                        }
                    }
                    .formNavigationPickerStyle()
                    .onChange(of: game) { _, _ in faction = "" }

                    Picker(String(localized: "Faction"), selection: $faction) {
                        Text(String(localized: "Choose…")).tag("")
                        ForEach(factions, id: \.self) { f in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color(hex: FactionResolver.resolve(faction: f, game: game, overrides: []).color))
                                    .frame(width: 8, height: 8)
                                    .accessibilityHidden(true)
                                Text(f)
                            }
                            .tag(f)
                        }
                        Text(String(localized: "Custom…")).tag(customSentinel)
                    }
                    .formNavigationPickerStyle()
                    if faction == customSentinel {
                        TextField(String(localized: "Custom faction"), text: $customFaction)
                            .textInputAutocapitalization(.words)
                    }
                    if !faction.isEmpty {
                        HStack(spacing: 12) {
                            CrestBadge(text: factionPreview.crest, colorHex: factionPreview.colorHex)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(String(localized: "Preview"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(displayFaction)
                                    .font(.subheadline.weight(.medium))
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 4)
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Add")) {
                        let f = resolvedFaction.isEmpty ? "Custom" : resolvedFaction
                        if onCreate(game, f, name) { dismiss() } else { error = true }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || faction.isEmpty)
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
                    LabeledContent {
                        StateChip(state: state, pipeline: pipeline)
                    } label: {
                        Text(String(localized: "Starting state"))
                    }
                    Picker(String(localized: "Starting state"), selection: $state) {
                        ForEach(pipeline) { stage in
                            PipelineStagePickerRow(stage: stage).tag(stage.key)
                        }
                    }
                    .formNavigationPickerStyle()
                    .labelsHidden()
                    .accessibilityLabel(String(localized: "Starting state"))
                    .accessibilityValue(state)
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
            .navigationBarTitleDisplayMode(.inline)
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
                            CrestBadge(text: pres.crest, colorHex: pres.colorHex)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(army.name)
                                    .font(.headline)
                                HStack(spacing: 5) {
                                    Image(systemName: HobbyGameSymbol.systemImage(for: army.game))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(Color.accentOnSurface)
                                        .symbolRenderingMode(.hierarchical)
                                        .accessibilityHidden(true)
                                    Text("\(army.game) · \(army.faction)")
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
            .navigationTitle(String(localized: "Rename army"))
            .navigationBarTitleDisplayMode(.inline)
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
    var overrides: [FactionPresetOverride] = []

    enum Mode: String, CaseIterable { case global, custom }

    @State private var mode: Mode = .global
    @State private var stages: [PipelineStage] = []

    private var resolvedGlobal: [PipelineStage] { Pipeline.resolve(globalPipeline) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    let pres = army.presentation(overrides: overrides)
                    HStack(spacing: 12) {
                        CrestBadge(text: pres.crest, colorHex: pres.colorHex)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(army.name)
                                .font(.headline)
                            HStack(spacing: 5) {
                                Image(systemName: HobbyGameSymbol.systemImage(for: army.game))
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(Color.accentOnSurface)
                                    .symbolRenderingMode(.hierarchical)
                                    .accessibilityHidden(true)
                                Text(army.faction)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)
                }

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

                if mode == .global {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(resolvedGlobal) { stage in
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(Color(hex: stage.hex))
                                            .frame(width: 8, height: 8)
                                            .accessibilityHidden(true)
                                        Text(stage.key)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(.quaternary.opacity(0.5), in: Capsule())
                                }
                            }
                        }
                        .padding(.vertical, 2)
                    } header: {
                        Text(String(localized: "Global stages"))
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
            .tabBarScrollInset()
            .readableContentWidth()
            .navigationTitle(String(localized: "Army pipeline"))
            .navigationBarTitleDisplayMode(.inline)
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
            }
        }
    }

    @ViewBuilder
    private func moveArmyRow(_ army: Army) -> some View {
        let pres = army.presentation(overrides: overrides)
        HStack(spacing: 10) {
            CrestBadge(text: pres.crest, colorHex: pres.colorHex)
            VStack(alignment: .leading, spacing: 2) {
                Text(army.name)
                    .lineLimit(1)
                Text("\(army.game) · \(army.faction)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
