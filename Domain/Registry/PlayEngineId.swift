import Foundation

public enum PlayEngineId: String, Codable, Sendable, CaseIterable {
    case phasedRound
    case alternatingActivation
    case gridSportDrive
    case commandCardPool
    case heroSkirmish
    case rulesOnly
}
