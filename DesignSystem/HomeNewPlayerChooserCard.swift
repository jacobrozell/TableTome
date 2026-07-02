import SwiftUI
import TabletomeDomain

/// Helps complete beginners pick the right game mode from the Play tab.
struct HomeNewPlayerChooserCard: View {
    @Environment(AppRouter.self) private var router
    @State private var showsBoxHelper = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "What did you buy?"), systemImage: "shippingbox.fill")
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)

            Text(
                String(
                    localized: """
                    Box says Spearhead on the cover? Tap below to open the Spearhead guide and Guided Match.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            Label(
                String(localized: "You roll physical dice — Tabletome tracks phases, score, and rules."),
                systemImage: "dice.fill"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            Button {
                showsBoxHelper = true
            } label: {
                Label(String(localized: "Not sure what you have?"), systemImage: "questionmark.circle")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("home.chooser.boxHelper")

            wh40kChooserRows

            if ReleaseSurface.isPlayHomeGameSystemVisible(GameSystemId.aosSpearhead.rawValue) {
                chooserRow(
                    title: String(localized: "I bought an Age of Sigmar starter box"),
                    detail: String(localized: "Box says Spearhead? Start here."),
                    accessibilityLabel: String(localized: "Age of Sigmar starter box"),
                    accessibilityHint: String(localized: "Box says Spearhead? Start here."),
                    gameSystemId: GameSystemId.aosSpearhead.rawValue,
                    identifier: "home.chooser.spearhead"
                )
            }

            if ReleaseSurface.showsAllPlayModesOnHome,
               ReleaseSurface.isGameSystemIdVisible(GameSystemId.scTmg.rawValue) {
                chooserRow(
                    title: String(localized: "I'm trying StarCraft: The Miniatures Game"),
                    detail: String(localized: "Terran vs Zerg — no prior wargame needed"),
                    accessibilityLabel: String(localized: "StarCraft: The Miniatures Game"),
                    accessibilityHint: String(localized: "Terran vs Zerg — no prior wargame needed"),
                    gameSystemId: GameSystemId.scTmg.rawValue,
                    identifier: "home.chooser.scTmg"
                )
            }

            Text(newPlayerChooserFooter)
            .font(.caption)
            .foregroundStyle(.tertiary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .accentHighlightCard()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("home.newPlayerChooser")
        .sheet(isPresented: $showsBoxHelper) {
            BoxIdentificationSheet()
        }
    }

    @ViewBuilder
    private var wh40kChooserRows: some View {
        if ReleaseSurface.showsAllPlayModesOnHome {
            if ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k10eCp.rawValue) {
                wh40kChooserRow(
                    title: String(localized: "Combat Patrol starter box"),
                    detail: String(localized: "10th Edition — box says Combat Patrol on the cover"),
                    gameSystemId: GameSystemId.wh40k10eCp.rawValue,
                    variant: .combatPatrol,
                    identifier: "home.chooser.wh40k.combatPatrol"
                )
            }

            if ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k11e.rawValue) {
                wh40kChooserRow(
                    title: String(localized: "Battleforce"),
                    detail: String(localized: "11th Edition single-faction army box"),
                    gameSystemId: GameSystemId.wh40k11e.rawValue,
                    variant: .battleforce,
                    identifier: "home.chooser.wh40k.battleforce"
                )

                wh40kChooserRow(
                    title: String(localized: "Warhammer 40,000: Armageddon"),
                    detail: String(localized: "Launch box — Space Marines vs Orks"),
                    gameSystemId: GameSystemId.wh40k11e.rawValue,
                    variant: .armageddon,
                    identifier: "home.chooser.wh40k.armageddon"
                )

                wh40kChooserRow(
                    title: String(localized: "Full Warhammer 40,000"),
                    detail: String(localized: "1,000+ points, any faction — 11th Edition"),
                    gameSystemId: GameSystemId.wh40k11e.rawValue,
                    variant: .full,
                    identifier: "home.chooser.wh40k.full"
                )
            }
        }
    }

    private func wh40kChooserRow(
        title: String,
        detail: String,
        gameSystemId: String,
        variant: Wh40kChooserVariant,
        identifier: String
    ) -> some View {
        Button {
            FirstSessionStore.recordOnboardingChoice(
                gameSystemId: gameSystemId,
                wh40kVariant: variant.rawValue
            )
            router.openGameGuide(gameSystemId: gameSystemId)
        } label: {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                BoxProductThumbnail(
                    style: BoxProductThumbnailStyle(
                        gameSystemId: gameSystemId,
                        chooserIdentifier: identifier
                    )
                )

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(detail)
        .accessibilityIdentifier(identifier)
    }

    private func chooserRow(
        title: String,
        detail: String,
        accessibilityLabel: String,
        accessibilityHint: String,
        gameSystemId: String,
        identifier: String
    ) -> some View {
        Button {
            openGameGuide(gameSystemId: gameSystemId)
        } label: {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                BoxProductThumbnail(
                    style: BoxProductThumbnailStyle(
                        gameSystemId: gameSystemId,
                        chooserIdentifier: identifier
                    )
                )

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityIdentifier(identifier)
    }

    private var newPlayerChooserFooter: String {
        if ReleaseSurface.showsMusterTab {
            return String(
                localized: """
                Models and Lists are optional — track painted armies whenever you're ready.
                """
            )
        }
        return String(
            localized: """
            The Models tab is optional — track painted armies whenever you're ready.
            """
        )
    }

    private func openGameGuide(gameSystemId: String) {
        FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        router.openGameGuide(gameSystemId: gameSystemId)
    }
}
