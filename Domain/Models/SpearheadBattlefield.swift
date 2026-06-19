import Foundation

public enum SpearheadBattlefield: String, CaseIterable, Sendable, Identifiable {
    case fireAndJade
    case sandAndBone
    case cityOfAsh

    public var id: String { rawValue }

    public var name: String {
        switch self {
        case .fireAndJade: String(localized: "Fire and Jade")
        case .sandAndBone: String(localized: "Sand and Bone")
        case .cityOfAsh: String(localized: "City of Ash")
        }
    }

    public var flipCaption: String {
        switch self {
        case .fireAndJade:
            String(localized: "Fair 50/50 flip between Aqshy (Fire) and Ghyran (Jade).")
        case .sandAndBone:
            String(localized: "Fair 50/50 flip between Ossia (Sand) and Dolorum (Bone).")
        case .cityOfAsh:
            String(localized: "Fair 50/50 flip between Ashen Bastion and Shattered Crossroads.")
        }
    }

    public var newPlayerSummary: String {
        switch self {
        case .fireAndJade:
            String(
                localized: """
                The printed 30\"×22\" board from a Spearhead battlefield pack — Realm of Fire vs Realm of Life. \
                Each side has its own deployment map and twist deck from that pack.
                """
            )
        case .sandAndBone:
            String(
                localized: """
                Desert and graveyard themed board with Ossia (Sand) and Dolorum (Bone) sides. \
                Use the matching Sand and Bone twist deck for the side you pick.
                """
            )
        case .cityOfAsh:
            String(
                localized: """
                Ruined-city board with Ashen Bastion and Shattered Crossroads sides. \
                Objectives and deployment zones differ from the other battlefields.
                """
            )
        }
    }
}
