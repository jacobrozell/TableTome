import Foundation
import TabletomeDomain

struct PlayContinuation: Equatable, Sendable {
    enum Destination: Equatable, Sendable {
        case gameGuide
        case guidedMatch
    }

    let gameSystemId: String
    let destination: Destination
    let title: String
    let message: String
    let buttonTitle: String
    /// When true, Guided Match should land on the battle tracker (in-progress table session).
    let opensBattleTab: Bool
}

enum PlayContinuationResolver {
    /// True when Guided Match should open on the Battle hub with the embedded tracker.
    static func shouldOpenBattleTab(gameSystemId: String) -> Bool {
        hasBattleProgress(gameSystemId: gameSystemId)
    }

    static func current(activeGameSystemId: String = ActiveGameContextPersistence.gameSystemId) -> PlayContinuation? {
        if let resume = resumableMatch(activeGameSystemId: activeGameSystemId) {
            return resume
        }
        if let choice = FirstSessionStore.onboardingChoice,
           ReleaseSurface.isPlayHomeGameSystemVisible(choice),
           !FirstSessionStore.hasOpenedGuidedMatch,
           !FirstSessionStore.hasOpenedGameGuide {
            if ReleaseSurface.showsGuidedMatch(for: choice) {
                return startGuidedMatch(for: choice)
            }
            return openGuide(for: choice)
        }
        return nil
    }

    private static func resumableMatch(activeGameSystemId: String) -> PlayContinuation? {
        let onboarding = FirstSessionStore.onboardingChoice

        var best: PlayContinuation?
        var bestScore = Int.min

        for gameSystemId in candidateGameSystemIds(activeGameSystemId: activeGameSystemId) {
            guard let continuation = resumeContinuation(for: gameSystemId) else { continue }
            let score = resumeScore(
                for: gameSystemId,
                continuation: continuation,
                onboardingChoice: onboarding,
                activeGameSystemId: activeGameSystemId
            )
            if score > bestScore {
                bestScore = score
                best = continuation
            }
        }
        return best
    }

    private static func candidateGameSystemIds(activeGameSystemId: String) -> [String] {
        var ids = Set(
            GameSystemId.allCases.map(\.rawValue).filter { ReleaseSurface.isGameSystemIdVisible($0) }
        )
        if ReleaseSurface.isGameSystemIdVisible(activeGameSystemId) {
            ids.insert(activeGameSystemId)
        }
        if let choice = FirstSessionStore.onboardingChoice,
           ReleaseSurface.isGameSystemIdVisible(choice) {
            ids.insert(choice)
        }
        return Array(ids)
    }

    private static func resumeScore(
        for gameSystemId: String,
        continuation: PlayContinuation,
        onboardingChoice: String?,
        activeGameSystemId: String
    ) -> Int {
        var score = continuation.opensBattleTab ? 100 : 10
        if gameSystemId == onboardingChoice { score += 5 }
        if gameSystemId == activeGameSystemId { score += 1 }
        return score
    }

    private static func resumeContinuation(for gameSystemId: String) -> PlayContinuation? {
        let matchState = MatchSetupStore.load(gameSystemId: gameSystemId)
        guard matchState.hasGuidedMatchProgress else { return nil }

        let resolvedId = GameSystemId(resolving: gameSystemId)
        if hasBattleProgress(gameSystemId: gameSystemId) {
            return battleResume(for: gameSystemId, resolvedId: resolvedId, matchState: matchState)
        }
        return setupResume(for: gameSystemId, resolvedId: resolvedId, matchState: matchState)
    }

    private static func hasBattleProgress(gameSystemId: String) -> Bool {
        BattleTrackerStore.hasResumableBattleProgress(gameSystemId: gameSystemId)
    }

    private static func setupResume(
        for gameSystemId: String,
        resolvedId: GameSystemId,
        matchState: GuidedMatchState
    ) -> PlayContinuation {
        let gameName = GameSystemRulesLabels.displayName(gameSystemId: resolvedId)
        let completedSteps = matchState.completedStepIds.count

        let message: String
        if matchState.hasBothArmies {
            if completedSteps > 0 {
                message = String(
                    localized: """
                    Your \(gameName) armies are set. Pick up the remaining setup steps where you left off.
                    """
                )
            } else {
                message = String(
                    localized: """
                    Your \(gameName) armies are ready. Finish setup, then open the battle tracker at the table.
                    """
                )
            }
        } else if completedSteps > 0 {
            message = String(
                localized: """
                Continue your \(gameName) Guided Match setup where you left off.
                """
            )
        } else {
            message = String(
                localized: """
                Continue choosing armies and setup for your \(gameName) match.
                """
            )
        }

        return PlayContinuation(
            gameSystemId: gameSystemId,
            destination: .guidedMatch,
            title: String(localized: "Resume your match"),
            message: message,
            buttonTitle: resumeGuidedMatchButtonTitle(for: resolvedId),
            opensBattleTab: false
        )
    }

