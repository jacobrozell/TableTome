import SwiftUI
import TabletomeDomain

/// Recommended paths for new and returning 40k players on the game guide screen.
struct FortyKStartHereCard: View {
    let gameSystem: GameSystem

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                Label(String(localized: "Start here"), systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
                if ReleaseSurface.showsNewEditionBadge(for: gameSystem.id) {
                    NewEditionBadge()
                }
            }

            Text(
                String(
                    localized: """
                    New to the hobby or upgrading from 10th Edition? Pick a path — about 10 minutes of reading, \
                    then play at the table.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                trackSection(
                    title: String(localized: "New to Warhammer 40,000"),
                    steps: [
                        (String(localized: "Getting Started"), String(localized: "What you need, army size, and how a turn works.")),
                        (String(localized: "Rules Reference"), String(localized: "Search turn phases, combat, and glossary terms.")),
                        (String(localized: "Guided Match"), String(localized: "Interactive setup and battle tracker — coming soon for 40k."))
                    ]
                )

                trackSection(
                    title: String(localized: "Played 10th Edition?"),
                    steps: [
                        (String(localized: "What's New in 11e"), String(localized: "Detachments, terrain objectives, combat, and battle-shock.")),
                        (String(localized: "Rules Reference"), String(localized: "Jump to changed topics from the guide.")),
                        (String(localized: "Guided Match"), String(localized: "Armageddon starter matchup — coming soon."))
                    ]
                )
            }

            NavigationLink {
                GettingStartedView(gameSystem: gameSystem)
            } label: {
                Label(String(localized: "Getting Started"), systemImage: "map")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("guide.wh40k.gettingStarted")

            if !gameSystem.editionMigrationSteps.isEmpty {
                NavigationLink {
                    EditionMigrationView(gameSystem: gameSystem)
                } label: {
                    Label(String(localized: "What's New in 11th Edition"), systemImage: "arrow.triangle.2.circlepath")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("guide.wh40k.whatsNew")
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
    }

    private func trackSection(title: String, steps: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 20, alignment: .trailing)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.0)
                            .font(.subheadline.weight(.medium))
                        Text(step.1)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}
