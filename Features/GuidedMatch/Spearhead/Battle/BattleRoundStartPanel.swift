import SwiftUI
import TabletomeDomain

struct BattleRoundStartPanel: View {
    @ObservedObject var viewModel: SpearheadBattleViewModel

    var body: some View {
        let round = viewModel.trackerState.battleRound
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(String(localized: "ROUND \(round) BEGINS"))
                .ttEyebrow()
            if let step = viewModel.focusedRoundOpenerStep {
                Text(step.title(round: round))
                    .font(TTFont.title)
                    .foregroundStyle(TTColor.inkPrimary)
                Text(step.detail(round: round))
                    .font(TTFont.body)
                    .foregroundStyle(TTColor.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if viewModel.focusedRoundOpenerStep == .firstTurnOrPriority {
                firstPlayerButtons
            }
            if let underdog = underdogLine {
                TTNotice(
                    title: String(localized: "Underdog"),
                    message: underdog,
                    systemImage: "arrow.down.circle.fill",
                    tone: .warning
                )
            }
            ForEach(BattleRoundChecklistStep.allCases) { step in
                checklistRow(step, round: round)
            }
        }
        .accessibilityIdentifier("battleTracker.roundStart")
        .onAppear {
            UIAccessibility.post(
                notification: .announcement,
                argument: String(localized: "Round \(round) begins")
            )
        }
    }

    private var firstPlayerButtons: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            playerButton(isPlayerOne: true)
            playerButton(isPlayerOne: false)
        }
    }

    private func playerButton(isPlayerOne: Bool) -> some View {
        let selected = viewModel.matchState.firstTurnIsPlayerOne == isPlayerOne
            || (viewModel.matchState.firstTurnIsPlayerOne == nil
                && viewModel.trackerState.activePlayerIsOne == isPlayerOne)
        let name = isPlayerOne ? viewModel.playerOneName : viewModel.playerTwoName
        return Group {
            if selected {
                Button {
                    viewModel.setRoundFirstTurn(isPlayerOne: isPlayerOne)
                } label: {
                    Text(String(localized: "\(name) goes first")).lineLimit(2)
                }
                .buttonStyle(.ttPlayer(isPlayerOne: isPlayerOne))
            } else {
                Button {
                    viewModel.setRoundFirstTurn(isPlayerOne: isPlayerOne)
                } label: {
                    Text(String(localized: "\(name) goes first")).lineLimit(2)
                }
                .buttonStyle(.ttSecondary)
            }
        }
        .accessibilityIdentifier(
            isPlayerOne
                ? "battleTracker.roundStart.firstPlayer.playerOne"
                : "battleTracker.roundStart.firstPlayer.playerTwo"
        )
    }

    private func checklistRow(_ step: BattleRoundChecklistStep, round: Int) -> some View {
        let key = BattleRoundChecklist.storageKey(round: round)
        let done = viewModel.trackerState.completedRoundChecklistSteps[key]?.contains(step.rawValue) == true
        return HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? TTColor.success : TTColor.inkTertiary)
                .accessibilityHidden(true)
            Text(step.title(round: round))
                .font(TTFont.body)
                .foregroundStyle(done ? TTColor.inkSecondary : TTColor.inkPrimary)
        }
        .accessibilityIdentifier("battleTracker.roundStart.\(step.rawValue)")
    }

    private var underdogLine: String? {
        guard let isPlayerOne = viewModel.underdogIsPlayerOne else {
            if viewModel.focusedRoundOpenerStep == .identifyUnderdog {
                return String(localized: "No underdog: scores are tied")
            }
            return nil
        }
        let name = isPlayerOne ? viewModel.playerOneName : viewModel.playerTwoName
        let low = min(viewModel.trackerState.playerOneVictoryPoints, viewModel.trackerState.playerTwoVictoryPoints)
        let high = max(viewModel.trackerState.playerOneVictoryPoints, viewModel.trackerState.playerTwoVictoryPoints)
        return String(localized: "\(name) is the underdog (\(low) vs \(high) VP)")
    }
}