    private static func battleResume(
        for gameSystemId: String,
        resolvedId: GameSystemId,
        matchState: GuidedMatchState
    ) -> PlayContinuation {
        let tracker = BattleTrackerStore.load(gameSystemId: gameSystemId)
        let activeName = tracker.activePlayerIsOne
            ? displayName(for: matchState.playerOne, fallback: String(localized: "Player 1"))
            : displayName(for: matchState.playerTwo, fallback: String(localized: "Player 2"))
        let round = GameSystemPlayContext.context(for: resolvedId).playEngine.roundLabel(round: tracker.battleRound)
        let phase = tracker.currentPhase.title
        let gameName = GameSystemRulesLabels.displayName(gameSystemId: resolvedId)

        return PlayContinuation(
            gameSystemId: gameSystemId,
            destination: .guidedMatch,
            title: String(localized: "Return to your battle"),
            message: String(
                localized: """
                \(gameName) — \(round) · \(phase) · \(activeName). Pick up the battle tracker at the table.
                """
            ),
            buttonTitle: String(localized: "Return to battle"),
            opensBattleTab: true
        )
    }

    private static func openGuide(for gameSystemId: String) -> PlayContinuation? {
        guard ReleaseSurface.isGameSystemIdVisible(gameSystemId) else { return nil }
        return PlayContinuation(
            gameSystemId: gameSystemId,
            destination: .gameGuide,
            title: String(localized: "Continue your path"),
            message: openGuideMessage(for: gameSystemId),
            buttonTitle: openGuideButtonTitle(for: gameSystemId),
            opensBattleTab: false
        )
    }

    private static func startGuidedMatch(for gameSystemId: String) -> PlayContinuation {
        let resolvedId = GameSystemId(resolving: gameSystemId)
        let gameName = GameSystemRulesLabels.displayName(gameSystemId: resolvedId)
        return PlayContinuation(
            gameSystemId: gameSystemId,
            destination: .guidedMatch,
            title: String(localized: "Start your first match"),
            message: startGuidedMatchMessage(for: gameSystemId, gameName: gameName),
            buttonTitle: startGuidedMatchButtonTitle(for: resolvedId),
            opensBattleTab: false
        )
    }

    private static func displayName(for selection: PlayerArmySelection, fallback: String) -> String {
        selection.playerName.isEmpty ? fallback : selection.playerName
    }

    private static func openGuideMessage(for gameSystemId: String) -> String {
        switch gameSystemId {
        case GameSystemId.aosSpearhead.rawValue:
            return String(
                localized: """
                Open the Spearhead guide for a quick overview, or jump straight into Guided Match at the table.
                """
            )
        case GameSystemId.wh40k10eCp.rawValue:
            return String(
                localized: """
                You picked Combat Patrol. Open the guide for missions and setup, then start Guided Match when you're ready.
                """
            )
        case GameSystemId.wh40k11e.rawValue:
            return String(
                localized: """
                You picked full Warhammer 40,000. Open the guide for deployment and phase tips, then run Guided Match.
                """
            )
        case GameSystemId.scTmg.rawValue:
            return String(
                localized: """
                You picked StarCraft: The Miniatures Game. Open the guide for economy and phases, then run Guided Match.
                """
            )
        default:
            return String(
                localized: """
                Open your game guide for setup steps, then run Guided Match at the table.
                """
            )
        }
    }

    private static func openGuideButtonTitle(for gameSystemId: String) -> String {
        GameSystemRegistry.bundled.copy(for: gameSystemId)?.openGuideButtonTitle
            ?? String(localized: "Open game guide")
    }

    private static func resumeGuidedMatchButtonTitle(for gameSystemId: GameSystemId) -> String {
        GameSystemPlayContext.context(for: gameSystemId).copy.resumeMatchButtonTitle
    }

    private static func startGuidedMatchMessage(for gameSystemId: String, gameName: String) -> String {
        if let message = GameSystemRegistry.bundled.copy(for: gameSystemId)?.startGuidedMatchMessage {
            return message
        }
        return String(localized: "Tap below to open Guided Match for \(gameName).")
    }

    private static func startGuidedMatchButtonTitle(for gameSystemId: GameSystemId) -> String {
        GameSystemPlayContext.context(for: gameSystemId).copy.startGuidedMatchButtonTitle
    }
}
