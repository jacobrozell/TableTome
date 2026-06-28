import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    private var usesAccessibilityLayout: Bool {
        dynamicTypeSize.needsLayoutAdaptation
    }

    func trackedScrollView(proxy: ScrollViewProxy) -> some View {
        applyScrollTargets(to: applyPhaseChanges(to: trackerScrollContent, proxy: proxy), proxy: proxy)
            .modifier(TrackerNoticeDismissalsModifier(view: self))
    }

    private var trackerScrollContent: some View {
        ScrollView(.vertical) {
            Group {
                switch layoutContext {
                case .padLandscape, .padPortrait:
                    if usesAccessibilityLayout {
                        compactLayout
                    } else {
                        padTabbedTwoColumnLayout
                    }
                case .phonePortrait, .phoneLandscape:
                    compactLayout
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(BattleTrackerContentWidth(layoutContext: layoutContext))
            .padding(trackerContentPadding)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .vertical)
        .tabBarScrollInset(enabled: !(isEmbeddedInGuidedMatch && layoutContext.prefersCollapsedBattleChrome))
        .modifier(BattleTrackerPhaseDockScrollInset(isEnabled: usesCompactBattleTrackerChrome && isEmbeddedInGuidedMatch))
    }

    private struct BattleTrackerPhaseDockScrollInset: ViewModifier {
        let isEnabled: Bool

        func body(content: Content) -> some View {
            if isEnabled {
                content.battleTrackerPhaseDockScrollInset()
            } else {
                content
            }
        }
    }

    private func applyPhaseChanges<Content: View>(
        to content: Content,
        proxy: ScrollViewProxy
    ) -> some View {
        content
            .onChange(of: viewModel.trackerState.currentPhase) { oldPhase, phase in
                selectedSectionTab = BattleTrackerSectionTab.suggested(
                    phase: phase,
                    deploymentComplete: deploymentIsComplete,
                    roundOpenerIncomplete: viewModel.roundOpenerIsIncomplete,
                    gameSystemId: viewModel.gameSystemId
                )
                if phase.isCombatRelated, ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId) {
                    requestCombatResolverFocus(using: proxy)
                }
                if phase == .endOfTurn, handoffBaselineEstablished {
                    presentScoringReminderIfNeeded()
                } else if oldPhase == .endOfTurn {
                    scoringReminderNotice = nil
                }
                if phase == .hero {
                    presentRoundOpenerNudgeIfNeeded()
                    presentHeroRoundOneNudgeIfNeeded()
                } else {
                    showsHeroRoundOneNotice = false
                }
                if handoffBaselineEstablished {
                    presentPhaseActionNudgeIfNeeded(from: oldPhase, to: phase)
                    presentTurnHandoff(from: oldPhase, to: phase, playerChanged: false)
                }
            }
            .onChange(of: viewModel.trackerState.battleRound) { oldRound, round in
                if oldRound == 1, round == 2 {
                    FirstSessionStore.recordFirstBattleRound()
                }
                if viewModel.roundOpenerIsIncomplete {
                    selectedSectionTab = .setup
                }
                guard round > oldRound else { return }
                presentRoundOpenerNudgeIfNeeded()
            }
            .onReceive(NotificationCenter.default.publisher(for: .matchSyncStateDidChange)) { _ in
                viewModel.reloadFromPersistedStores()
                onMatchStateChange?()
                syncCombatContext()
            }
            .onChange(of: viewModel.focusedDeploymentStep) { oldStep, newStep in
                guard oldStep != nil, newStep == nil else { return }
                presentRoundOpenerNudgeIfNeeded()
            }
            .onChange(of: viewModel.trackerState.activePlayerIsOne) { oldValue, _ in
                syncCombatContext()
                requestCombatResolverFocus(using: proxy)
                if handoffBaselineEstablished {
                    presentTurnHandoff(
                        from: viewModel.trackerState.currentPhase,
                        to: viewModel.trackerState.currentPhase,
                        playerChanged: oldValue != viewModel.trackerState.activePlayerIsOne
                    )
                }
            }
    }

    private struct TrackerNoticeDismissalsModifier: ViewModifier {
        let view: BattlePhaseTrackerView

        func body(content: Content) -> some View {
            content
                .onChange(of: view.damageUndoNotice) { _, notice in
                    scheduleDismiss(notice, seconds: 6) {
                        if view.damageUndoNotice == notice { view.damageUndoNotice = nil }
                    }
                }
                .onChange(of: view.turnHandoffNotice) { _, notice in
                    scheduleDismiss(notice, seconds: 5) {
                        if view.turnHandoffNotice == notice { view.turnHandoffNotice = nil }
                    }
                }
                .onChange(of: view.phaseActionNudge) { _, notice in
                    scheduleDismiss(notice, seconds: 8) {
                        if view.phaseActionNudge == notice { view.phaseActionNudge = nil }
                    }
                }
                .onChange(of: view.scoringReminderNotice) { _, notice in
                    scheduleDismiss(notice, seconds: 8) {
                        if view.scoringReminderNotice == notice { view.scoringReminderNotice = nil }
                    }
                }
                .onChange(of: view.roundOpenerNotice) { _, notice in
                    scheduleDismiss(notice, seconds: 8) {
                        if view.roundOpenerNotice == notice { view.roundOpenerNotice = nil }
                    }
                }
                .onChange(of: view.showsHeroRoundOneNotice) { _, isVisible in
                    guard isVisible else { return }
                    Task {
                        try? await Task.sleep(for: .seconds(10))
                        withAnimation(view.reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                            if view.showsHeroRoundOneNotice {
                                view.showsHeroRoundOneNotice = false
                            }
                        }
                    }
                }
        }

        private func scheduleDismiss<T: Equatable>(
            _ notice: T?,
            seconds: TimeInterval,
            clear: @escaping () -> Void
        ) {
            guard notice != nil else { return }
            Task {
                try? await Task.sleep(for: .seconds(seconds))
                withAnimation(view.reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                    clear()
                }
            }
        }
    }

    private func applyScrollTargets<Content: View>(
        to content: Content,
        proxy: ScrollViewProxy
    ) -> some View {
        content
            .onChange(of: scrollToCombatResolver) { _, shouldScroll in
                guard shouldScroll else { return }
                showsCombatResolver = true
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
                    proxy.scrollTo("combatResolver", anchor: .top)
                }
                scrollToCombatResolver = false
            }
            .onChange(of: scrollToVictoryPoints) { _, shouldScroll in
                guard shouldScroll else { return }
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
                    proxy.scrollTo("victoryPoints", anchor: .top)
                }
                scrollToVictoryPoints = false
                scoringReminderNotice = nil
            }
            .onChange(of: scrollToRoundChecklist) { _, shouldScroll in
                guard shouldScroll else { return }
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
                    proxy.scrollTo("roundChecklist", anchor: .top)
                }
                scrollToRoundChecklist = false
                roundOpenerNotice = nil
            }
            .onChange(of: scrollToPhaseControls) { _, shouldScroll in
                guard shouldScroll else { return }
                let target = showsSlimTurnTab ? "battleTracker.phasePlaybook" : "phaseControls"
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
                    proxy.scrollTo(target, anchor: .top)
                }
                scrollToPhaseControls = false
            }
    }

    func applyCombatEvaluationSync<V: View>(to view: V) -> some View {
        view
            .onChange(of: diceInputModeRaw) { _, _ in
                combatViewModel.clearSimulatedRolls()
                multiAttackViewModel.clearSimulatedRolls()
            }
            .onChange(of: combatViewModel.enabledBuffIds) { _, _ in
                syncMultiAttack()
                combatViewModel.refreshEvaluation()
            }
            .onChange(of: combatViewModel.hitRoll) { _, _ in combatViewModel.refreshEvaluation() }
            .onChange(of: combatViewModel.woundRoll) { _, _ in combatViewModel.refreshEvaluation() }
            .onChange(of: combatViewModel.saveRoll) { _, _ in combatViewModel.refreshEvaluation() }
            .onChange(of: combatViewModel.wardRoll) { _, _ in combatViewModel.refreshEvaluation() }
            .onChange(of: combatViewModel.damage) { _, _ in combatViewModel.refreshEvaluation() }
            .onChange(of: combatViewModel.rollOptions) { _, _ in combatViewModel.refreshEvaluation() }
            .onChange(of: combatViewModel.attackerWeaponId) { _, _ in syncMultiAttack() }
            .onChange(of: combatViewModel.defenderUnitId) { _, _ in syncMultiAttack() }
            .onChange(of: combatViewModel.attackerDeployedModelCount) { _, _ in
                combatViewModel.clearVariableAttackResolution()
                syncMultiAttack()
            }
            .onChange(of: combatViewModel.resolvedVariableAttackCount) { _, _ in syncMultiAttack() }
    }
}
