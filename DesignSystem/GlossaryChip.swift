import SwiftUI
import TabletomeDomain

extension GlossaryEntryLink {
    var inlineURL: URL {
        URL(string: "tabletome://glossary/\(gameSystemId)/\(entryId)")!
    }

    init?(inlineURL url: URL) {
        guard url.scheme == "tabletome", url.host == "glossary" else { return nil }
        let components = url.pathComponents.filter { $0 != "/" }
        guard components.count == 2 else { return nil }
        self.init(gameSystemId: components[0], entryId: components[1])
    }
}

/// Prose with the first occurrence of glossary terms linked inline — used on dense beginner screens.
struct InlineGlossaryText: View {
    let text: String
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    var ruleSections: [RuleSection] = []
    var font: Font = .callout
    var foregroundStyle: Color = .secondary

    @EnvironmentObject private var glossaryNavigation: GlossaryNavigationState

    private var segments: [GlossaryTextSegment] {
        GlossaryTextLinker.segments(
            in: text,
            gameSystemId: gameSystemId,
            ruleSections: ruleSections
        )
    }

    var body: some View {
        Text(attributedText)
            .font(font)
            .foregroundStyle(foregroundStyle)
            .environment(\.openURL, OpenURLAction(handler: handleURL))
            .inlineGlossaryAccessibilityActions(segments: segments, gameSystemId: gameSystemId) { link in
                glossaryNavigation.open(link)
            }
    }

    private var attributedText: AttributedString {
        var output = AttributedString()
        for segment in segments {
            switch segment {
            case .plain(let value):
                output.append(AttributedString(value))
            case .linked(let value, let entryId):
                var linked = AttributedString(value)
                linked.link = GlossaryEntryLink(gameSystemId: gameSystemId, entryId: entryId).inlineURL
                linked.underlineStyle = .single
                linked.foregroundColor = Color.accentColor
                output.append(linked)
            }
        }
        return output
    }

    private func handleURL(_ url: URL) -> OpenURLAction.Result {
        guard let link = GlossaryEntryLink(inlineURL: url) else {
            return .systemAction
        }
        glossaryNavigation.open(link)
        return .handled
    }
}

struct GlossaryChip: View {
    let entry: RulesGlossaryEntry
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    var ruleSections: [RuleSection] = []

    @EnvironmentObject private var glossaryNavigation: GlossaryNavigationState

    var body: some View {
        Button {
            glossaryNavigation.open(
                GlossaryEntryLink(gameSystemId: gameSystemId, entryId: entry.id)
            )
        } label: {
            Text(entry.term)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.accentOnSurface)
                .adaptiveLineLimit(2)
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
        .minimumTouchTarget()
        .accessibilityLabel(entry.term)
        .accessibilityHint(String(localized: "Opens the glossary definition for this term."))
        .accessibilityIdentifier("glossary.chip.\(entry.id)")
    }
}

struct GlossaryChipsRow: View {
    let text: String
    var label: String? = String(localized: "Key terms")
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    var ruleSections: [RuleSection] = []

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var entries: [RulesGlossaryEntry] {
        RulesGlossaryCatalog.entriesReferenced(
            in: text,
            gameSystemId: gameSystemId,
            ruleSections: ruleSections
        )
    }

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                if let label {
                    Text(label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                if dynamicTypeSize.needsLayoutAdaptation {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 120), spacing: DesignTokens.Spacing.sm)],
                        alignment: .leading,
                        spacing: DesignTokens.Spacing.sm
                    ) {
                        ForEach(entries) { entry in
                            GlossaryChip(
                                entry: entry,
                                gameSystemId: gameSystemId,
                                ruleSections: ruleSections
                            )
                        }
                    }
                    .accessibilityLabel(label ?? String(localized: "Key terms"))
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            ForEach(entries) { entry in
                                GlossaryChip(
                                    entry: entry,
                                    gameSystemId: gameSystemId,
                                    ruleSections: ruleSections
                                )
                            }
                        }
                    }
                    .accessibilityLabel(label ?? String(localized: "Key terms"))
                }
            }
        }
    }
}

private extension View {
    func inlineGlossaryAccessibilityActions(
        segments: [GlossaryTextSegment],
        gameSystemId: String,
        setPendingLink: @escaping (GlossaryEntryLink) -> Void
    ) -> some View {
        let linkedSegments: [(text: String, link: GlossaryEntryLink)] = segments.compactMap { segment in
            guard case .linked(let text, let entryId) = segment else { return nil }
            return (text, GlossaryEntryLink(gameSystemId: gameSystemId, entryId: entryId))
        }
        return linkedSegments.reduce(AnyView(self)) { view, item in
            AnyView(
                view.accessibilityAction(named: String(localized: "Define \(item.text)")) {
                    setPendingLink(item.link)
                }
            )
        }
    }
}
