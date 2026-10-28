import TabletomeDomain

struct BattleActionPresentation: Equatable {
    let title: String
    let systemImage: String?
    let usesPlayerStyle: Bool
    let playerIsOne: Bool
    let usesCompleteIdentifier: Bool
}

enum BattleActionCopy {
    static func presentation(
        step: BattleFlowGuideStep?,
        activePlayerIsOne: Bool,
        activePlayerName: String,
        otherPlayerName: String,
        nextPhase: BattleTurnPhase?
    ) -> BattleActionPresentation {
        switch step?.kind {
        case .deployment(let deploymentStep):
            if deploymentStep == .deploymentAbilities {
                return brand(String(localized: "Begin Round 1"), systemImage: "flag.checkered")
            }
            return brand(String(localized: "Next"))
        case .roundOpener(let opener):
            if opener == .startOfRoundAbilities {
                return player(
                    String(localized: "Start \(activePlayerName)'s Turn"),
                    isPlayerOne: activePlayerIsOne
                )
            }
            return brand(String(localized: "Next"))
        case .turnPhase(let phase):
            if phase == .endOfTurn {
                return BattleActionPresentation(
                    title: String(localized: "Pass to \(otherPlayerName)"),
                    systemImage: "arrow.left.arrow.right",
                    usesPlayerStyle: true,
                    playerIsOne: !activePlayerIsOne,
                    usesCompleteIdentifier: false
                )
            }
            if nextPhase == .endOfTurn {
                return brand(String(localized: "End Turn"))
            }
            if let nextPhase {
                return brand(String(localized: "Start \(nextPhase.shortTitle) Phase"))
            }
            return brand(String(localized: "Next Phase"))
        case .startNextRound(let round):
            return brand(String(localized: "Start Round \(round + 1)"), systemImage: "flag.checkered")
        case .battleComplete:
            return BattleActionPresentation(
                title: String(localized: "See Results"),
                systemImage: "trophy.fill",
                usesPlayerStyle: false,
                playerIsOne: true,
                usesCompleteIdentifier: true
            )
        case .scSetup, .wh40kSetup, .cpSetup:
            return brand(String(localized: "Next"))
        case nil:
            return brand(String(localized: "Next Phase"))
        }
    }

    private static func brand(_ title: String, systemImage: String? = nil) -> BattleActionPresentation {
        BattleActionPresentation(
            title: title,
            systemImage: systemImage,
            usesPlayerStyle: false,
            playerIsOne: true,
            usesCompleteIdentifier: false
        )
    }

    private static func player(_ title: String, isPlayerOne: Bool) -> BattleActionPresentation {
        BattleActionPresentation(
            title: title,
            systemImage: nil,
            usesPlayerStyle: true,
            playerIsOne: isPlayerOne,
            usesCompleteIdentifier: false
        )
    }
}
