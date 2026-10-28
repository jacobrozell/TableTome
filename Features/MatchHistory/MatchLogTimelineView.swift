import SwiftUI
import TabletomeDomain

struct MatchLogTimelineView: View {
    let events: [MatchLogEvent]

    private struct TimelineSection: Identifiable {
        let id: String
        let title: String
        let events: [MatchLogEvent]
        let collapsesPhaseChanges: Bool
    }

    private enum TimelineEntry: Identifiable {
        case event(MatchLogEvent)
        case phaseChanges(id: String, events: [MatchLogEvent])

        var id: String {
            switch self {
            case .event(let event):
                event.id.uuidString
            case .phaseChanges(let id, _):
                id
            }
        }
    }

    private var displayEvents: [MatchLogEvent] {
        var filtered: [MatchLogEvent] = []
        for (index, event) in events.enumerated() {
            if shouldHideDamageAfterBatch(event: event, at: index, in: events) {
                continue
            }
            filtered.append(event)
        }
        return filtered
    }

    private var groupedSections: [TimelineSection] {
        var sections: [TimelineSection] = []
        var currentTitle = ""
        var currentEvents: [MatchLogEvent] = []

        for event in displayEvents {
            let title = sectionTitle(for: event)
            if title != currentTitle, !currentEvents.isEmpty {
                sections.append(makeSection(title: currentTitle, events: currentEvents, index: sections.count))
                currentEvents = []
            }
            currentTitle = title
            currentEvents.append(event)
        }
        if !currentEvents.isEmpty {
            sections.append(makeSection(title: currentTitle, events: currentEvents, index: sections.count))
        }
        return sections
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            if displayEvents.isEmpty {
                Text(String(localized: "No events were recorded for this match."))
                    .font(TTFont.subheadline)
                    .foregroundStyle(TTColor.inkSecondary)
            } else {
                ForEach(groupedSections) { section in
                    sectionView(section)
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("matchLog.timeline")
    }

    private func sectionView(_ section: TimelineSection) -> some View {
        let entries = entries(for: section)
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            TTSectionHeader(section.title)
                .textCase(nil)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    let showsConnector = index < entries.count - 1
                    switch entry {
                    case .event(let event):
                        MatchLogEventRow(event: event, showsConnector: showsConnector)
                            .accessibilityIdentifier("matchLog.event.\(event.id.uuidString)")
                    case .phaseChanges(_, let phaseEvents):
                        MatchLogPhaseChangeGroup(
                            events: phaseEvents,
                            showsConnector: showsConnector,
                            accessibilityIdentifier: "matchLog.phaseChanges.\(section.id)"
                        )
                    }
                }
            }
        }
    }

    private func makeSection(title: String, events: [MatchLogEvent], index: Int) -> TimelineSection {
        TimelineSection(
            id: "\(index)-\(title)",
            title: title,
            events: events,
            collapsesPhaseChanges: events.contains(where: isRoundEvent)
        )
    }

    private func entries(for section: TimelineSection) -> [TimelineEntry] {
        guard section.collapsesPhaseChanges else {
            return section.events.map { .event($0) }
        }
        var entries: [TimelineEntry] = []
        var phases: [MatchLogEvent] = []
        var phaseIndex: Int?
        for event in section.events {
            if event.kind == .phaseChanged {
                if phaseIndex == nil {
                    phaseIndex = entries.count
                    entries.append(.phaseChanges(id: "phases-\(section.id)", events: []))
                }
                phases.append(event)
            } else {
                entries.append(.event(event))
            }
        }
        if let phaseIndex {
            entries[phaseIndex] = .phaseChanges(id: "phases-\(section.id)", events: phases)
        }
        return entries
    }

    private func shouldHideDamageAfterBatch(
        event: MatchLogEvent,
        at index: Int,
        in events: [MatchLogEvent]
    ) -> Bool {
        guard event.kind == .damageApplied, index > 0 else { return false }
        let previous = events[index - 1]
        guard previous.kind == .combatBatchResolved else { return false }
        guard event.payload.woundsRemoved == previous.payload.combatDamageDealt else { return false }
        let defender = previous.payload.defenderUnitName ?? ""
        let unit = event.payload.unitName ?? ""
        return !defender.isEmpty && defender == unit
    }

    private func isRoundEvent(_ event: MatchLogEvent) -> Bool {
        switch event.kind {
        case .matchStarted, .matchEnded, .setupStepCompleted, .deploymentStepCompleted:
            false
        default:
            event.payload.round != nil
        }
    }

    private func sectionTitle(for event: MatchLogEvent) -> String {
        switch event.kind {
        case .matchStarted, .matchEnded:
            String(localized: "Match")
        case .setupStepCompleted:
            String(localized: "Setup")
        case .deploymentStepCompleted:
            String(localized: "Deployment")
        default:
            if let round = event.payload.round {
                String(localized: "Round \(round)")
            } else {
                String(localized: "Battle")
            }
        }
    }
}

