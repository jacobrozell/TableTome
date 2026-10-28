import SwiftUI
import TabletomeDomain

enum MatchStepPresentation {
    case detail
    case inlineHub
}

struct MatchStepDetailView: View {
    let step: MatchSetupStep
    let stepNumber: Int
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    var presentation: MatchStepPresentation = .detail

    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var usesSideBySideColumns: Bool {
        TabletomeLayout.usesSideBySideLayout(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass,
            isAccessibilitySize: dynamicTypeSize.needsLayoutAdaptation
        )
    }

    private var stepParagraphs: [String] {
        step.body
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var isComplete: Bool {
        viewModel.matchState.completedStepIds.contains(step.id)
    }

    var body: some View {
        Group {
            switch presentation {
            case .detail:
                detailBody
            case .inlineHub:
                inlineHubBody
            }
        }
        .onAppear {
            viewModel.syncAutoCompletions()
        }
    }

    private var detailBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(String(localized: "SETUP · STEP \(stepNumber) OF \(viewModel.sortedMatchSteps.count)"))
                    .ttEyebrow()
                Text(step.title)
                    .font(TTFont.title)
                    .foregroundStyle(TTColor.inkPrimary)
                if isComplete {
                    TTBadge(
                        String(localized: "Step complete"),
                        tone: .success,
                        systemImage: "checkmark"
                    )
                    .accessibilityIdentifier("guidedMatch.stepComplete.\(step.id)")
                }
                ForEach(stepParagraphs, id: \.self) { paragraph in
                    Text(paragraph)
                        .font(TTFont.body)
                        .foregroundStyle(TTColor.inkPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                GlossaryChipsRow(text: step.body, gameSystemId: viewModel.gameSystemId.rawValue, ruleSections: ruleSections)

                SetupStepRulesLink(
                    gameSystemId: viewModel.gameSystemId.rawValue,
                    stepTitle: step.title,
                    relatedRuleSectionId: step.relatedRuleSectionId
                )

                stepSpecificContent

                if usesManualConfirmation, !isComplete {
                    Button(String(localized: "Mark step complete")) {
                        viewModel.setStepComplete(step.id, complete: true)
                    }
                    .buttonStyle(.ttSecondary)
                    .accessibilityIdentifier("guidedMatch.markComplete.\(step.id)")
                }

                if let relatedSection, ReleaseSurface.showsRulesAssistant {
                    ReferenceLinksGroup {
                        NavigationLink(value: RuleSectionLink(
                            gameSystemId: viewModel.gameSystemId.rawValue,
                            sectionId: relatedSection.id
                        )) {
                            ReferenceLinkRow(title: relatedSection.title, systemImage: "doc.text")
                        }
                        .accessibilityLabel(String(localized: "Related rule: \(relatedSection.title)"))
                        .accessibilityIdentifier("guidedMatch.relatedRule.\(step.id)")
                    }
                }

                if !step.tips.isEmpty {
                    TipsCard(tips: step.tips)
                }
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .tabBarScrollInset()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(id: "guidedMatch.stepDone.\(step.id)", placement: .confirmationAction) {
                Button(String(localized: "Done")) {
                    dismiss()
                }
                .fontWeight(.semibold)
                .accessibilityIdentifier("guidedMatch.stepDone.\(step.id)")
            }
            .hidingToolbarGlassBackgroundIfAvailable()
        }
    }

    private var inlineHubBody: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if step.usesCompactInlineHubContent {
                MatchStepInlineBattlefieldContent(
                    step: step,
                    viewModel: viewModel,
                    ruleSections: ruleSections,
                    usesSideBySideColumns: usesSideBySideColumns
                )
            } else {
                stepSpecificContent
                if usesManualConfirmation, !isComplete {
                    Button(String(localized: "Mark step complete")) {
                        viewModel.setStepComplete(step.id, complete: true)
                    }
                    .buttonStyle(.ttSecondary)
                    .accessibilityIdentifier("guidedMatch.markComplete.\(step.id)")
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityIdentifier("guidedMatch.stepInline.\(step.id)")
    }

    private var usesManualConfirmation: Bool {
        if viewModel.gameSystemId == .scTmg,
           ["battle-format", "mission-setup", "confirm-lists"].contains(step.id) {
            return true
        }
        if viewModel.gameSystemId == .aosSpearhead,
           step.id == SpearheadSetupStepId.preBattleLoadout {
            return true
        }
        return false
    }

    @ViewBuilder
    var stepSpecificContent: some View {
        if viewModel.gameSystemId == .aosSpearhead {
            SpearheadStepContent(
                step: step,
                viewModel: viewModel,
                ruleSections: ruleSections,
                usesSideBySideColumns: usesSideBySideColumns
            )
        } else {
            MatchStepLegacyContent(
                step: step,
                viewModel: viewModel,
                ruleSections: ruleSections,
                usesSideBySideColumns: usesSideBySideColumns
            )
        }
    }

    private var relatedSection: RuleSection? {
        guard let sectionId = step.relatedRuleSectionId else { return nil }
        return ruleSections.first { $0.id == sectionId }
    }
}
