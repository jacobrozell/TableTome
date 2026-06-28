import Foundation

/// Closed, compiler-checked capability groupings (Phase 2).
/// New code branches on `combatRollEngineKind` / `deploymentChecklistStyle`
/// stored on `PlayCapabilities` — not system-named boolean flags.

public enum CombatRollEngineKind: String, Sendable, Equatable, CaseIterable {
    case none
    case wh40k10eCombatPatrol
    case wh40k11e
}

public enum DeploymentChecklistStyle: String, Sendable, Equatable, CaseIterable {
    case none
    case spearhead
    case wh40k
    case scTmg
}

extension PlayCapabilities {
    /// True when any combat-roll engine is configured.
    public var resolvesCombatRolls: Bool {
        combatRollEngineKind != .none
    }

    /// Patrol-format rules (stratagems, patrol scoring) — replaces `showsCombatPatrolMode`.
    public var usesPatrolFormatRules: Bool {
        combatRollEngineKind == .wh40k10eCombatPatrol
    }

    /// 40k-family rules (11e matched or 10e Combat Patrol).
    public var resolvesWh40kRules: Bool {
        deploymentChecklistStyle == .wh40k || usesPatrolFormatRules
    }
}
