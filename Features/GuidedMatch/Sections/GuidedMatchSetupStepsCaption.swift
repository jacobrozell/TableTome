import Foundation
import TabletomeDomain

enum GuidedMatchSetupStepsCaption {
    static func text(gameSystemId: GameSystemId, stepCount: Int) -> String {
        switch gameSystemId {
        case .scTmg:
            return String(
                localized: "\(stepCount) steps — armies, mission setup, battlefield, attacker, and battle"
            )
        case .wh40k11e:
            return String(
                localized: "\(stepCount) steps — army pick, attacker roll, dispositions, deployment, and battle"
            )
        case .wh40k10eCp:
            return String(
                localized: "\(stepCount) steps — patrol, mission, formations, deployment, and battle"
            )
        default:
            return String(
                localized: "\(stepCount) steps — army pick, attacker roll, abilities, deployment, and battle"
            )
        }
    }
}
