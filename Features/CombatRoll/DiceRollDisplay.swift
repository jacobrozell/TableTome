import SwiftUI
import TabletomeDomain

enum DiceRollDisplay {
    static func purposeLabel(_ purpose: RollPurpose) -> String {
        switch purpose {
        case .hit: String(localized: "Hit")
        case .wound: String(localized: "Wound")
        case .save: String(localized: "Save")
        case .ward: String(localized: "Ward")
        case .damage: String(localized: "Damage")
        case .variableDamage(let kind): kind.rawValue
        }
    }

    static func rollSummary(_ rolls: [DiceRollResult]) -> String {
        rolls.map(rollLine).joined(separator: " · ")
    }

    static func rollLine(_ roll: DiceRollResult) -> String {
        let label = purposeLabel(roll.purpose)
        switch roll.purpose {
        case .variableDamage(.d3):
            let d6 = roll.underlyingRolls.first ?? roll.faceValue
            return "\(label) d6:\(d6)→\(roll.faceValue)"
        case .variableDamage(.d6):
            return "\(label) d6:\(roll.faceValue)"
        case .variableDamage(.twoD6):
            let parts = roll.underlyingRolls.map(String.init).joined(separator: "+")
            return "\(label) \(parts)=\(roll.faceValue)"
        default:
            return "\(label) d6:\(roll.faceValue)"
        }
    }

    static func matchesPurpose(_ lhs: RollPurpose, _ rhs: RollPurpose) -> Bool {
        switch (lhs, rhs) {
        case (.hit, .hit), (.wound, .wound), (.save, .save), (.ward, .ward), (.damage, .damage):
            true
        case (.variableDamage(let left), .variableDamage(let right)):
            left == right
        default:
            false
        }
    }
}

struct SimulatedRollSummaryView: View {
    let rolls: [DiceRollResult]

    private var summary: String { DiceRollDisplay.rollSummary(rolls) }

    var body: some View {
        if !rolls.isEmpty {
            Text(summary)
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("diceRoller.rollSummary")
                .accessibilityLabel(String(localized: "Rolled \(summary)"))
        }
    }
}
