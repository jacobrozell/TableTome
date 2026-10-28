import SwiftUI

public struct TTRichTextListItem: Equatable, Sendable {
    public let number: String
    public let text: String

    public init(number: String, text: String) {
        self.number = number
        self.text = text
    }
}

public enum TTRichTextBlock: Equatable, Sendable {
    case paragraph(String)
    case subheading(String)
    case numberedList([TTRichTextListItem])
    case bulletList([String])
}

/// Pure rules-string parser. No SwiftUI types, so unit tests can call it directly.
public enum TTRichTextParser {
    public static func blocks(from content: String) -> [TTRichTextBlock] {
        let normalized = content.replacingOccurrences(of: "\r\n", with: "\n")
        return normalized
            .components(separatedBy: "\n\n")
            .flatMap { blocks(in: $0) }
    }

    private static func blocks(in chunk: String) -> [TTRichTextBlock] {
        let lines = chunk.components(separatedBy: "\n")
        var result: [TTRichTextBlock] = []
        var paragraphLines: [String] = []

        func flushParagraph() {
            let text = paragraphLines
                .joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            paragraphLines.removeAll()
            guard !text.isEmpty else { return }
            if !text.contains("\n"), text.count < 60, text.hasSuffix(":") {
                result.append(.subheading(text))
            } else {
                result.append(.paragraph(text))
            }
        }

        var index = 0
        while index < lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespaces)
            if line.isEmpty {
                flushParagraph()
                index += 1
                continue
            }
            if numberedItem(in: line) != nil {
                flushParagraph()
                var items: [TTRichTextListItem] = []
                while index < lines.count {
                    let candidate = lines[index].trimmingCharacters(in: .whitespaces)
                    guard let item = numberedItem(in: candidate) else { break }
                    items.append(item)
                    index += 1
                }
                result.append(.numberedList(items))
                continue
            }
            if bulletText(in: line) != nil {
                flushParagraph()
                var items: [String] = []
                while index < lines.count {
                    let candidate = lines[index].trimmingCharacters(in: .whitespaces)
                    guard let item = bulletText(in: candidate) else { break }
                    items.append(item)
                    index += 1
                }
                result.append(.bulletList(items))
                continue
            }
            paragraphLines.append(line)
            index += 1
        }
        flushParagraph()
        return result
    }

    private static func numberedItem(in line: String) -> TTRichTextListItem? {
        var index = line.startIndex
        guard index < line.endIndex, line[index].isNumber else { return nil }
        while index < line.endIndex, line[index].isNumber {
            index = line.index(after: index)
        }
        guard index < line.endIndex, line[index] == "." else { return nil }
        let number = String(line[..<index])
        var textIndex = line.index(after: index)
        guard textIndex < line.endIndex, line[textIndex].isWhitespace else { return nil }
        while textIndex < line.endIndex, line[textIndex].isWhitespace {
            textIndex = line.index(after: textIndex)
        }
        guard textIndex < line.endIndex else { return nil }
        return TTRichTextListItem(number: number, text: String(line[textIndex...]))
    }

    private static func bulletText(in line: String) -> String? {
        let prefixes = ["- ", "• "]
        for prefix in prefixes where line.hasPrefix(prefix) {
            let text = String(line.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
            guard !text.isEmpty else { return nil }
            return text
        }
        return nil
    }
}

/// Lightweight renderer for rules strings. Not Markdown, except inline bold and italic.
public struct TTRichText: View {
    private let content: String

    public init(_ content: String) {
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            ForEach(Array(TTRichTextParser.blocks(from: content).enumerated()), id: \.offset) { _, block in
                blockView(block)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func blockView(_ block: TTRichTextBlock) -> some View {
        switch block {
        case .paragraph(let text):
            Text(inlineAttributed(text, font: TTFont.body))
                .lineSpacing(3)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        case .subheading(let text):
            Text(inlineAttributed(text, font: TTFont.headline))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
        case .numberedList(let items):
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                        Text(item.number)
                            .font(TTFont.numericSmall)
                            .foregroundStyle(TTColor.brand)
                            .frame(minWidth: 24, alignment: .trailing)
                        Text(inlineAttributed(item.text, font: TTFont.body))
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        case .bulletList(let items):
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                        Text("•")
                            .font(TTFont.body)
                            .foregroundStyle(TTColor.brand)
                            .frame(minWidth: 24, alignment: .center)
                        Text(inlineAttributed(item, font: TTFont.body))
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private func inlineAttributed(_ source: String, font: Font) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        var parsed = (try? AttributedString(markdown: source, options: options)) ?? AttributedString(source)
        let runs = parsed.runs.map { (range: $0.range, intent: $0.inlinePresentationIntent ?? []) }
        for run in runs {
            if run.intent.contains(.stronglyEmphasized) {
                parsed[run.range].font = font.weight(.semibold)
            } else if run.intent.contains(.emphasized) {
                parsed[run.range].font = font.italic()
            } else {
                parsed[run.range].font = font
            }
            parsed[run.range].foregroundColor = TTColor.inkPrimary
        }
        return parsed
    }
}

#Preview("TTRichText") {
    TTPreviewMatrix {
        TTRichText(
            """
            Each battle round has two player turns.

            1. Start of Turn
            2. Hero Phase

            Use **one** Core ability per phase.
            """
        )
    }
}