private struct MatchLogEventVisual {
    let systemImage: String
    let tone: TTTone

    static func visual(for event: MatchLogEvent) -> MatchLogEventVisual {
        switch event.kind {
        case .phaseChanged, .roundAdvanced, .activePlayerChanged:
            return MatchLogEventVisual(systemImage: "arrow.triangle.2.circlepath", tone: .neutral)
        case .victoryPointsChanged:
            let tone = event.payload.playerIsOne.map { TTTone.player($0) } ?? .neutral
            return MatchLogEventVisual(systemImage: "star.fill", tone: tone)
        case .damageApplied:
            return MatchLogEventVisual(systemImage: "bolt.fill", tone: .danger)
        case .abilityUsed:
            return MatchLogEventVisual(systemImage: "sparkles", tone: .brand)
        case .unitDestroyed:
            return MatchLogEventVisual(systemImage: "xmark.octagon.fill", tone: .danger)
        case .combatBatchResolved:
            return MatchLogEventVisual(
                systemImage: MatchLogSummaryFormatter.systemImage(for: event.kind),
                tone: .danger
            )
        case .matchStarted, .matchEnded, .setupStepCompleted, .deploymentStepCompleted,
             .userNote, .scActivation, .scSupplyChanged:
            return MatchLogEventVisual(
                systemImage: MatchLogSummaryFormatter.systemImage(for: event.kind),
                tone: .neutral
            )
        }
    }
}

private struct MatchLogEventRow: View {
    let event: MatchLogEvent
    let showsConnector: Bool

    var body: some View {
        let visual = MatchLogEventVisual.visual(for: event)
        MatchLogTimelineRow(
            systemImage: visual.systemImage,
            tone: visual.tone,
            title: MatchLogSummaryFormatter.title(for: event),
            subtitle: MatchLogSummaryFormatter.subtitle(for: event),
            time: event.timestamp.formatted(date: .omitted, time: .shortened),
            showsConnector: showsConnector
        )
    }
}

private struct MatchLogPhaseChangeGroup: View {
    let events: [MatchLogEvent]
    let showsConnector: Bool
    let accessibilityIdentifier: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(TTMotion.standard(reduceMotion: reduceMotion)) {
                    isExpanded.toggle()
                }
            } label: {
                MatchLogTimelineRow(
                    systemImage: "arrow.triangle.2.circlepath",
                    tone: .neutral,
                    title: phaseChangeLabel,
                    subtitle: nil,
                    time: nil,
                    showsConnector: isExpanded || showsConnector,
                    minimumHeight: DesignTokens.minTouchTarget,
                    groupsAccessibility: false
                ) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(TTFont.caption)
                        .foregroundStyle(TTColor.inkTertiary)
                        .accessibilityHidden(true)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel(phaseChangeLabel)
            .accessibilityValue(isExpanded ? String(localized: "Expanded") : String(localized: "Collapsed"))
            .accessibilityHint(
                isExpanded
                    ? String(localized: "Hides phase changes.")
                    : String(localized: "Shows each phase change.")
            )
            .accessibilityIdentifier(accessibilityIdentifier)

            if isExpanded {
                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                    let connects = showsConnector || index < events.count - 1
                    MatchLogEventRow(event: event, showsConnector: connects)
                        .accessibilityIdentifier("matchLog.event.\(event.id.uuidString)")
                        .transition(reduceMotion ? .identity : .opacity)
                }
            }
        }
    }

    private var phaseChangeLabel: String {
        if events.count == 1 {
            String(localized: "1 phase change")
        } else {
            String(localized: "\(events.count) phase changes")
        }
    }
}

