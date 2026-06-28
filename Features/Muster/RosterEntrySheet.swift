import SwiftUI
import SwiftData
import TabletomeDomain
import TabletomeHobbyData

struct RosterEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var configs: [AppConfiguration]

    let entry: RosterEntry

    private var overrides: [FactionPresetOverride] { configs.first?.factionOverrides ?? [] }
    private var catalog: CatalogUnit? { UnitCatalogLoader.unit(id: entry.catalogUnitId) }

    private var pointsInfo: RosterCatalogSync.EntryPointsInfo {
        RosterCatalogSync.entryPointsInfo(for: entrySnapshot)
    }

    private var entrySnapshot: RosterCatalogSync.EntrySnapshot {
        RosterCatalogSync.EntrySnapshot(
            catalogUnitId: entry.catalogUnitId,
            pointsEach: entry.pointsEach,
            usesCustomPoints: entry.usesCustomPoints
        )
    }

    private var canResetToCatalog: Bool {
        entry.usesCustomPoints && RosterCatalogSync.catalogPoints(for: entry.catalogUnitId) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                if let roster = entry.roster {
                    Section {
                        rosterContextHeader(roster)
                    }
                }

                Section {
                    unitContextHeader
                }

                Section {
                    QuantityStepper(label: String(localized: "Quantity"), value: Binding(
                        get: { entry.qty },
                        set: { RosterStore.setQty(entry, $0, in: context) }
                    ), range: 1...HobbyLimits.maxRosterQty)
                } header: {
                    Text(String(localized: "Entry"))
                }

                Section {
                    QuantityStepper(
                        label: String(localized: "Points each"),
                        value: Binding(
                            get: { entry.pointsEach },
                            set: { RosterStore.setPointsEach(entry, $0, in: context) }
                        ),
                        range: 0...9_999
                    )

                    HStack {
                        Text(String(localized: "Line total"))
                        Spacer(minLength: 8)
                        PointsSourceViews.pointsCapsule(
                            String(localized: "\(entry.pointsTotal) pts"),
                            style: entry.usesCustomPoints ? .custom : .accent
                        )
                    }

                    if canResetToCatalog, let catalogPts = catalog?.basePoints {
                        Button {
                            _ = RosterStore.resetPointsToCatalog(entry, in: context)
                        } label: {
                            Label(
                                String(localized: "Reset to \(catalogPts) pts (catalog)"),
                                systemImage: "arrow.counterclockwise"
                            )
                        }
                    }
                } header: {
                    Text(String(localized: "Points"))
                } footer: {
                    PointsSourceViews.entrySourceCallout(pointsInfo)
                }

                Section {
                    Button(String(localized: "Remove from list"), role: .destructive) {
                        RosterStore.deleteEntry(entry, in: context)
                        dismiss()
                    }
                }
            }
            .tabBarScrollInset()
            .readableContentWidth()
            .navigationTitle(String(localized: "Edit unit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private func rosterContextHeader(_ roster: Roster) -> some View {
        let pres = roster.presentation(overrides: overrides)
        let sizeLabel = BattleSizes.resolve(game: roster.game, key: roster.battleSizeKey)?.label
            ?? roster.battleSizeKey
        HStack(spacing: 12) {
            CrestBadge(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
            VStack(alignment: .leading, spacing: 3) {
                Text(roster.name)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 5) {
                    Image(systemName: HobbyGameSymbol.systemImage(for: roster.game))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.accentOnSurface)
                        .symbolRenderingMode(.hierarchical)
                        .accessibilityHidden(true)
                    Text("\(roster.faction) · \(sizeLabel)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var unitContextHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: catalog.map { CatalogCategorySymbol.systemImage(for: $0.category) } ?? "figure.stand")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.accentOnSurface)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 32, height: 32)
                .background(Color.accentColor.opacity(0.12), in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(entry.displayName)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                    if entry.usesCustomPoints {
                        PointsSourceViews.customPointsBadge()
                    }
                }
                if let catalog {
                    Text(unitMetadata(catalog))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                PointsSourceViews.pointsCapsule(
                    String(localized: "\(entry.pointsTotal) pts total"),
                    style: entry.usesCustomPoints ? .custom : .accent
                )
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private func unitMetadata(_ catalog: CatalogUnit) -> String {
        let noun = catalog.modelCount == 1
            ? String(localized: "model")
            : String(localized: "models")
        return String(localized: "\(catalog.category) · \(catalog.modelCount) \(noun)")
    }
}
