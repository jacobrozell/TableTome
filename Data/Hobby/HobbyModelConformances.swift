import Foundation
import TabletomeDomain

extension Army: ArmyLike {}

extension SquadMember: SquadMemberLike {}

extension ArmyUnit: UnitLike {
    public var members: [any SquadMemberLike] {
        squadMembers.map { $0 as any SquadMemberLike }
    }

    public var orderedMembers: [any SquadMemberLike] {
        sortedSquadMembers.map { $0 as any SquadMemberLike }
    }
}
