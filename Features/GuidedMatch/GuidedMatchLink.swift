import Foundation
import TabletomeDomain

struct GuidedMatchLink: Hashable {
    let gameSystemId: GameSystemId
    var opensBattleTab: Bool = false
}
