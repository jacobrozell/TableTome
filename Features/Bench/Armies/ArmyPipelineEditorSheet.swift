import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

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
            .formEditorScreenChrome()
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
                        .fontWeight(.semibold)
                }
                .hidingToolbarGlassBackgroundIfAvailable()
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
