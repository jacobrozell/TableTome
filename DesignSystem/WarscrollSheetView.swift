import SwiftUI
import TabletomeDomain
import UIKit

struct WarscrollInfoButton: View {
    let armyId: String
    let unit: SpearheadUnit
    var gameSystemId: GameSystemId = .default
    var accessibilityId: String

    @State private var showsSheet = false

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    var body: some View {
        Button {
            showsSheet = true
        } label: {
            Image(systemName: "info.circle")
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(playContext.unitRulesInfoAccessibilityLabel(unitName: unit.name))
        .accessibilityHint(String(localized: "Opens the unit rules reference."))
        .accessibilityIdentifier(accessibilityId)
        .sheet(isPresented: $showsSheet) {
            WarscrollSheetView(armyId: armyId, unit: unit)
        }
    }
}

struct WarscrollReferenceView: View {
    let armyId: String
    let unit: SpearheadUnit

    private var sheetImageURL: URL? {
        WarscrollSheetCatalog.sheetImageURL(armyId: armyId, unitId: unit.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                if let sheetImageURL,
                   let uiImage = UIImage(contentsOfFile: sheetImageURL.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel(unit.name)
                }
                WarscrollTextReference(unit: unit)
            }
            .padding(DesignTokens.Spacing.md)
        }
    }
}

struct WarscrollSheetView: View {
    let armyId: String
    let unit: SpearheadUnit

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            WarscrollReferenceView(armyId: armyId, unit: unit)
            .navigationTitle(unit.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                }
            }
            .accessibilityIdentifier("warscroll.sheet.\(unit.id)")
        }
    }
}

private struct WarscrollTextReference: View {
    let unit: SpearheadUnit

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            if !unit.keywords.isEmpty {
                Text(unit.keywords.joined(separator: " · "))
                    .ttEyebrow()
            }
            Text(unit.name)
                .font(TTFont.title)
                .foregroundStyle(TTColor.inkPrimary)
            if let notes = unit.notes, !notes.isEmpty {
                Text(notes)
                    .font(TTFont.footnote)
                    .foregroundStyle(TTColor.inkTertiary)
            }
            let stats = unitReferenceStats(unit)
            if !stats.isEmpty {
                TTStatStrip(stats: stats)
            }
            if !unit.weapons.isEmpty {
                TTSectionHeader(String(localized: "Weapons"))
                TTWeaponTable(weapons: unit.weapons)
            }
            if !unit.abilities.isEmpty {
                TTSectionHeader(String(localized: "Abilities"))
                ForEach(unit.abilities) { ability in
                    UnitAbilityCard(
                        ability: ability,
                        phase: ability.phases.first ?? .hero,
                        isUsed: false,
                        onMarkUsed: nil
                    )
                }
            }
            if !unit.keywords.isEmpty {
                TTSectionHeader(String(localized: "Keywords"))
                TTFlowLayout {
                    ForEach(unit.keywords, id: \.self) { keyword in
                        TTBadge(keyword, tone: .neutral, style: .soft)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

func unitReferenceStats(_ unit: SpearheadUnit) -> [TTStat] {
    var stats: [TTStat] = []
    if let move = unit.move {
        stats.append(TTStat(label: String(localized: "Move"), value: move))
    }
    if let save = unit.save {
        stats.append(TTStat(label: String(localized: "Save"), value: "\(save)+"))
    }
    if let health = unit.health {
        stats.append(TTStat(label: String(localized: "Health"), value: "\(health)"))
    }
    if let control = unit.control {
        stats.append(TTStat(label: String(localized: "Control"), value: "\(control)"))
    }
    return stats
}

