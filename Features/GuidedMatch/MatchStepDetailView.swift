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
                Text(step.body)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                GlossaryChipsRow(text: step.body, gameSystemId: viewModel.gameSystemId.rawValue, ruleSections: ruleSections)

                SetupStepRulesLink(
                    gameSystemId: viewModel.gameSystemId.rawValue,
                    stepTitle: step.title,
                    relatedRuleSectionId: step.relatedRuleSectionId
                )

                stepSpecificContent

                if let relatedSection {
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

                stepCompletionStatus
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .tabBarScrollInset()
        .navigationTitle(step.title)
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
                compactInlineBattlefieldContent
                inlineStepCompletionHint
            } else {
                stepSpecificContent
                stepCompletionStatus
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityIdentifier("guidedMatch.stepInline.\(step.id)")
    }

    private var stepCompletionStatus: some View {
        MatchStepCompletionStatus(
            step: step,
            isComplete: isComplete,
            completionHint: completionHint,
            usesManualConfirmation: usesManualConfirmation,
            onMarkComplete: { viewModel.setStepComplete(step.id, complete: true) }
        )
    }

    var completionHint: String {
        if isComplete {
            return String(localized: "Step complete")
        }
        if step.id == "pick-enhancement" {
            return String(
                localized: "Tap Use recommended defaults, or pick one Enhancement and one Secondary for each player."
            )
        }
        if usesManualConfirmation {
            if step.id == "regiment-abilities" {
                return String(
                    localized: "Pick one regiment ability per player (or keep our suggestions), then tap Mark step complete."
                )
            }
            if step.id == "enhancements" {
                return String(
                    localized: "Pick one enhancement for each general (or keep our suggestions), then tap Mark step complete."
                )
            }
            return String(localized: "Tap below when you've finished this step.")
        }
        return String(localized: "Complete the actions above — this step checks off automatically.")
    }

    private var usesManualConfirmation: Bool {
        if viewModel.gameSystemId == .scTmg,
           ["battle-format", "mission-setup", "confirm-lists"].contains(step.id) {
            return true
        }
        if viewModel.gameSystemId == .aosSpearhead,
           ["regiment-abilities", "enhancements"].contains(step.id) {
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
