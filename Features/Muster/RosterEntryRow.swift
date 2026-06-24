import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

struct RosterEntryRow: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(AppRouter.self) private var router
    @Query private var armies: [Army]

    let entry: RosterEntry
    let roster: Roster
    var match: CollectionMatchResult?
    var onTap: (() -> Void)?

    private var catalog: CatalogUnit? { UnitCatalogLoader.unit(id: entry.catalogUnitId) }
    private var usesStackedLayout: Bool {
        AdaptiveLayout.usesStackedRowLayout(
            dynamicType: dynamicTypeSize,
            verticalSizeClass: verticalSizeClass
        )
    }

    var body: some View {
        Group {
            if usesStackedLayout { stackedRow } else { compactRow }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
        .accessibilityElement(children: .contain)
        .accessibilityHint(String(localized: "Opens unit options"))
    }

    private var compactRow: some View {
        HStack(alignment: .center, spacing: 10) {
            nameBlock
            Spacer(minLength: 4)
            ownershipControl
            pointsDisplay
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
            qtyStepper
        }
    }

    private var stackedRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            nameBlock
            HStack(alignment: .center, spacing: 10) {
                ownershipControl
                pointsDisplay
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
                Spacer(minLength: 0)
                qtyStepper
            }
        }
    }

    private var pointsDisplay: some View {
        VStack(alignment: .trailing, spacing: 2) {
            PointsSourceViews.pointsCapsule(
                "\(entry.pointsTotal)",
                style: entry.usesCustomPoints ? .custom : .subtle
            )
            if entry.usesCustomPoints, entry.qty > 1 {
                Text(String(localized: "\(entry.pointsEach) ea"))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.orange)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(pointsAccessibilityLabel)
    }

    private var pointsAccessibilityLabel: String {
        if entry.usesCustomPoints {
            return String(localized: "\(entry.pointsTotal) points, \(entry.pointsEach) each, custom value")
        }
        return String(localized: "\(entry.pointsTotal) points")
    }

    private var nameBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(entry.displayName)
                    .font(.body.weight(.medium))
                    .lineLimit(usesStackedLayout ? 4 : 2)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                if entry.usesCustomPoints {
                    PointsSourceViews.customPointsBadge(compact: true)
                }
            }
            if let catalog {
                Text(modelCountLabel(catalog.modelCount, category: catalog.category))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(nameAccessibilityLabel)
    }

    @ViewBuilder
    private var ownershipControl: some View {
        if let match {
            if match.status == .owned || match.status == .partial {
                Button { openCollection(for: match) } label: {
                    OwnershipBadge(status: match.status)
                }
                .buttonStyle(.plain)
                .accessibilityHint(ownershipHint(for: match.status))
            } else {
                OwnershipBadge(status: match.status)
                    .accessibilityHint(ownershipHint(for: match.status))
            }
        }
    }

    @ViewBuilder
    private var qtyStepper: some View {
        if usesStackedLayout {
            Stepper(String(localized: "Qty \(entry.qty)"), value: Binding(
                get: { entry.qty },
                set: { RosterStore.setQty(entry, $0, in: context) }
            ), in: 1...HobbyLimits.maxRosterQty)
            .accessibilityLabel(String(localized: "Quantity"))
            .accessibilityValue("\(entry.qty)")
        } else {
            Stepper(value: Binding(
                get: { entry.qty },
                set: { RosterStore.setQty(entry, $0, in: context) }
            ), in: 1...HobbyLimits.maxRosterQty) {
                EmptyView()
            }
            .labelsHidden()
            .accessibilityLabel(String(localized: "Quantity"))
            .accessibilityValue("\(entry.qty)")
        }
    }

    private var nameAccessibilityLabel: String {
        var parts = [entry.displayName, String(localized: "\(entry.pointsTotal) points")]
        if entry.usesCustomPoints {
            parts.append(String(localized: "Custom points"))
        }
        if let catalog {
            parts.append(modelCountLabel(catalog.modelCount, category: catalog.category))
        }
        if let match {
            parts.append(ownershipHint(for: match.status))
        }
        return parts.joined(separator: ", ")
    }

    private func modelCountLabel(_ count: Int, category: String) -> String {
        let noun = count == 1
            ? String(localized: "model")
            : String(localized: "models")
        return String(localized: "\(count) \(noun) · \(category)")
    }

    private func ownershipHint(for status: CollectionMatchResult.Status) -> String {
        switch status {
        case .owned, .partial:
            String(localized: "Owned in collection, opens in Collection tab")
        case .missing:
            String(localized: "Missing from collection")
        case .unknown:
            String(localized: "Collection match unknown")
        }
    }

    private func openCollection(for match: CollectionMatchResult) {
        guard match.status == .owned || match.status == .partial,
              let unitId = match.matchedUnitIds.first,
              let armyId = armies.flatMap(\.units).first(where: { $0.id == unitId })?.army?.id
        else { return }
        router.openCollection(armyId: armyId, unitId: unitId)
    }
}
