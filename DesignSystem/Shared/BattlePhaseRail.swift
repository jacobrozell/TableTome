import SwiftUI
import TabletomeDomain

struct BattlePhaseRail: View {
    let phases: [BattleTurnPhase]
    let current: BattleTurnPhase
    let tone: TTTone
    let gameSystemId: String
    var axis: Axis = .horizontal
    var showsDeployment: Bool = false
    var isInteractive: Bool = true
    let onSelect: (BattleTurnPhase) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var currentPhase
    @State private var scrolledPhase: BattleTurnPhase?
    @State private var infoPhase: BattleTurnPhase?

    var body: some View {
        Group {
            if showsDeployment {
                deploymentChip
            } else if axis == .vertical {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    phaseButtons
                }
                .padding(.vertical, DesignTokens.Spacing.xs)
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        phaseButtons
                    }
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $scrolledPhase)
                .scrollIndicators(.hidden)
            }
        }
        .frame(minHeight: axis == .vertical ? nil : DesignTokens.Size.phaseRailHeight)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(String(localized: "Turn phases"))
        .accessibilityIdentifier("battleTracker.phaseRail")
        .accessibilityAdjustableAction { direction in
            guard isInteractive else { return }
            shift(direction == .increment ? 1 : -1)
        }
        .onAppear { scrolledPhase = current }
        .onChange(of: current) { _, phase in
            scrolledPhase = phase
        }
        .ttHaptic(.phaseAdvanced, trigger: current)
        .popover(item: $infoPhase) { phase in
            Text(phase.playerFacingSummary(gameSystemId: gameSystemId))
                .font(TTFont.footnote)
                .foregroundStyle(TTColor.inkPrimary)
                .padding()
                .frame(maxWidth: 280)
                .presentationCompactAdaptation(.popover)
        }
    }

    private var deploymentChip: some View {
        Text(String(localized: "Deployment"))
            .font(TTFont.buttonSmall)
            .foregroundStyle(tone.onSolid)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .frame(minHeight: 32)
            .background(tone.solid, in: Capsule())
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("battleTracker.phaseRail.deployment")
    }

    private var phaseButtons: some View {
        ForEach(phases) { phase in
            phaseButton(phase)
                .id(phase)
        }
    }

    private func phaseButton(_ phase: BattleTurnPhase) -> some View {
        let state = phaseState(phase)
        return Button {
            guard isInteractive else { return }
            onSelect(phase)
        } label: {
            HStack(spacing: DesignTokens.Spacing.xxs) {
                if state == .done {
                    Image(systemName: "checkmark")
                        .font(TTFont.caption)
                        .accessibilityHidden(true)
                }
                if state == .current {
                    Image(systemName: phase.battleSystemImage)
                        .accessibilityHidden(true)
                }
                Text(phase.shortTitle)
                    .font(TTFont.buttonSmall)
                    .lineLimit(1)
            }
            .foregroundStyle(labelColor(state))
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .frame(minHeight: axis == .vertical ? 36 : 32)
            .background {
                if state == .current {
                    Capsule()
                        .fill(tone.solid)
                        .matchedGeometryEffect(id: "currentPhase", in: currentPhase)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel(phase, state: state))
        .accessibilityHint(String(localized: "Jumps to this phase"))
        .accessibilityIdentifier("battleTracker.phaseRail.\(phase.rawValue)")
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.4).onEnded { _ in
                infoPhase = phase
            }
        )
    }

    private func phaseState(_ phase: BattleTurnPhase) -> PhaseState {
        guard let currentIndex = phases.firstIndex(of: current),
              let index = phases.firstIndex(of: phase) else {
            return phase == current ? .current : .upcoming
        }
        if index < currentIndex { return .done }
        if index == currentIndex { return .current }
        return .upcoming
    }

    private func labelColor(_ state: PhaseState) -> Color {
        switch state {
        case .done: TTColor.inkSecondary
        case .current: tone.onSolid
        case .upcoming: TTColor.inkTertiary
        }
    }

    private func accessibilityLabel(_ phase: BattleTurnPhase, state: PhaseState) -> String {
        switch state {
        case .done: String(localized: "\(phase.title), done")
        case .current: String(localized: "\(phase.title), current")
        case .upcoming: phase.title
        }
    }

    private func shift(_ delta: Int) {
        guard let index = phases.firstIndex(of: current) else { return }
        let next = index + delta
        guard phases.indices.contains(next) else { return }
        onSelect(phases[next])
    }

    private enum PhaseState { case done, current, upcoming }
}
