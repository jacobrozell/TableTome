import Foundation

/// Closed, compiler-checked alternatives to the system-named boolean flags on
/// `PlayCapabilities` (Phase 2 of the architecture refactor).
///
/// New code should branch on these enums instead of reading
/// `usesWh40k11eCombatRollEngine` / `showsScTmgDeploymentChecklist` etc. Adding
/// a system then selects an existing case (zero call-site churn) or adds one
/// case the compiler forces every switch to handle — instead of a new `Bool`
/// that silently defaults to `false` everywhere.
///
/// These are computed from the existing stored flags so the migration is
/// additive: nothing breaks, and the stored system-named booleans can be
/// deleted once every reader has moved to the enums.

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
    /// Which combat-roll engine, if any, this system uses — replaces the
    /// `usesWh40k10e/11eCombatRollEngine` boolean pair.
    public var combatRollEngineKind: CombatRollEngineKind {
        if usesWh40k11eCombatRollEngine { return .wh40k11e }
        if usesWh40k10eCombatRollEngine { return .wh40k10eCombatPatrol }
        return .none
    }

    /// Which deployment-checklist layout, if any — replaces the three
    /// `shows*DeploymentChecklist` booleans with one closed choice.
    public var deploymentChecklistStyle: DeploymentChecklistStyle {
        if showsWh40kDeploymentChecklist { return .wh40k }
        if showsScTmgDeploymentChecklist { return .scTmg }
        if showsDeploymentChecklist { return .spearhead }
        return .none
    }

    /// True when any combat-roll engine is configured.
    public var resolvesCombatRolls: Bool {
        combatRollEngineKind != .none
    }
}
