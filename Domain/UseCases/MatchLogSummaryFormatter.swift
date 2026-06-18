import Foundation

public enum MatchLogSummaryFormatter: Sendable {
    public static func title(for event: MatchLogEvent) -> String {
        switch event.kind {
        case .matchStarted:
            String(localized: "Match started")
        case .matchEnded:
            String(localized: "Match ended")
        case .setupStepCompleted:
            setupStepTitle(for: event)
        case .deploymentStepCompleted:
            deploymentStepTitle(for: event)
        case .phaseChanged:
            phaseTitle(for: event)
        case .roundAdvanced:
            String(localized: "Round \(event.payload.round ?? 0)")
        case .activePlayerChanged:
            String(localized: "\(event.payload.playerName ?? "")'s turn")
        case .victoryPointsChanged:
            victoryPointsTitle(for: event)
        case .abilityUsed:
            String(localized: "Ability used: \(event.payload.abilityName ?? "")")
        case .damageApplied:
            damageTitle(for: event)
        case .unitDestroyed:
            String(localized: "\(event.payload.unitName ?? "") destroyed")
        case .combatBatchResolved:
            combatBatchHeadline(for: event)
        case .userNote, .scActivation, .scSupplyChanged:
            fallbackTitle(for: event.kind)
        }
    }

    public static func subtitle(for event: MatchLogEvent) -> String? {
        switch event.kind {
        case .combatBatchResolved:
            combatBatchDetail(for: event)
        case .phaseChanged:
            if let player = event.payload.playerName {
                String(localized: "\(player)'s turn")
            } else {
                nil
            }
        default:
            nil
        }
    }

    public static func systemImage(for kind: MatchLogEventKind) -> String {
        switch kind {
        case .matchStarted, .matchEnded:
            "flag.checkered"
        case .setupStepCompleted, .deploymentStepCompleted:
            "checkmark.circle"
        case .phaseChanged, .roundAdvanced, .activePlayerChanged:
            "arrow.triangle.2.circlepath"
        case .victoryPointsChanged:
            "star.circle.fill"
        case .abilityUsed:
            "sparkles"
        case .damageApplied, .unitDestroyed:
            "heart.slash.fill"
        case .combatBatchResolved:
            "dice.fill"
        case .userNote:
            "note.text"
        case .scActivation, .scSupplyChanged:
            "bolt.fill"
        }
    }

    private static func fallbackTitle(for kind: MatchLogEventKind) -> String {
        switch kind {
        case .userNote: String(localized: "Note")
        case .scActivation: String(localized: "Activation")
        case .scSupplyChanged: String(localized: "Supply changed")
        default: ""
        }
    }

    private static func phaseTitle(for event: MatchLogEvent) -> String {
        let round = event.payload.round ?? 0
        let phase = phaseDisplayName(event.payload.phaseId)
        return String(localized: "Round \(round) · \(phase)")
    }

    private static func victoryPointsTitle(for event: MatchLogEvent) -> String {
        let name = event.payload.playerName ?? ""
        let delta = event.payload.delta ?? 0
        let sign = delta >= 0 ? "+" : ""
        let reason = pointsReasonLabel(event.payload.pointsReason ?? .manual)
        return String(localized: "\(name) \(sign)\(delta) VP (\(reason))")
    }

    private static func damageTitle(for event: MatchLogEvent) -> String {
        let unit = event.payload.unitName ?? ""
        let removed = event.payload.woundsRemoved ?? 0
        let remaining = event.payload.woundsRemaining ?? 0
        return String(localized: "\(unit) −\(removed) wounds (\(remaining) left)")
    }

    private static func setupStepTitle(for event: MatchLogEvent) -> String {
        guard let stepId = event.payload.stepId else {
            return String(localized: "Setup step completed")
        }
        if stepId.hasPrefix("mission:") {
            let missionId = String(stepId.dropFirst("mission:".count))
            return String(localized: "Mission selected: \(humanizeIdentifier(missionId))")
        }
        return String(localized: "Setup: \(humanizeIdentifier(stepId))")
    }

    private static func deploymentStepTitle(for event: MatchLogEvent) -> String {
        guard let stepId = event.payload.stepId else {
            return String(localized: "Deployment step completed")
        }
        if let title = deploymentChecklistTitle(stepId) {
            return title
        }
        return String(localized: "Deployment: \(humanizeIdentifier(stepId))")
    }

    private static func combatBatchHeadline(for event: MatchLogEvent) -> String {
        let attacker = event.payload.attackerUnitName ?? ""
        let defender = event.payload.defenderUnitName ?? ""
        let weapon = event.payload.weaponName ?? ""
        if weapon.isEmpty {
            return String(localized: "\(attacker) → \(defender)")
        }
        return String(localized: "\(attacker) → \(defender) · \(weapon)")
    }

    private static func combatBatchDetail(for event: MatchLogEvent) -> String {
        let hits = event.payload.combatHits ?? 0
        let wounds = event.payload.combatWounds ?? 0
        let saves = event.payload.combatFailedSaves ?? 0
        let damage = event.payload.combatDamageDealt ?? 0
        return String(
            localized: "\(hits) hits · \(wounds) wounds · \(saves) failed saves → \(damage) damage"
        )
    }

    private static func phaseDisplayName(_ phaseId: String?) -> String {
        guard let phaseId, !phaseId.isEmpty else { return "" }
        return BattleTurnPhase(rawValue: phaseId)?.title ?? humanizeIdentifier(phaseId)
    }

    private static func pointsReasonLabel(_ reason: MatchVictoryPointsReason) -> String {
        switch reason {
        case .objective:
            String(localized: "objective")
        case .tactic:
            String(localized: "battle tactic")
        case .manual:
            String(localized: "manual")
        case .other:
            String(localized: "other")
        }
    }

    private static func deploymentChecklistTitle(_ stepId: String) -> String? {
        if let step = DeploymentChecklistStep(rawValue: stepId) { return step.title }
        if let step = Wh40kDeploymentChecklistStep(rawValue: stepId) { return step.title }
        if let step = ScTmgDeploymentChecklistStep(rawValue: stepId) { return step.title }
        if let step = CombatPatrolDeploymentChecklistStep(rawValue: stepId) { return step.title }
        return nil
    }

    private static func humanizeIdentifier(_ value: String) -> String {
        value
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}
