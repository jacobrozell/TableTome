import SwiftUI
import SwiftData
import PhotosUI
import TabletomeHobbyData
import TabletomeDomain
#if canImport(UIKit)
import UIKit
#endif

@MainActor
struct HobbySettingsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(BannerCenter.self) private var banner
    @Query private var configs: [AppConfiguration]
    @Query private var armies: [Army]

    private var cfg: AppConfiguration { configs.first ?? HobbyConfig.current(context) }

    var body: some View {
        @Bindable var cfg = cfg
        Form {
            Section {
                NavigationLink(value: HobbySettingsRoute.pipeline) {
                    Label(String(localized: "Pipeline stages"), systemImage: "arrow.right.to.line")
                }
                NavigationLink(value: HobbySettingsRoute.factions) {
                    Label(String(localized: "Faction crests & colours"), systemImage: "shield.lefthalf.filled")
                }
            } header: {
                Text(String(localized: "Painting"))
            } footer: {
                Text(String(localized: "Customize painting stages and how armies appear in your collection."))
            }

            if ReleaseSurface.showsMusterTab {
                MusterSettingsSection(cfg: cfg)
            }

            CollectionSettingsSection(cfg: cfg)

            SettingsDataSection()

            Section(String(localized: "Help & Feedback")) {
                NavigationLink(value: HobbySettingsRoute.accessibility) {
                    Label(String(localized: "Accessibility"), systemImage: "accessibility")
                }
                NavigationLink(value: HobbySettingsRoute.privacy) {
                    Label(String(localized: "Privacy Policy"), systemImage: "hand.raised")
                }
            }

            Section(String(localized: "About")) {
                LabeledContent(String(localized: "App"), value: AppInfo.displayName)
                LabeledContent(String(localized: "Version")) {
                    Text(Bundle.main.appVersion)
                        .foregroundStyle(.secondary)
                }
                Text(String(localized: "For the Emperor · For the Great Horned Rat · Sigmar Watches"))
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle(String(localized: "Collection & Data"))
        .navigationBarTitleDisplayMode(.inline)
        .tabBarScrollInset()
        .navigationDestination(for: HobbySettingsRoute.self) { route in
            switch route {
            case .pipeline:
                PipelineEditor(cfg: cfg)
            case .factions:
                FactionOverridesEditor(cfg: cfg, armies: armies)
            case .accessibility:
                AccessibilityView()
            case .privacy:
                PrivacyPolicyView()
            }
        }
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button(String(localized: "Done")) { dismiss() } } }
    }
}

/// Global pipeline editor.
private struct PipelineEditor: View {
    @Environment(\.modelContext) private var context
    @Bindable var cfg: AppConfiguration
    @State private var stages: [PipelineStage] = []

