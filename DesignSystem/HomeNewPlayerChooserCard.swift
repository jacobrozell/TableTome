import SwiftUI
import TabletomeDomain

/// Helps complete beginners pick the right game mode from the Play tab.
struct HomeNewPlayerChooserCard: View {
    @Environment(AppRouter.self) private var router
    @State private var showsBoxHelper = false
    @State private var showsWh40kPicker = false

    private var showsAnyWh40kChooser: Bool {
        ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k11e.rawValue)
            || ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k10eCp.rawValue)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "What did you buy?"), systemImage: "shippingbox.fill")
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)

            Text(
                String(
                    localized: """
                    Pick what matches your box. You can change this anytime from Play.
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

            if showsAnyWh40kChooser {
                wh40kChooserRow
            }

            if ReleaseSurface.isGameSystemIdVisible(GameSystemId.aosSpearhead.rawValue) {
                chooserRow(
                    title: String(localized: "I bought an Age of Sigmar starter box"),
                    detail: String(localized: "Box says Spearhead? Start here."),
                    gameSystemId: GameSystemId.aosSpearhead.rawValue,
                    identifier: "home.chooser.spearhead"
                )
            }

            if ReleaseSurface.isGameSystemIdVisible(GameSystemId.scTmg.rawValue) {
                chooserRow(
                    title: String(localized: "I'm trying StarCraft: The Miniatures Game"),
                    detail: String(localized: "Terran vs Zerg — no prior wargame needed"),
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
        .sheet(isPresented: $showsWh40kPicker) {
            Wh40kBoxPickerSheet()
        }
    }

    private var wh40kChooserRow: some View {
        Button {
            showsWh40kPicker = true
        } label: {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                BoxProductThumbnail(
                    style: BoxProductThumbnailStyle(
                        gameSystemId: GameSystemId.wh40k11e.rawValue,
                        chooserIdentifier: "home.chooser.wh40k"
                    )
                )

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "I bought a Warhammer 40,000 box"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(
                        String(
                            localized: """
                            Combat Patrol (10e rules), Battleforce, Armageddon, or full 11e army — tap to pick your box type.
                            """
                        )
                    )
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
        .accessibilityIdentifier("home.chooser.wh40k")
    }

    private func chooserRow(
        title: String,
        detail: String,
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
        .accessibilityIdentifier(identifier)
    }

    private var newPlayerChooserFooter: String {
        if FirstSessionStore.shouldHideHobbyTabs() {
            if ReleaseSurface.showsMusterTab {
                return String(
                    localized: """
                    Collection and army lists unlock after your first game — focus on Play for now.
                    """
                )
            }
            return String(
                localized: """
                Miniature collection tracking unlocks after your first game — focus on Play for now.
                """
            )
        }
        if ReleaseSurface.showsMusterTab {
            return String(
                localized: """
                Models & Lists tabs are for tracking painted armies later — skip them until after your first game.
                """
            )
        }
        return String(
            localized: """
            The Models tab is for tracking painted armies later — skip it until after your first game.
            """
        )
    }

    private func openGameGuide(gameSystemId: String) {
        ActiveGameContextStore.setActiveGameSystem(gameSystemId)
        FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        router.openGameGuide(gameSystemId: gameSystemId)
    }
}
