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
    var font: Font = TTFont.callout
    var foregroundStyle: Color = TTColor.inkSecondary

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
                var plain = AttributedString(value)
                plain.font = font
                plain.foregroundColor = foregroundStyle
                output.append(plain)
            case .linked(let value, let entryId):
                var linked = AttributedString(value)
                linked.font = font
                linked.link = GlossaryEntryLink(gameSystemId: gameSystemId, entryId: entryId).inlineURL
                linked.underlineStyle = Text.LineStyle(pattern: .dot, color: TTColor.brand)
                linked.foregroundColor = TTColor.brand
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
            HStack(spacing: DesignTokens.Spacing.xxs) {
                Image(systemName: "character.book.closed")
                    .font(TTFont.caption)
                    .foregroundStyle(TTColor.brand)
                    .accessibilityHidden(true)
                Text(entry.term)
                    .font(TTFont.subheadline.weight(.medium))
                    .foregroundStyle(TTColor.brand)
                    .multilineTextAlignment(.leading)
                    .adaptiveLineLimit(2)
            }
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .frame(minHeight: 32)
            .background(TTColor.brandSoft, in: Capsule())
            .frame(minHeight: DesignTokens.minTouchTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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

    private var entries: [RulesGlossaryEntry] {
        RulesGlossaryCatalog.entriesReferenced(
            in: text,
            gameSystemId: gameSystemId,
            ruleSections: ruleSections
        )
    }

    private var chipFlow: some View {
        TTFlowLayout(spacing: DesignTokens.Spacing.sm) {
            ForEach(entries) { entry in
                GlossaryChip(
                    entry: entry,
                    gameSystemId: gameSystemId,
                    ruleSections: ruleSections
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                if let label {
                    Text(label)
                        .font(TTFont.caption.weight(.semibold))
                        .foregroundStyle(TTColor.inkSecondary)
                        .accessibilityHidden(true)
                    chipFlow
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel(label)
                } else {
                    chipFlow
                        .accessibilityElement(children: .contain)
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

#Preview("GlossaryChip") {
    TTPreviewMatrix {
        GlossaryChip(
            entry: RulesGlossaryEntry(id: "rend", term: "Rend", definition: "Rend makes saves harder.")
        )
        .environmentObject(GlossaryNavigationState())
    }
}
