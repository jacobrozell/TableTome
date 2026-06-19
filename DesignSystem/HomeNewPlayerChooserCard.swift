import SwiftUI
import TabletomeDomain

/// Helps complete beginners pick the right game mode from the Play tab.
struct HomeNewPlayerChooserCard: View {
    @State private var showsBoxHelper = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "New to wargaming?"), systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            Text(
                String(
                    localized: """
                    Pick the option that matches what you own or want to try. You can change this anytime from Play.
                    """
                )
            )
            .font(.callout)
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

            chooserRow(
                title: String(localized: "I bought a Warhammer 40,000 starter box"),
                detail: String(localized: "Small box-set battles — best if your box says Combat Patrol"),
                systemImage: "shippingbox.fill",
                gameSystemId: GameSystemId.wh40k10eCp.rawValue,
                identifier: "home.chooser.combatPatrol",
                showsRecommendedBadge: true,
                recommendedBadgeLabel: String(localized: "If box says Combat Patrol")
            )

            chooserRow(
                title: String(localized: "I bought an Age of Sigmar starter box"),
                detail: String(localized: "Fast intro battles — look for Spearhead on the box"),
                systemImage: "shield.lefthalf.filled",
                gameSystemId: GameSystemId.aosSpearhead.rawValue,
                identifier: "home.chooser.spearhead",
                showsRecommendedBadge: true
            )

            chooserRow(
                title: String(localized: "I play full Warhammer 40,000"),
                detail: String(localized: "Larger armies and the current 11th Edition rules"),
                systemImage: "scope",
                gameSystemId: GameSystemId.wh40k11e.rawValue,
                identifier: "home.chooser.wh40k11e"
            )

            chooserRow(
                title: String(localized: "I'm trying StarCraft: The Miniatures Game"),
                detail: String(localized: "Terran vs Zerg starter — no prior wargame needed"),
                systemImage: "gamecontroller.fill",
                gameSystemId: GameSystemId.scTmg.rawValue,
                identifier: "home.chooser.scTmg"
            )

            Text(
                String(
                    localized: """
                    Models & Lists tabs are for tracking painted armies later — skip them until after your first game.
                    """
                )
            )
            .font(.caption)
            .foregroundStyle(.tertiary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("home.newPlayerChooser")
        .sheet(isPresented: $showsBoxHelper) {
            BoxIdentificationSheet()
        }
    }

    private func chooserRow(
        title: String,
        detail: String,
        systemImage: String,
        gameSystemId: String,
        identifier: String,
        showsRecommendedBadge: Bool = false,
        recommendedBadgeLabel: String = String(localized: "Good first game")
    ) -> some View {
        NavigationLink(value: gameSystemId) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        if showsRecommendedBadge {
                            Text(recommendedBadgeLabel)
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.14), in: Capsule())
                                .foregroundStyle(Color.accentColor)
                        }
                    }
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
        .simultaneousGesture(TapGesture().onEnded {
            ActiveGameContextStore.setActiveGameSystem(gameSystemId)
            FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        })
        .accessibilityIdentifier(identifier)
    }
}
