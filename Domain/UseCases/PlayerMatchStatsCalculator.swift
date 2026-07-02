import Foundation

public struct PlayerMatchStats: Sendable, Equatable {
    public var wins: Int
    public var losses: Int
    public var ties: Int
    public var lastPlayedAt: Date?
    public var lastOpponentName: String?

    public init(
        wins: Int = 0,
        losses: Int = 0,
        ties: Int = 0,
        lastPlayedAt: Date? = nil,
        lastOpponentName: String? = nil
    ) {
        self.wins = wins
        self.losses = losses
        self.ties = ties
        self.lastPlayedAt = lastPlayedAt
        self.lastOpponentName = lastOpponentName
    }

    public var gamesPlayed: Int { wins + losses + ties }

    public var recordLabel: String {
        if ties > 0 {
            return "\(wins)W · \(losses)L · \(ties)T"
        }
        return "\(wins)W · \(losses)L"
    }
}

public enum PlayerMatchStatsCalculator: Sendable {
    public static func stats(
        for profile: PlayerProfile,
        records: [MatchRecord]
    ) -> PlayerMatchStats {
        var stats = PlayerMatchStats()
        let normalizedName = normalize(profile.displayName)

        for record in records {
            guard let slot = playerSlot(in: record, profileId: profile.id, normalizedName: normalizedName) else {
                continue
            }
            if stats.lastPlayedAt == nil || record.endedAt > stats.lastPlayedAt! {
                stats.lastPlayedAt = record.endedAt
                stats.lastOpponentName = opponentName(in: record, playerSlot: slot)
            }
            switch outcome(for: record, playerSlot: slot) {
            case .win:
                stats.wins += 1
            case .loss:
                stats.losses += 1
            case .tie:
                stats.ties += 1
            case .none:
                break
            }
        }
        return stats
    }

    public static func records(
        involving profile: PlayerProfile,
        from records: [MatchRecord]
    ) -> [MatchRecord] {
        let normalizedName = normalize(profile.displayName)
        return records.filter { record in
            playerSlot(in: record, profileId: profile.id, normalizedName: normalizedName) != nil
        }
    }

    public static func records(
        involvingProfileId profileId: UUID,
        normalizedName: String,
        from records: [MatchRecord]
    ) -> [MatchRecord] {
        records.filter { record in
            playerSlot(in: record, profileId: profileId, normalizedName: normalizedName) != nil
        }
    }

    public enum PerspectiveOutcome: Sendable, Equatable {
        case win, loss, tie
    }

    public static func perspectiveOutcome(
        for record: MatchRecord,
        profile: PlayerProfile
    ) -> PerspectiveOutcome? {
        let normalizedName = normalize(profile.displayName)
        guard let slot = playerSlot(in: record, profileId: profile.id, normalizedName: normalizedName) else {
            return nil
        }
        switch outcome(for: record, playerSlot: slot) {
        case .win: return .win
        case .loss: return .loss
        case .tie: return .tie
        case .none: return nil
        }
    }

    /// True when the record is linked to this profile by normalized name only (no archived profile id).
    public static func isLegacyNameAssociation(for record: MatchRecord, profile: PlayerProfile) -> Bool {
        let normalizedName = normalize(profile.displayName)
        guard playerSlot(in: record, profileId: profile.id, normalizedName: normalizedName) != nil else {
            return false
        }
        if record.players.playerOneProfileId == profile.id || record.players.playerTwoProfileId == profile.id {
            return false
        }
        return true
    }

    public static func legacyAssociatedProfiles(
        for record: MatchRecord,
        profiles: [PlayerProfile]
    ) -> [PlayerProfile] {
        profiles.filter { isLegacyNameAssociation(for: record, profile: $0) }
    }

    private enum Outcome {
        case win, loss, tie, none
    }

    private enum PlayerSlot {
        case playerOne, playerTwo
    }

    private static func playerSlot(
        in record: MatchRecord,
        profileId: UUID,
        normalizedName: String
    ) -> PlayerSlot? {
        if record.players.playerOneProfileId == profileId { return .playerOne }
        if record.players.playerTwoProfileId == profileId { return .playerTwo }
        if normalize(record.players.playerOneName) == normalizedName { return .playerOne }
        if normalize(record.players.playerTwoName) == normalizedName { return .playerTwo }
        return nil
    }

    private static func outcome(for record: MatchRecord, playerSlot slot: PlayerSlot) -> Outcome {
        switch record.result.winner {
        case .tie:
            return .tie
        case .playerOne:
            return slot == .playerOne ? .win : .loss
        case .playerTwo:
            return slot == .playerTwo ? .win : .loss
        case .undecided:
            return .none
        }
    }

    private static func opponentName(in record: MatchRecord, playerSlot slot: PlayerSlot) -> String {
        switch slot {
        case .playerOne:
            record.players.playerTwoName
        case .playerTwo:
            record.players.playerOneName
        }
    }

    private static func normalize(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
