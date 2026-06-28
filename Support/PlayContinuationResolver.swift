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

    static func current() -> PlayContinuation? {
        if let resume = resumableMatch() {
            return resume
        }
        if let choice = FirstSessionStore.onboardingChoice,
           !FirstSessionStore.hasOpenedGameGuide {
            return openGuide(for: choice)
        }
        return nil
    }

    private static func resumableMatch() -> PlayContinuation? {
        let onboarding = FirstSessionStore.onboardingChoice
        let active = ActiveGameContextStore.gameSystemId

        var best: PlayContinuation?
        var bestScore = Int.min

        for gameSystemId in candidateGameSystemIds() {
            guard let continuation = resumeContinuation(for: gameSystemId) else { continue }
            let score = resumeScore(
                for: gameSystemId,
                continuation: continuation,
                onboardingChoice: onboarding,
                activeGameSystemId: active
            )
            if score > bestScore {
                bestScore = score
                best = continuation
            }
        }
        return best
    }

    private static func candidateGameSystemIds() -> [String] {
        var ids = Set(GameSystemId.allCases.map(\.rawValue))
        ids.insert(ActiveGameContextStore.gameSystemId)
        if let choice = FirstSessionStore.onboardingChoice {
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

    private static func openGuide(for gameSystemId: String) -> PlayContinuation {
        PlayContinuation(
            gameSystemId: gameSystemId,
            destination: .gameGuide,
            title: String(localized: "Continue your path"),
            message: openGuideMessage(for: gameSystemId),
            buttonTitle: openGuideButtonTitle(for: gameSystemId),
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
                You picked Age of Sigmar Spearhead. Open the guide for setup steps, then run Guided Match at the table.
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
        switch gameSystemId {
        case GameSystemId.aosSpearhead.rawValue:
            return String(localized: "Open Spearhead guide")
        case GameSystemId.wh40k10eCp.rawValue:
            return String(localized: "Open Combat Patrol guide")
        case GameSystemId.wh40k11e.rawValue:
            return String(localized: "Open Warhammer 40,000 guide")
        case GameSystemId.scTmg.rawValue:
            return String(localized: "Open StarCraft guide")
        default:
            return String(localized: "Open game guide")
        }
    }

    private static func resumeGuidedMatchButtonTitle(for gameSystemId: GameSystemId) -> String {
        switch gameSystemId {
        case .aosSpearhead:
            return String(localized: "Resume Spearhead match")
        case .wh40k10eCp:
            return String(localized: "Resume Combat Patrol match")
        case .wh40k11e:
            return String(localized: "Resume Warhammer 40,000 match")
        case .scTmg:
            return String(localized: "Resume StarCraft match")
        }
    }
}
