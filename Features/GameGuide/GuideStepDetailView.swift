import SwiftUI
import TabletomeDomain

struct GuideStepDetailView: View {
    let gameSystemId: String
    let step: GuideStep
    let ruleSections: [RuleSection]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(step.body)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                GlossaryChipsRow(text: step.body, gameSystemId: gameSystemId, ruleSections: ruleSections)

                if step.id == "pick-army", gameSystemId == "aos-spearhead" {
                    WhatYouNeedCard()
                }

                if step.id == "realm-battlefield" || step.id == "fight-battle", gameSystemId == "aos-spearhead" {
                    NavigationLink(value: BattleTacticsReferenceLink(gameSystemId: gameSystemId)) {
                        Label(String(localized: "Card Decks Guide"), systemImage: "rectangle.stack")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(minHeight: DesignTokens.minTouchTarget)
                    }
                    .accessibilityHint(String(localized: "Which physical deck is twists vs battle tactics"))
                    .accessibilityIdentifier("guide.cardDecks.\(step.id)")
                }

                if let relatedSection {
                    NavigationLink(value: RuleSectionLink(gameSystemId: gameSystemId, sectionId: relatedSection.id)) {
                        Label(relatedSection.title, systemImage: "doc.text")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(minHeight: DesignTokens.minTouchTarget)
                    }
                    .accessibilityLabel(String(localized: "Related rule: \(relatedSection.title)"))
                    .accessibilityHint(String(localized: "Opens this rule section"))
                    .accessibilityIdentifier("guide.relatedRule.\(step.id)")
                }

                if !step.tips.isEmpty {
                    TipsCard(tips: step.tips)
                    GlossaryChipsRow(
                        text: step.tips.joined(separator: " "),
                        gameSystemId: gameSystemId,
                        ruleSections: ruleSections
                    )
                }
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .navigationTitle(step.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var relatedSection: RuleSection? {
        guard let sectionId = step.relatedRuleSectionId else { return nil }
        return ruleSections.first { $0.id == sectionId }
    }
}
