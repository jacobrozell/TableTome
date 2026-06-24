import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

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
        NavigationStack {
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
                        let pres = FactionResolver.resolve(
                            faction: row.faction, game: row.game, overrides: cfg.factionOverrides
                        )
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                Image(systemName: HobbyGameSymbol.systemImage(for: row.game))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.accentOnSurface)
                                    .symbolRenderingMode(.hierarchical)
                                    .accessibilityHidden(true)
                                Text(row.faction)
                                    .font(.subheadline.weight(.medium))
                                Spacer(minLength: 0)
                                CrestBadge(
                                    text: crest[row.id] ?? pres.crest,
                                    colorHex: (color[row.id] ?? Color(hex: pres.color)).hexString
                                )
                            }
                            HStack {
                                TextField(String(localized: "Crest"), text: Binding(
                                    get: { crest[row.id] ?? "" },
                                    set: { crest[row.id] = String($0.prefix(8)) }))
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                                ColorPicker("", selection: Binding(
                                    get: { color[row.id] ?? .gray },
                                    set: { color[row.id] = $0 }))
                                .labelsHidden()
                                .accessibilityLabel(String(localized: "Faction color"))
                            }
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

    private func seed() {
        for row in rows {
            let r = FactionResolver.resolve(faction: row.faction, game: row.game, overrides: cfg.factionOverrides)
            crest[row.id] = r.crest
            color[row.id] = Color(hex: r.color)
        }
    }

    private func save() {
        cfg.factionOverrides = rows.map { row in
            FactionPresetOverride(key: row.id,
                                  crest: String((crest[row.id] ?? "").prefix(8)),
                                  hex: (color[row.id] ?? .gray).hexString)
        }
        try? context.save()
    }
}
