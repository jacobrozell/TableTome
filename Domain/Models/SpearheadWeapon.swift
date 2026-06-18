import Foundation

public struct WeaponRollProfile: Sendable, Equatable {
    public let hit: Int
    public let wound: Int
    public let rend: Int
    public let damage: Int
}

public struct SpearheadWeapon: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let rangeInches: Int?
    public let attacks: String
    public let hit: Int
    public let wound: Int
    public let rend: Int
    public let damage: String
    public let ability: String?
    public let modelsWithWeapon: Int?

    public init(
        id: String,
        name: String,
        rangeInches: Int? = nil,
        attacks: String,
        hit: Int,
        wound: Int,
        rend: Int,
        damage: String,
        ability: String? = nil,
        modelsWithWeapon: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.rangeInches = rangeInches
        self.attacks = attacks
        self.hit = hit
        self.wound = wound
        self.rend = rend
        self.damage = damage
        self.ability = ability
        self.modelsWithWeapon = modelsWithWeapon
    }

    enum CodingKeys: String, CodingKey {
        case id, name, rangeInches, attacks, hit, wound, rend, damage, ability, modelsWithWeapon
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        rangeInches = try container.decodeIfPresent(Int.self, forKey: .rangeInches)
        attacks = try container.decode(String.self, forKey: .attacks)
        hit = try container.decode(Int.self, forKey: .hit)
        wound = try container.decode(Int.self, forKey: .wound)
        rend = try container.decode(Int.self, forKey: .rend)
        damage = try container.decode(String.self, forKey: .damage)
        ability = try container.decodeIfPresent(String.self, forKey: .ability)
        modelsWithWeapon = try container.decodeIfPresent(Int.self, forKey: .modelsWithWeapon)
    }

    public var isRanged: Bool { rangeInches != nil }

    /// Profile for the roll evaluator when damage is a fixed number.
    public var numericRollProfile: WeaponRollProfile? {
        guard let damageValue = Int(damage) else { return nil }
        return WeaponRollProfile(hit: hit, wound: wound, rend: rend, damage: damageValue)
    }
}