    var body: some View {
        Form {
            Section {
                if !stages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(stages) { stage in
                                HStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color(hex: stage.hex))
                                        .frame(width: 8, height: 8)
                                    Text(stage.key)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
                ForEach(Array(stages.enumerated()), id: \.offset) { index, _ in
                    HStack {
                        TextField(String(localized: "Stage name"), text: $stages[index].key)
                        ColorPicker("", selection: Binding(
                            get: { Color(hex: stages[index].hex) },
                            set: { stages[index].hex = $0.hexString }))
                        .labelsHidden()
                        .accessibilityLabel(String(localized: "Stage color"))
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
                Text(FormHints.pipelineStages)
            }
        }
        .navigationTitle(String(localized: "Pipeline"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { EditButton() }
        .onAppear { stages = Pipeline.resolve(cfg.globalPipeline) }
        .onDisappear {
            let cleaned = stages
                .filter { !$0.key.trimmingCharacters(in: .whitespaces).isEmpty }
                .map { PipelineStage(key: $0.key, hex: safeColor($0.hex)) }
            cfg.globalPipeline = (cleaned.isEmpty || cleaned == DefaultPipeline.stages) ? nil : cleaned
            try? context.save()
        }
    }
}

private struct FactionOverridesEditor: View {
    @Environment(\.modelContext) private var context
    @Bindable var cfg: AppConfiguration
    let armies: [Army]

    struct Row: Identifiable { let id: String; let game: String; let faction: String }

    @State private var crest: [String: String] = [:]
    @State private var color: [String: Color] = [:]
    @State private var imageFileNames: [String: String?] = [:]

    private var rows: [Row] {
        var seen = Set<String>()
        var out: [Row] = []
        for a in armies {
            let key = FactionResolver.compositeKey(game: a.game, faction: a.faction)
            if seen.insert(key).inserted { out.append(Row(id: key, game: a.game, faction: a.faction)) }
        }
        return out.sorted { $0.id < $1.id }
    }

    var body: some View {
        Form {
            if rows.isEmpty {
                Section {
                    ContentUnavailableView {
                        Label(String(localized: "No armies yet"), systemImage: "shield")
                    } description: {
                        Text(String(localized: "Add an army in Collection to customize its crest."))
                    }
                    .adaptiveEmptyStateLayout()
                }
            } else {
                Section {
                    ForEach(rows) { row in
                        NavigationLink {
                            FactionCrestDetailView(
                                row: row,
                                crest: crestBinding(for: row.id),
                                color: colorBinding(for: row.id),
                                imageFileName: imageBinding(for: row.id)
                            )
                        } label: {
                            FactionCrestSummaryRow(
                                row: row,
                                crest: crest[row.id] ?? "",
                                colorHex: (color[row.id] ?? .gray).hexString,
                                imageFileName: imageFileNames[row.id] ?? nil
                            )
                        }
                    }
                } header: {
                    Text(String(localized: "Factions"))
                } footer: {
                    Text(FormHints.factionCrest)
                }
            }
        }
        .navigationTitle(String(localized: "Factions"))
        .onAppear(perform: seed)
        .onDisappear(perform: save)
    }

    private func crestBinding(for rowId: String) -> Binding<String> {
        Binding(
            get: { crest[rowId] ?? "" },
            set: { crest[rowId] = String($0.prefix(8)) }
        )
    }

    private func colorBinding(for rowId: String) -> Binding<Color> {
        Binding(
            get: { color[rowId] ?? .gray },
            set: { color[rowId] = $0 }
        )
    }

    private func imageBinding(for rowId: String) -> Binding<String?> {
        Binding(
            get: { imageFileNames[rowId] ?? nil },
            set: { imageFileNames[rowId] = $0 }
        )
    }

    private func seed() {
        for row in rows {
            let override = cfg.factionOverrides.first { $0.key == row.id }
            let resolved = FactionResolver.resolve(
                faction: row.faction, game: row.game, overrides: cfg.factionOverrides
            )
            crest[row.id] = override?.crest ?? resolved.crest
            color[row.id] = Color(hex: override?.hex ?? resolved.colorHex)
            imageFileNames[row.id] = override?.imageFileName
        }
    }

    private func save() {
        let previousFiles = Set(cfg.factionOverrides.compactMap(\.imageFileName))
        cfg.factionOverrides = rows.map { row in
            FactionPresetOverride(
                key: row.id,
                crest: String((crest[row.id] ?? "").prefix(8)),
                hex: (color[row.id] ?? .gray).hexString,
                imageFileName: imageFileNames[row.id] ?? nil
            )
        }
        let keptFiles = Set(cfg.factionOverrides.compactMap(\.imageFileName))
        for orphaned in previousFiles.subtracting(keptFiles) {
            CrestImageStore.delete(fileName: orphaned)
        }
        try? context.save()
    }
}

private struct FactionCrestSummaryRow: View {
    let row: FactionOverridesEditor.Row
    let crest: String
    let colorHex: String
    let imageFileName: String?

    var body: some View {
        HStack(spacing: 10) {
            CrestBadge(text: crest, colorHex: colorHex, imageFileName: imageFileName)
            VStack(alignment: .leading, spacing: 2) {
                Text(row.faction)
                    .font(.subheadline.weight(.medium))
                Text(SupportedGames.displayName(for: row.game))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
    }
}

private struct FactionCrestDetailView: View {
    let row: FactionOverridesEditor.Row
    @Binding var crest: String
    @Binding var color: Color
    @Binding var imageFileName: String?

    @State private var pickerItem: PhotosPickerItem?
    @State private var importError: String?

    var body: some View {
        Form {
            Section {
                HStack(spacing: 12) {
                    CrestBadge(
                        text: crest,
                        colorHex: color.hexString,
                        imageFileName: imageFileName
                    )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(row.faction)
                            .font(.headline)
                        Text(SupportedGames.displayName(for: row.game))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 4)
            }

            Section {
                TextField(String(localized: "Abbreviation"), text: $crest)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                ColorPicker(String(localized: "Badge colour"), selection: $color, supportsOpacity: false)
            } header: {
                Text(String(localized: "Text crest"))
            }

            Section {
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label(
                        imageFileName == nil
                            ? String(localized: "Choose image…")
                            : String(localized: "Replace image…"),
                        systemImage: "photo"
                    )
                }
                if imageFileName != nil {
                    Button(String(localized: "Remove image"), role: .destructive) {
                        CrestImageStore.delete(fileName: imageFileName)
                        imageFileName = nil
                    }
                }
                if let importError {
                    Text(importError)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            } header: {
                Text(String(localized: "Custom image"))
            } footer: {
                Text(String(localized: "Square logos work best. Stored on this device only."))
            }
        }
        .navigationTitle(row.faction)
        .navigationBarTitleDisplayMode(.inline)
        .tabBarScrollInset()
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { await importImage(from: item) }
        }
    }

    private func importImage(from item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                importError = String(localized: "Could not read the selected image.")
                return
            }
            let fileName = try CrestImageStore.write(from: data, replacing: imageFileName)
            imageFileName = fileName
            importError = nil
        } catch {
            importError = error.localizedDescription
        }
        pickerItem = nil
    }
}
