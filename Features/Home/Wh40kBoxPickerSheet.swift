import SwiftUI
import TabletomeDomain

/// Sub-picker for the collapsed “I bought a Warhammer 40,000 box” chooser row.
struct Wh40kBoxPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppRouter.self) private var router

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k10eCp.rawValue) {
                        pickerRow(
                            title: String(localized: "Combat Patrol starter box"),
                            detail: String(
                                localized: "10th Edition patrol rules — box says Combat Patrol on the cover"
                            ),
                            gameSystemId: GameSystemId.wh40k10eCp.rawValue,
                            variant: .combatPatrol,
                            identifier: "wh40kPicker.combatPatrol",
                            badge: .custom(String(localized: "If box says Combat Patrol"))
                        )
                    }

                    if ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k11e.rawValue) {
                        pickerRow(
                            title: String(localized: "Battleforce"),
                            detail: String(
                                localized: "11th Edition — Astra Militarum, Tyranids, Chaos, or Necrons army box"
                            ),
                            gameSystemId: GameSystemId.wh40k11e.rawValue,
                            variant: .battleforce,
                            identifier: "wh40kPicker.battleforce"
                        )

                        pickerRow(
                            title: String(localized: "Warhammer 40,000: Armageddon"),
                            detail: String(localized: "Launch box — Space Marines vs Orks with mission cards"),
                            gameSystemId: GameSystemId.wh40k11e.rawValue,
                            variant: .armageddon,
                            identifier: "wh40kPicker.armageddon",
                            badge: .custom(String(localized: "Launch box"))
                        )

                        pickerRow(
                            title: String(localized: "Full Warhammer 40,000"),
                            detail: String(localized: "1,000+ points, any faction — 11th Edition"),
                            gameSystemId: GameSystemId.wh40k11e.rawValue,
                            variant: .full,
                            identifier: "wh40kPicker.full"
                        )
                    }
                } header: {
                    Text(String(localized: "Which 40k box?"))
                } footer: {
                    Text(
                        String(
                            localized: """
                            Combat Patrol uses 10th Edition rules. Battleforce, Armageddon, and full army use 11th Edition.
                            """
                        )
                    )
                }
            }
            .navigationTitle(String(localized: "Warhammer 40,000"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Close")) { dismiss() }
                }
            }
        }
    }

    private func pickerRow(
        title: String,
        detail: String,
        gameSystemId: String,
        variant: Wh40kChooserVariant,
        identifier: String,
        badge: GuideBadgeStyle? = nil
    ) -> some View {
        Button {
            openGuide(gameSystemId: gameSystemId, variant: variant)
        } label: {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                BoxProductThumbnail(
                    style: BoxProductThumbnailStyle(
                        gameSystemId: gameSystemId,
                        chooserIdentifier: identifier
                    )
                )

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if let badge {
                            GuideBadge(style: badge)
                        }
                    }
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
            .contentShape(Rectangle())
        }
        .accessibilityIdentifier(identifier)
    }

    private func openGuide(gameSystemId: String, variant: Wh40kChooserVariant) {
        FirstSessionStore.recordOnboardingChoice(
            gameSystemId: gameSystemId,
            wh40kVariant: variant.rawValue
        )
        router.openGameGuide(gameSystemId: gameSystemId)
        dismiss()
    }
}
