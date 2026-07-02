import SwiftUI
import TabletomeDomain

struct BoxIdentificationRecommendationRow: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

struct BoxIdentificationResultStep: View {
    let recommendedGameSystemId: String
    let sciFiStarterFormat: BoxIdentificationSheet.SciFiStarterFormat?
    let sciFiBoxKind: BoxIdentificationSheet.SciFiBoxKind?
    let onOpenGuide: () -> Void

    var body: some View {
        Section {
            BoxIdentificationRecommendationRow(
                title: recommendationCopy.title,
                detail: recommendationCopy.detail
            )
            Button {
                onOpenGuide()
            } label: {
                Label(String(localized: "Open this guide"), systemImage: "play.circle.fill")
            }
            .accessibilityIdentifier("boxIdentification.openGuide")
        } header: {
            Text(String(localized: "We suggest"))
        } footer: {
            Text(String(localized: "You can change this anytime from the chooser on Play."))
        }
    }

    private var recommendationCopy: (title: String, detail: String) {
        BoxIdentificationRecommendationCopy.text(
            for: recommendedGameSystemId,
            sciFiStarterFormat: sciFiStarterFormat,
            sciFiBoxKind: sciFiBoxKind
        )
    }
}

enum BoxIdentificationRecommendationCopy {
    static func text(
        for gameSystemId: String,
        sciFiStarterFormat: BoxIdentificationSheet.SciFiStarterFormat?,
        sciFiBoxKind: BoxIdentificationSheet.SciFiBoxKind?
    ) -> (title: String, detail: String) {
        switch gameSystemId {
        case GameSystemId.aosSpearhead.rawValue:
            return (
                String(localized: "Age of Sigmar: Spearhead"),
                String(localized: "Fast fantasy battles — look for Spearhead on the box.")
            )
        case GameSystemId.wh40k10eCp.rawValue:
            return (
                String(localized: "Warhammer 40,000: Combat Patrol"),
                String(localized: "10th Edition patrol rules — look for Combat Patrol on the box.")
            )
        case GameSystemId.wh40k11e.rawValue:
            if sciFiStarterFormat == .armageddon {
                return (
                    String(localized: "Warhammer 40,000: Armageddon"),
                    String(localized: "11th Edition launch box — tap Use Starter Matchup for both armies.")
                )
            }
            if sciFiStarterFormat == .battleforce {
                return (
                    String(localized: "Warhammer 40,000 — Battleforce"),
                    String(
                        localized: """
                        Pick your Battleforce army in Guided Match — Astra Militarum, Tyranids, Chaos Space Marines, or Necrons.
                        """
                    )
                )
            }
            return (
                String(localized: "Warhammer 40,000"),
                String(localized: "11th Edition matched play — Armageddon, Battleforces, or your own lists.")
            )
        case GameSystemId.scTmg.rawValue:
            return (
                String(localized: "StarCraft: The Miniatures Game"),
                String(localized: "Terran vs Zerg on the tabletop — no prior wargame needed.")
            )
        default:
            return (gameSystemId, String(localized: "Open the guide to get started."))
        }
    }
}
