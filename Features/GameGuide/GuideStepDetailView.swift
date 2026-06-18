import SwiftUI
import TabletomeDomain

struct GuideStepDetailView: View {
    let gameSystemId: String
    let step: GuideStep
    let ruleSections: [RuleSection]
    @State private var isComplete = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(step.body)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                GlossaryChipsRow(text: step.body)

                if step.id == "pick-army", gameSystemId == "aos-spearhead" {
                    WhatYouNeedCard()
                }

                if step.id == "realm-battlefield" || step.id == "fight-battle", gameSystemId == "aos-spearhead" {
                    NavigationLink {
                        BattleTacticsReferenceView(ruleSections: ruleSections)
                    } label: {
                        Label(String(localized: "Card Decks Guide"), systemImage: "rectangle.stack")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(minHeight: DesignTokens.minTouchTarget)
                    }
                    .accessibilityHint(String(localized: "Which physical deck is twists vs battle tactics"))
                    .accessibilityIdentifier("guide.cardDecks.\(step.id)")
                }

                if let relatedSection {
                    NavigationLink {
                        RuleSectionDetailView(section: relatedSection, allSections: ruleSections)
                    } label: {
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
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text(String(localized: "Tips"))
                            .font(.headline)
                        ForEach(step.tips, id: \.self) { tip in
                            Label(tip, systemImage: "lightbulb")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        GlossaryChipsRow(text: step.tips.joined(separator: " "))
                    }
                    .padding(DesignTokens.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
                }

                Toggle(isOn: $isComplete) {
                    Text(String(localized: "Mark step complete"))
                        .font(.headline)
                }
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("guide.stepComplete.\(step.id)")
                .onChange(of: isComplete) { _, newValue in
                    GuideProgressStore.setComplete(newValue, gameSystemId: gameSystemId, stepId: step.id)
                }
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .navigationTitle(step.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isComplete = GuideProgressStore.isComplete(gameSystemId: gameSystemId, stepId: step.id)
        }
        .animation(reduceMotion ? nil : .default, value: isComplete)
    }

    private var relatedSection: RuleSection? {
        guard let sectionId = step.relatedRuleSectionId else { return nil }
        return ruleSections.first { $0.id == sectionId }
    }
}
