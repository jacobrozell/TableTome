import SwiftUI
import TabletomeDomain

/// In-flow escape hatch to Rules Search or the Rules tab from Guided Match setup.
struct SetupStepRulesLink: View {
    let gameSystemId: String
    let stepTitle: String
    var relatedRuleSectionId: String?

    @Environment(AppRouter.self) private var router

    var body: some View {
        if ReleaseSurface.showsRulesAssistant {
            Button {
                router.openRulesSearch(
                    gameSystemId: gameSystemId,
                    query: stepTitle
                )
            } label: {
                TTRow(
                    title: String(localized: "Look this up in Rules Search"),
                    systemImage: "magnifyingglass"
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("guidedMatch.setupRulesSearch.\(stepTitle)")
        } else if let relatedRuleSectionId {
            NavigationLink(value: RuleSectionLink(gameSystemId: gameSystemId, sectionId: relatedRuleSectionId)) {
                TTRow(title: String(localized: "Look up in Rules"), systemImage: "doc.text")
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("guidedMatch.setupRulesSection.\(relatedRuleSectionId)")
            .accessibilityHint(
                String(
                    localized: "Opens \(stepTitle) in the rules reference for this game."
                )
            )
        } else {
            NavigationLink(value: RulesReferenceBrowseLink(gameSystemId: gameSystemId)) {
                TTRow(title: String(localized: "Look up in Rules"), systemImage: "doc.text")
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("guidedMatch.setupRulesBrowse.\(stepTitle)")
            .accessibilityHint(
                String(
                    localized: "Opens the rules reference for this game. Search for \(stepTitle) or related terms."
                )
            )
        }
    }
}
