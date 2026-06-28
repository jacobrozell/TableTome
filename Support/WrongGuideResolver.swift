import Foundation
import TabletomeDomain

struct WrongGuideAlert: Equatable, Sendable {
    let title: String
    let message: String
    let suggestedGameSystemId: String
    let buttonTitle: String
}

/// Detects when the open game guide likely does not match the player's Play tab chooser pick.
enum WrongGuideResolver {
    static func alert(
        currentGameSystemId: String,
        onboardingChoice: String?,
        wh40kVariant: String?
    ) -> WrongGuideAlert? {
        if wh40kVariant == Wh40kChooserVariant.combatPatrol.rawValue,
           currentGameSystemId == GameSystemId.wh40k11e.rawValue,
           ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k10eCp.rawValue) {
            return WrongGuideAlert(
                title: String(localized: "Combat Patrol box?"),
                message: String(
                    localized: """
                    Your chooser pick was a Combat Patrol starter — that uses 10th Edition patrol rules. \
                    This guide is for 11th Edition (Battleforce, Armageddon, full 40k).
                    """
                ),
                suggestedGameSystemId: GameSystemId.wh40k10eCp.rawValue,
                buttonTitle: String(localized: "Open Combat Patrol guide")
            )
        }

        if let wh40kVariant,
           wh40kVariant != Wh40kChooserVariant.combatPatrol.rawValue,
           currentGameSystemId == GameSystemId.wh40k10eCp.rawValue,
           ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k11e.rawValue) {
            return WrongGuideAlert(
                title: String(localized: "11th Edition box?"),
                message: String(
                    localized: """
                    Your chooser pick was Battleforce, Armageddon, or full 40k — that uses 11th Edition rules. \
                    This guide is for Combat Patrol starter boxes only.
                    """
                ),
                suggestedGameSystemId: GameSystemId.wh40k11e.rawValue,
                buttonTitle: String(localized: "Open Warhammer 40,000 guide")
            )
        }

        guard let onboardingChoice else { return nil }
        guard onboardingChoice != currentGameSystemId else { return nil }

        if onboardingChoice == GameSystemId.wh40k10eCp.rawValue,
           currentGameSystemId == GameSystemId.wh40k11e.rawValue,
           ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k10eCp.rawValue) {
            return WrongGuideAlert(
                title: String(localized: "Combat Patrol box?"),
                message: String(
                    localized: """
                    You picked a Combat Patrol starter on Play — 10th Edition patrol rules. \
                    This guide is for 11th Edition full 40k.
                    """
                ),
                suggestedGameSystemId: GameSystemId.wh40k10eCp.rawValue,
                buttonTitle: String(localized: "Open Combat Patrol guide")
            )
        }

        if onboardingChoice == GameSystemId.aosSpearhead.rawValue,
           usesFortyKGuideSurface(currentGameSystemId) {
            return WrongGuideAlert(
                title: String(localized: "Wrong game guide?"),
                message: String(
                    localized: """
                    You picked an Age of Sigmar Spearhead box on Play. This guide is for Warhammer 40,000.
                    """
                ),
                suggestedGameSystemId: GameSystemId.aosSpearhead.rawValue,
                buttonTitle: String(localized: "Open Spearhead guide")
            )
        }

        if usesFortyKGuideSurface(onboardingChoice),
           currentGameSystemId == GameSystemId.aosSpearhead.rawValue {
            return WrongGuideAlert(
                title: String(localized: "Wrong game guide?"),
                message: String(
                    localized: """
                    You picked a Warhammer 40,000 box on Play. This guide is for Age of Sigmar Spearhead.
                    """
                ),
                suggestedGameSystemId: onboardingChoice,
                buttonTitle: String(localized: "Open Warhammer 40,000 guide")
            )
        }

        if onboardingChoice == GameSystemId.scTmg.rawValue,
           currentGameSystemId != GameSystemId.scTmg.rawValue {
            return WrongGuideAlert(
                title: String(localized: "Wrong game guide?"),
                message: String(
                    localized: "You picked StarCraft on Play. This guide is for a different game."
                ),
                suggestedGameSystemId: GameSystemId.scTmg.rawValue,
                buttonTitle: String(localized: "Open StarCraft guide")
            )
        }

        if currentGameSystemId == GameSystemId.scTmg.rawValue,
           onboardingChoice != GameSystemId.scTmg.rawValue {
            return WrongGuideAlert(
                title: String(localized: "Wrong game guide?"),
                message: String(
                    localized: "You picked a different game on Play. This guide is for StarCraft."
                ),
                suggestedGameSystemId: onboardingChoice,
                buttonTitle: suggestedGuideButtonTitle(for: onboardingChoice)
            )
        }

        return nil
    }

    private static func usesFortyKGuideSurface(_ gameSystemId: String) -> Bool {
        let capabilities = GameSystemPlayContext.context(for: gameSystemId).capabilities
        return capabilities.deploymentChecklistStyle == .wh40k
            || capabilities.usesPatrolFormatRules
    }

    private static func suggestedGuideButtonTitle(for gameSystemId: String) -> String {
        switch gameSystemId {
        case GameSystemId.aosSpearhead.rawValue:
            String(localized: "Open Spearhead guide")
        case GameSystemId.wh40k10eCp.rawValue:
            String(localized: "Open Combat Patrol guide")
        case GameSystemId.wh40k11e.rawValue:
            String(localized: "Open Warhammer 40,000 guide")
        default:
            String(localized: "Open recommended guide")
        }
    }
}

/// Which 40k starter path the player picked from the collapsed chooser.
enum Wh40kChooserVariant: String, Sendable {
    case combatPatrol
    case battleforce
    case armageddon
    case full
}
