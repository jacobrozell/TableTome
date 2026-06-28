import SwiftUI
import TabletomeDomain

struct CombatPatrolDeploymentChecklistCard: View {
    let completedSteps: Set<String>
    let focusedSteps: Set<CombatPatrolDeploymentChecklistStep>
    let onToggle: (CombatPatrolDeploymentChecklistStep, Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: String(localized: "Battlefield Checklist"), systemImage: "map")
            ForEach(CombatPatrolDeploymentChecklistStep.allCases) { step in
                let isComplete = CombatPatrolDeploymentChecklist.isComplete(
                    step: step,
                    completedSteps: completedSteps
                )
                let isFocused = focusedSteps.contains(step)
                Button {
                    onToggle(step, !isComplete)
                } label: {
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                        Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isComplete ? Color.accentColor : Color(.tertiaryLabel))
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text(step.title)
                                .font(.subheadline.weight(isFocused ? .semibold : .regular))
                                .foregroundStyle(.primary)
                            Text(step.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("guidedMatch.cpDeployment.\(step.rawValue)")
            }
        }
        .surfaceCard()
    }
}

struct CombatPatrolMissionPickerCard: View {
    let missions: [CombatPatrolMission]
    let selectedMissionId: String?
    let onSelect: (String) -> Void

    private var sortedMissions: [CombatPatrolMission] {
        missions.sorted { ($0.d6Result ?? 99) < ($1.d6Result ?? 99) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: String(localized: "Choose Mission"), systemImage: "dice")

            if missions.isEmpty {
                Text(String(localized: "Mission list unavailable — pick Clash of Patrols from the rules reference."))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sortedMissions) { mission in
                    missionRow(mission)
                }
            }
        }
        .surfaceCard()
    }

    private func missionRow(_ mission: CombatPatrolMission) -> some View {
        let isSelected = selectedMissionId == mission.id
        return Button {
            onSelect(mission.id)
        } label: {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                HStack {
                    Text(mission.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if mission.recommendedForFirstGame == true {
                        Text(String(localized: "First game"))
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, DesignTokens.Spacing.sm)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.12), in: Capsule())
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.accentColor)
                    }
                }
                if let d6 = mission.d6Result {
                    Text(String(localized: "D6 result: \(d6)"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(mission.missionRuleSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignTokens.Spacing.sm)
            .background(
                isSelected
                    ? Color.accentColor.opacity(0.08)
                    : Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("guidedMatch.mission.\(mission.id)")
    }
}

struct FirstTurnPickerCard: View {
    let playerOneName: String
    let playerTwoName: String
    let firstTurnIsPlayerOne: Bool?
    let onSelect: (Bool?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: String(localized: "Who takes the first turn?"), systemImage: "arrow.triangle.2.circlepath")

            Picker(String(localized: "First turn"), selection: binding) {
                Text(String(localized: "Not decided")).tag(Optional<Bool>.none)
                Text(playerOneName).tag(Optional(true))
                Text(playerTwoName).tag(Optional(false))
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("guidedMatch.firstTurnPicker")
        }
        .surfaceCard()
    }

    private var binding: Binding<Bool?> {
        Binding(
            get: { firstTurnIsPlayerOne },
            set: { onSelect($0) }
        )
    }
}
