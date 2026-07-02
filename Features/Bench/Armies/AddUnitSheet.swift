import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

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
                    FormNameField(
                        title: String(localized: "Unit name"),
                        text: $name,
                        prompt: String(localized: "Intercessors (5)"),
                        focus: $nameFocused
                    )
                    .accessibilityIdentifier("unitName")
                    QuantityStepper(label: String(localized: "Quantity"), value: $qty)
                    if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                        ModelCountSummary(name: name, qty: qty)
                    }
                } header: {
                    Text(String(localized: "Unit"))
                } footer: {
                    Text(FormHints.modelCountBeginner)
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
            .formEditorScreenChrome()
            .navigationTitle(String(localized: "Add unit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Add")) { onAdd(name, qty, source, state, trackPerModel, memberStates); dismiss() }
                    .accessibilityIdentifier("addUnitConfirm")
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .hidingToolbarGlassBackgroundIfAvailable()
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
