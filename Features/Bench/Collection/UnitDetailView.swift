import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

/// Edit all fields for a single unit.
@MainActor
struct UnitDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(BannerCenter.self) private var banner
    @Query private var allArmies: [Army]
    @Query private var configs: [AppConfiguration]

    let unitId: UUID

    @State private var showMove = false
    @State private var confirmDelete = false
    @State private var advanceTrigger = false
    @State private var deleteWarningTrigger = false
    @State private var duplicateTrigger = false

    private var unit: ArmyUnit? {
        allArmies.flatMap(\.units).first { $0.id == unitId }
    }

    private var army: Army? { unit?.army }

    private var globalPipeline: [PipelineStage]? {
        (try? context.fetch(FetchDescriptor<AppConfiguration>()))?.first?.globalPipeline
    }

    private var pipeline: [PipelineStage] {
        guard let army else { return Pipeline.resolve(globalPipeline) }
        return Pipeline.forArmy(army, global: globalPipeline)
    }

    private var usesSpearhead: Bool {
        guard let army else { return false }
        return army.units.contains { $0.spearhead != nil }
    }

    private var overrides: [FactionPresetOverride] {
        (configs.first ?? HobbyConfig.current(context)).factionOverrides
    }

    private var otherArmies: [Army] {
        guard let army else { return [] }
        return allArmies.filter { $0.id != army.id }
    }

    private var otherArmyNames: [String] {
        otherArmies.map(\.name)
    }

    private var canAdvance: Bool {
        guard let unit else { return false }
        return Pipeline.canAdvance(unit, pipeline)
    }

    private var trackable: Bool { (unit?.modelCount ?? 0) >= 2 }

    var body: some View {
        Group {
            if let unit {
                unitForm(unit)
            } else {
                ContentUnavailableView {
                    Label(String(localized: "Unit not found"), systemImage: "figure.stand")
                } description: {
                    Text(String(localized: "This unit may have been deleted."))
                }
            }
        }
        .navigationTitle(unit?.name.isEmpty == false ? unit!.name : String(localized: "Unit"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { unitToolbar }
        .confirmationDialog(
            String(localized: "Remove \"\(unit?.name ?? "")\"?"),
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Remove"), role: .destructive) {
                if let unit {
                    ArmyStore.delete(unit, in: context)
                    deleteWarningTrigger.toggle()
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showMove) {
            if let unit {
                MoveUnitSheet(
                    unitName: unit.name,
                    destinationArmies: otherArmies,
                    overrides: overrides
                ) { target in
                    _ = ArmyStore.move(unit, to: target, in: context)
                    dismiss()
                }
                .presentationDetents([.medium])
            }
        }
        .sensoryFeedback(.success, trigger: advanceTrigger)
        .sensoryFeedback(.warning, trigger: deleteWarningTrigger)
        .sensoryFeedback(.impact(weight: .light), trigger: duplicateTrigger)
    }

    @ViewBuilder
    private func unitForm(_ unit: ArmyUnit) -> some View {
        @Bindable var unit = unit
        Form {
            unitSummarySection(unit)

            Section {
                TextField(String(localized: "Name"), text: $unit.name)
                    .textInputAutocapitalization(.words)
                QuantityStepper(label: String(localized: "Quantity"), value: Binding(
                    get: { unit.qty },
                    set: { ArmyStore.setQty(unit, $0, in: context) }
                ))
                if !unit.name.trimmingCharacters(in: .whitespaces).isEmpty {
                    ModelCountSummary(name: unit.name, qty: unit.qty)
                }
                TextField(String(localized: "Source"), text: $unit.source)
                    .textInputAutocapitalization(.words)
                if usesSpearhead {
                    Toggle(String(localized: "Spearhead"), isOn: Binding(
                        get: { unit.spearhead == true },
                        set: { ArmyStore.setSpearhead(unit, $0, in: context) }
                    ))
                }
            } header: {
                Text(String(localized: "Unit"))
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(FormHints.modelCount)
                    Text(FormHints.source)
                }
            }

            Section {
                LabeledContent {
                    StateChip(state: unit.state, pipeline: pipeline)
                } label: {
                    Text(String(localized: "Current state"))
                }
                Picker(String(localized: "State"), selection: Binding(
                    get: { unit.state },
                    set: { ArmyStore.setState(unit, $0, in: context) }
                )) {
                    ForEach(pipeline) { stage in
                        Text(stage.key).tag(stage.key)
                    }
                }
                .formNavigationPickerStyle()
                .accessibilityLabel(String(localized: "Painting state"))
                .accessibilityValue(unit.state)
                if canAdvance {
                    Button(String(localized: "Advance one stage"), systemImage: "arrow.right.circle.fill") {
                        ArmyStore.advance(unit, pipeline: pipeline, in: context)
                        advanceTrigger.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                }
                FormNotesField(title: String(localized: "Notes"), text: $unit.notes)
            } header: {
                Text(String(localized: "Painting"))
            } footer: {
                Text(FormHints.notesTags)
            }

            UnitPhotoSection(unit: unit, pipeline: pipeline)

            UnitTimelineSection(unit: unit, pipeline: pipeline)

            if trackable {
                Section {
                    Toggle(String(localized: "Track per model"), isOn: Binding(
                        get: { unit.hasSquadMembers },
                        set: { enabled in
                            if enabled { SquadStore.enable(unit, in: context) }
                            else { SquadStore.disable(unit, in: context) }
                        }
                    ))
                    if unit.hasSquadMembers {
                        Text(Members.stateSummary(of: unit))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ForEach(unit.sortedSquadMembers) { member in
                            SquadMemberRow(unit: unit, member: member, pipeline: pipeline)
                        }
                    }
                } header: {
                    Text(String(localized: "Squad"))
                } footer: {
                    Text(
                        unit.hasSquadMembers
                            ? FormHints.trackPerModel
                            : FormHints.trackPerModelOff
                    )
                }
            }

            Section {
                Button(String(localized: "Delete unit"), role: .destructive) { confirmDelete = true }
            }
        }
        .tabBarScrollInset()
        .readableContentWidth()
    }

    @ViewBuilder
    private func unitSummarySection(_ unit: ArmyUnit) -> some View {
        if let army {
            let pres = army.presentation(overrides: overrides)
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .center, spacing: 12) {
                        CrestBadge(text: pres.crest, colorHex: pres.colorHex)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(army.name)
                                .font(.subheadline.weight(.semibold))
                            HStack(spacing: 5) {
                                Image(systemName: HobbyGameSymbol.systemImage(for: army.game))
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(Color.accentOnSurface)
                                    .symbolRenderingMode(.hierarchical)
                                    .accessibilityHidden(true)
                                Text("\(army.game) · \(army.faction)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        Spacer(minLength: 0)
                        StateChip(state: unit.state, pipeline: pipeline)
                    }
                    if unit.modelCount > 1 || unit.hasSquadMembers {
                        ProgressMeter(
                            segments: Pipeline.segments(of: [unit], pipeline),
                            height: 6
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    @ToolbarContentBuilder private var unitToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if let unit, canAdvance {
                Button(String(localized: "Advance"), systemImage: "arrow.right.circle") {
                    ArmyStore.advance(unit, pipeline: pipeline, in: context)
                    advanceTrigger.toggle()
                }
                .accessibilityLabel(String(localized: "Advance painting state"))
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button(String(localized: "Duplicate"), systemImage: "plus.square.on.square") {
                    if let unit {
                        if ArmyStore.duplicate(unit, in: context) != nil {
                            banner.show(String(localized: "Duplicated \(unit.name)"))
                            duplicateTrigger.toggle()
                        }
                    }
                }
                Button(String(localized: "Move to…"), systemImage: "arrow.right.arrow.left") { showMove = true }
                    .disabled(otherArmyNames.isEmpty)
                Button(String(localized: "Delete"), systemImage: "trash", role: .destructive) { confirmDelete = true }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .accessibilityLabel(String(localized: "Unit actions"))
        }
    }
}
