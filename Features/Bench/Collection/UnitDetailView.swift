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
            UnitPhotoSection(unit: unit, pipeline: pipeline)

            unitSummarySection(unit)

            Section {
                TextField(String(localized: "Name"), text: $unit.name)
                    .textInputAutocapitalization(.words)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Quantity"))
                        .font(TTFont.subheadline)
                        .foregroundStyle(TTColor.inkSecondary)
                    TTCounter(
                        value: Binding(
                            get: { unit.qty },
                            set: { ArmyStore.setQty(unit, $0, in: context) }
                        ),
                        range: 1...9999,
                        label: String(localized: "Quantity"),
                        size: .regular
                    )
                }
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
            .listRowBackground(TTColor.surface)

            Section {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text(String(localized: "Current state"))
                        .font(TTFont.subheadline)
                        .foregroundStyle(TTColor.inkSecondary)
                    stageStepper(unit)
                }
                if canAdvance {
                    Button {
                        ArmyStore.advance(unit, pipeline: pipeline, in: context)
                        advanceTrigger.toggle()
                    } label: {
                        Label(String(localized: "Advance one stage"), systemImage: "arrow.right.circle.fill")
                    }
                    .buttonStyle(.ttSecondary)
                }
                FormNotesField(title: String(localized: "Notes"), text: $unit.notes)
            } header: {
                Text(String(localized: "Painting"))
            } footer: {
                Text(FormHints.notesTags)
            }
            .listRowBackground(TTColor.surface)

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
                            .font(TTFont.caption)
                            .foregroundStyle(TTColor.inkSecondary)
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
                .listRowBackground(TTColor.surface)
            }

            Section {
                Button(String(localized: "Delete unit"), role: .destructive) { confirmDelete = true }
                    .buttonStyle(.ttDestructive)
            }
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .background(TTColor.canvas.ignoresSafeArea())
        .listRowSeparatorTint(TTColor.stroke)
        .tabBarScrollInset()
    }

    private func stageStepper(_ unit: ArmyUnit) -> some View {
        let currentIndex = pipeline.firstIndex { $0.key == unit.state } ?? -1
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(Array(pipeline.enumerated()), id: \.element.id) { index, stage in
                    let isCurrent = stage.key == unit.state
                    let isPast = currentIndex >= 0 && index < currentIndex
                    Button {
                        ArmyStore.setState(unit, stage.key, in: context)
                    } label: {
                        Text(stage.key)
                            .font(TTFont.caption.weight(.semibold))
                            .foregroundStyle(stageChipForeground(isCurrent: isCurrent, isPast: isPast, hex: stage.hex))
                            .padding(.horizontal, DesignTokens.Spacing.sm)
                            .frame(minHeight: DesignTokens.minTouchTarget)
                            .background(
                                stageChipBackground(isCurrent: isCurrent, isPast: isPast, hex: stage.hex),
                                in: Capsule()
                            )
                            .overlay {
                                if isCurrent {
                                    Capsule().strokeBorder(TTColor.brand, lineWidth: 2)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(stage.key)
                    .accessibilityHint(String(localized: "Sets the painting stage"))
                    .accessibilityAddTraits(isCurrent ? .isSelected : [])
                }
            }
        }
    }

    private func stageChipForeground(isCurrent: Bool, isPast: Bool, hex: String) -> Color {
        if isCurrent { return TTColor.brand }
        if isPast { return Color(hex: hex).legibleForeground }
        return TTColor.inkSecondary
    }

    private func stageChipBackground(isCurrent: Bool, isPast: Bool, hex: String) -> Color {
        if isPast { return Color(hex: hex) }
        if isCurrent { return TTColor.brandSoft }
        return TTColor.sunken
    }

    @ViewBuilder
    private func unitSummarySection(_ unit: ArmyUnit) -> some View {
        if let army {
            let pres = army.presentation(overrides: overrides)
            Section {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                        CrestTile(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                            Text(army.name)
                                .font(TTFont.headline)
                                .foregroundStyle(TTColor.inkPrimary)
                            Text("\(SupportedGames.displayName(for: army.game)) · \(army.faction)")
                                .font(TTFont.subheadline)
                                .foregroundStyle(TTColor.inkSecondary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                        StageCapsule(state: unit.state, pipeline: pipeline)
                    }
                    if unit.modelCount > 1 || unit.hasSquadMembers {
                        ProgressMeter(
                            segments: Pipeline.segments(of: [unit], pipeline),
                            height: 6
                        )
                    }
                }
                .padding(.vertical, DesignTokens.Spacing.xs)
            }
            .listRowBackground(TTColor.surface)
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
