import SwiftUI
import TabletomeDomain
import UIKit

struct WarscrollInfoButton: View {
    let armyId: String
    let unit: SpearheadUnit
    var accessibilityId: String

    @State private var showsSheet = false

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
        .accessibilityLabel(String(localized: "View \(unit.name) warscroll"))
        .accessibilityHint(String(localized: "Opens the unit datasheet."))
        .accessibilityIdentifier(accessibilityId)
        .sheet(isPresented: $showsSheet) {
            WarscrollSheetView(armyId: armyId, unit: unit)
        }
    }
}

struct WarscrollSheetView: View {
    let armyId: String
    let unit: SpearheadUnit

    @Environment(\.dismiss) private var dismiss

    private var sheetImageURL: URL? {
        WarscrollSheetCatalog.sheetImageURL(armyId: armyId, unitId: unit.id)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    if let sheetImageURL,
                       let uiImage = UIImage(contentsOfFile: sheetImageURL.path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .accessibilityLabel(unit.name)
                    } else {
                        WarscrollTextReference(unit: unit)
                    }
                }
                .padding(DesignTokens.Spacing.md)
            }
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
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if let subtext = WarscrollStatSummary.unitChoiceSubtext(unit) {
                Text(subtext)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let profile = unitDefensiveProfile.nilIfEmpty {
                labeledSection(String(localized: "Unit"), text: profile)
            }

            if !unit.weapons.isEmpty {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text(String(localized: "Weapons"))
                        .font(.subheadline.bold())
                    ForEach(unit.weapons) { weapon in
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text(weapon.name)
                                .font(.subheadline.weight(.semibold))
                            Text(WarscrollStatSummary.weaponCombatProfile(weapon))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let ability = weapon.ability, !ability.isEmpty {
                                Text(ability)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(DesignTokens.Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
                    }
                }
            }

            if !unit.keywords.isEmpty {
                labeledSection(String(localized: "Keywords"), text: unit.keywords.joined(separator: " · "))
            }

            Text(sheetImageMissingHint)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var unitDefensiveProfile: String {
        WarscrollStatSummary.unitDefensiveProfile(unit)
    }

    private var sheetImageMissingHint: String {
        String(localized: "Official warscroll image isn't bundled for this unit. Showing stats from the app.")
    }

    private func labeledSection(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(title)
                .font(.subheadline.bold())
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
