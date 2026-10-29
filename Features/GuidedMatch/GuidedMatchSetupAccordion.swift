import SwiftUI
import TabletomeDomain

struct SetupAccordion: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    let onStartBattle: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(BannerCenter.self) private var banners
    @State private var editingStepId: String?

    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        ForEach(Array(viewModel.sortedMatchSteps.enumerated()), id: \.element.id) { index, step in
                            stepRow(step, number: index + 1)
                                .id(step.id)
                        }
                    }
                    .readableContentWidth()
                    .padding(DesignTokens.Spacing.md)
                }
                progressBar
            }
            .onChange(of: viewModel.setupProgress.completed) { previous, completed in
                guard completed > previous else { return }
                if viewModel.setupIsComplete {
                    editingStepId = nil
                    banners.show(
                        BannerItem(
                            id: "guidedMatch.setupComplete",
                            message: String(localized: "Setup complete. Ready to battle."),
                            systemImage: "checkmark.circle.fill",
                            tone: .success
                        )
                    )
                } else if let next = viewModel.nextIncompleteStep {
                    editingStepId = nil
                    withAnimation(TTMotion.standard(reduceMotion: reduceMotion)) {
                        proxy.scrollTo(next.id, anchor: .top)
                    }
                }
            }
        }
        .ttHaptic(.phaseAdvanced, trigger: viewModel.setupProgress.completed)
        .ttScreenBackground()
    }

    private var progressBar: some View {
        let progress = viewModel.setupProgress
        return HStack(spacing: DesignTokens.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                TTProgressBar(fraction: viewModel.setupProgressFraction, tone: .brand, criticalThreshold: nil)
                Text(String(localized: "\(progress.completed) of \(progress.total) steps"))
                    .font(TTFont.footnote)
                    .foregroundStyle(TTColor.inkSecondary)
            }
            Button(String(localized: "Start Battle"), action: onStartBattle)
                .buttonStyle(.ttPrimaryInline)
                .disabled(!viewModel.setupIsComplete)
                .accessibilityIdentifier("guidedMatch.startBattle")
        }
        .padding(DesignTokens.Spacing.md)
        .barChromeBackground()
    }

    @ViewBuilder
    private func stepRow(_ step: MatchSetupStep, number: Int) -> some View {
        let done = viewModel.matchState.completedStepIds.contains(step.id)
        let expanded = expandedStepId == step.id
        if expanded {
            currentCard(step, number: number)
        } else if done {
            doneRow(step, number: number)
        } else {
            upcomingRow(step, number: number)
        }
    }

    private var expandedStepId: String? {
        if let editingStepId { return editingStepId }
        return viewModel.nextIncompleteStep?.id
    }

    private func doneRow(_ step: MatchSetupStep, number: Int) -> some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(TTColor.success)
                .accessibilityHidden(true)
            Text(step.title)
                .font(TTFont.headline)
                .foregroundStyle(TTColor.inkSecondary)
            Spacer(minLength: 0)
            Button(String(localized: "Edit")) {
                withAnimation(TTMotion.standard(reduceMotion: reduceMotion)) {
                    editingStepId = step.id
                }
            }
            .buttonStyle(.ttTertiary)
        }
        .frame(minHeight: 52)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("guidedMatch.setupStep.\(step.id)")
        .accessibilityLabel(String(localized: "Step \(number), \(step.title), complete"))
    }

    private func currentCard(_ step: MatchSetupStep, number: Int) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                Text("\(number)")
                    .font(TTFont.numericSmall)
                    .foregroundStyle(TTColor.inkOnBrand)
                    .frame(width: 28, height: 28)
                    .background(TTColor.brandFill, in: Circle())
                Text(step.title)
                    .font(TTFont.titleSmall)
                    .foregroundStyle(TTColor.inkPrimary)
            }
            Text(step.summary)
                .font(TTFont.callout)
                .foregroundStyle(TTColor.inkSecondary)
                .lineLimit(2)
            MatchStepDetailView(
                step: step,
                stepNumber: number,
                viewModel: viewModel,
                ruleSections: ruleSections,
                presentation: .inlineHub
            )
            NavigationLink(value: GuidedMatchDestination.step(step.id)) {
                Text(String(localized: "Read full step"))
            }
            .buttonStyle(.ttTertiary)
            .accessibilityIdentifier("guidedMatch.stepGuide.\(step.id)")
        }
        .surfaceCard()
        .accessibilityIdentifier("guidedMatch.setupStep.\(step.id)")
    }

    private func upcomingRow(_ step: MatchSetupStep, number: Int) -> some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Text("\(number)")
                .font(TTFont.numericSmall)
                .foregroundStyle(TTColor.inkTertiary)
                .frame(width: 28, height: 28)
                .overlay {
                    Circle().strokeBorder(TTColor.stroke, lineWidth: 2)
                }
            Text(step.title)
                .font(TTFont.headline)
                .foregroundStyle(TTColor.inkTertiary)
            Spacer(minLength: 0)
        }
        .frame(minHeight: 52)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("guidedMatch.setupStep.\(step.id)")
        .accessibilityLabel(String(localized: "Step \(number), \(step.title), not started"))
    }
}
