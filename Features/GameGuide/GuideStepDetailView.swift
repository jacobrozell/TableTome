import SwiftUI
import TabletomeDomain

struct GuideStepDetailView: View {
    let gameSystemId: String
    let steps: [GuideStep]
    let ruleSections: [RuleSection]

    @State private var index: Int

    init(gameSystemId: String, steps: [GuideStep], index: Int, ruleSections: [RuleSection]) {
        self.gameSystemId = gameSystemId
        self.steps = steps
        self.ruleSections = ruleSections
        _index = State(initialValue: index)
    }

    private var step: GuideStep { steps[index] }

    private var showsSpearheadExtras: Bool {
        GameSystemPlayContext.context(for: gameSystemId).capabilities.showsBattleTacticDecks
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(String(localized: "Step \(index + 1) of \(steps.count)"))
                    .ttEyebrow()
                Text(step.title)
                    .font(TTFont.title)
                    .foregroundStyle(TTColor.inkPrimary)
                    .accessibilityAddTraits(.isHeader)

                paragraphs(step.body)

                GlossaryChipsRow(text: step.body, gameSystemId: gameSystemId, ruleSections: ruleSections)

                if step.id == "pick-army", showsSpearheadExtras {
                    WhatYouNeedCard()
                }

                if showsSpearheadExtras, step.id == "realm-battlefield" || step.id == "fight-battle" {
                    NavigationLink(value: BattleTacticsReferenceLink(gameSystemId: gameSystemId)) {
                        TTRow(
                            title: String(localized: "Card Decks Guide"),
                            systemImage: "rectangle.stack"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint(String(localized: "Which physical deck is twists vs battle tactics"))
                    .accessibilityIdentifier("guide.cardDecks.\(step.id)")
                }

                if let relatedSection {
                    TTSectionHeader(String(localized: "Related"))
                    TTCard(padding: 0) {
                        NavigationLink(value: RuleSectionLink(gameSystemId: gameSystemId, sectionId: relatedSection.id)) {
                            TTRow(title: relatedSection.title, systemImage: "doc.text")
                        }
                        .buttonStyle(.plain)
                    }
                    .accessibilityLabel(String(localized: "Related rule: \(relatedSection.title)"))
                    .accessibilityIdentifier("guide.relatedRule.\(step.id)")
                }

                ForEach(step.tips, id: \.self) { tip in
                    TTNotice(
                        title: String(localized: "Tip"),
                        message: tip,
                        systemImage: "lightbulb",
                        tone: .warning
                    )
                }
                if !step.tips.isEmpty {
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
        .ttScreenBackground()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                if index > 0 {
                    Button(String(localized: "Previous")) { index -= 1 }
                        .buttonStyle(.ttSecondary)
                        .accessibilityIdentifier("guide.stepDetail.previous")
                }
                if index < steps.count - 1 {
                    Button(String(localized: "Next Step")) { index += 1 }
                        .buttonStyle(.ttPrimary)
                        .accessibilityIdentifier("guide.stepDetail.next")
                } else if ReleaseSurface.showsGuidedMatch(for: gameSystemId) {
                    NavigationLink(value: GuidedMatchLink(gameSystemId: GameSystemId(resolving: gameSystemId))) {
                        Text(String(localized: "Start a Battle"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.ttPrimary)
                    .accessibilityIdentifier("guide.stepDetail.next")
                }
            }
            .padding(DesignTokens.Spacing.md)
            .background(TTColor.canvas)
        }
        .onAppear {
            GuideProgressStore.markRead(stepId: step.id, gameSystemId: gameSystemId)
        }
        .onChange(of: index) { _, _ in
            GuideProgressStore.markRead(stepId: step.id, gameSystemId: gameSystemId)
        }
    }

    private func paragraphs(_ body: String) -> some View {
        let blocks = body.components(separatedBy: "\n\n")
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                if block.hasPrefix("1. ") || block.hasPrefix("- ") || block.hasPrefix("• ") {
                    Text(block)
                        .font(TTFont.body)
                        .foregroundStyle(TTColor.inkPrimary)
                        .lineSpacing(3)
                        .padding(.leading, DesignTokens.Spacing.md)
                } else {
                    Text(block)
                        .font(TTFont.body)
                        .foregroundStyle(TTColor.inkPrimary)
                        .lineSpacing(3)
                }
            }
        }
    }

    private var relatedSection: RuleSection? {
        guard let sectionId = step.relatedRuleSectionId else { return nil }
        return ruleSections.first { $0.id == sectionId }
    }
}