private struct MatchLogTimelineRow<Trailing: View>: View {
    let systemImage: String
    let tone: TTTone
    let title: String
    let subtitle: String?
    let time: String?
    let showsConnector: Bool
    let minimumHeight: CGFloat
    let groupsAccessibility: Bool
    private let trailing: Trailing

    @ScaledMetric(relativeTo: .body) private var iconDiameter: CGFloat = 28

    init(
        systemImage: String,
        tone: TTTone,
        title: String,
        subtitle: String?,
        time: String?,
        showsConnector: Bool,
        minimumHeight: CGFloat = 0,
        groupsAccessibility: Bool = true,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.systemImage = systemImage
        self.tone = tone
        self.title = title
        self.subtitle = subtitle
        self.time = time
        self.showsConnector = showsConnector
        self.minimumHeight = minimumHeight
        self.groupsAccessibility = groupsAccessibility
        self.trailing = trailing()
    }

    var body: some View {
        TimelineRowLayout(spacing: DesignTokens.Spacing.sm) {
            icon
            textColumn
        }
        .overlay(alignment: .topLeading) {
            if showsConnector {
                VStack(spacing: 0) {
                    Color.clear.frame(width: iconDiameter, height: iconDiameter)
                    Rectangle()
                        .fill(TTColor.stroke)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
                .frame(width: iconDiameter, alignment: .top)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
        }
        .modifier(MatchLogRowAccessibility(groups: groupsAccessibility))
    }

    private var textColumn: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.xs) {
                Text(title)
                    .font(TTFont.subheadline)
                    .foregroundStyle(TTColor.inkPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                trailing
            }
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(TTFont.caption)
                    .foregroundStyle(TTColor.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let time {
                Text(time)
                    .font(TTFont.caption)
                    .foregroundStyle(TTColor.inkTertiary)
            }
        }
        .padding(.bottom, showsConnector ? DesignTokens.Spacing.md : DesignTokens.Spacing.xs)
        .frame(maxWidth: .infinity, minHeight: minimumHeight, alignment: .topLeading)
    }

    private var icon: some View {
        Image(systemName: systemImage)
            .resizable()
            .scaledToFit()
            .frame(width: iconDiameter * 0.5, height: iconDiameter * 0.5)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(tone.foreground)
            .frame(width: iconDiameter, height: iconDiameter)
            .background(tone.soft, in: Circle())
            .accessibilityHidden(true)
    }
}

extension MatchLogTimelineRow where Trailing == EmptyView {
    init(
        systemImage: String,
        tone: TTTone,
        title: String,
        subtitle: String?,
        time: String?,
        showsConnector: Bool
    ) {
        self.init(
            systemImage: systemImage,
            tone: tone,
            title: title,
            subtitle: subtitle,
            time: time,
            showsConnector: showsConnector,
            minimumHeight: 0,
            groupsAccessibility: true
        ) {
            EmptyView()
        }
    }
}

private struct MatchLogRowAccessibility: ViewModifier {
    let groups: Bool

    func body(content: Content) -> some View {
        if groups {
            content.accessibilityElement(children: .combine)
        } else {
            content
        }
    }
}

private struct TimelineRowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard subviews.count == 2 else { return .zero }
        let iconSize = subviews[0].sizeThatFits(.unspecified)
        let textWidth = max(0, (proposal.width ?? iconSize.width) - iconSize.width - spacing)
        let textSize = subviews[1].sizeThatFits(ProposedViewSize(width: textWidth, height: nil))
        let width = proposal.width ?? (iconSize.width + spacing + textSize.width)
        return CGSize(width: width, height: max(iconSize.height, textSize.height))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count == 2 else { return }
        let iconSize = subviews[0].sizeThatFits(.unspecified)
        subviews[0].place(
            at: CGPoint(x: bounds.minX, y: bounds.minY),
            anchor: .topLeading,
            proposal: ProposedViewSize(width: iconSize.width, height: bounds.height)
        )
        let textX = bounds.minX + iconSize.width + spacing
        subviews[1].place(
            at: CGPoint(x: textX, y: bounds.minY),
            anchor: .topLeading,
            proposal: ProposedViewSize(width: max(0, bounds.width - iconSize.width - spacing), height: nil)
        )
    }
}
