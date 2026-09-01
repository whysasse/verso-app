import SwiftUI

// MARK: - Data Model

enum MarkdownNode {
    /// FAB-303 step 1: where a block's content actually came from in the source file, carried by
    /// every "text" block type (paragraph, heading, list item, blockquote — the set FAB-303's
    /// later steps merge into cross-block selectable "text regions"). `codeBlock`/`image`/
    /// `horizontalRule`/`table` don't carry this — nothing consumes it for those yet.
    struct BlockSource {
        /// 0-based, inclusive source line span this block was parsed from. Single-line for
        /// heading/list-item/blockquote; can span multiple lines for a paragraph.
        let lineRange: ClosedRange<Int>
        /// Those lines joined by `\n`, byte-for-byte identical to source (not trimmed/collapsed)
        /// -- so a highlight action can splice it back in exactly. Supersedes `.paragraph`'s
        /// FAB-54 `rawText` field, now generalized to every case listed above.
        let rawText: String
        /// UTF-16 offset (matching this file's `NSRange` conventions) from the start of `rawText`
        /// to where the block's actual content begins -- e.g. 2 for `"- "`/`"> "`, `level + 1` for
        /// a heading's `"#"..."####" + " "`, or (for a paragraph) however much leading whitespace
        /// was trimmed off before parsing. Computed generically (line/text length minus already-
        /// extracted content length) rather than hardcoded per syntax, so it can't drift out of
        /// sync with the parsing logic that produces it.
        ///
        /// FAB-303 step 2: `contentOffset + an InlineNode.sourceRange` is the node's *exact* raw
        /// offset within `rawText` -- for a paragraph this holds across the whole (possibly
        /// multi-line) `rawText`, not just its first line, because a paragraph's lines are joined
        /// with a single space for parsing and a single newline for `rawText`, and both are
        /// exactly 1 UTF-16 unit -- so the two stay position-for-position identical past the
        /// trimmed prefix. See `flushParagraph`.
        let contentOffset: Int
    }

    case paragraph(inlines: [InlineNode], source: BlockSource)
    case heading(level: Int, inlines: [InlineNode], source: BlockSource)
    case unorderedListItem(inlines: [InlineNode], source: BlockSource)
    case orderedListItem(index: Int, inlines: [InlineNode], source: BlockSource)
    case blockquote(inlines: [InlineNode], source: BlockSource)
    case codeBlock(language: String?, code: String)
    case image(url: String, alt: String)
    case horizontalRule
    /// GFM pipe table (FAB-293). `headers`/each row in `rows` are one cell per column, already
    /// run through `parseInlines`; `alignments` has one entry per column, from the delimiter
    /// row's `:---`/`:---:`/`---:` syntax (default `.leading` when absent).
    case table(headers: [[InlineNode]], rows: [[[InlineNode]]], alignments: [TableAlignment])

    enum TableAlignment {
        case leading, center, trailing
    }

    enum InlineNode {
        /// FAB-303 step 2: every case's `sourceRange` is the UTF-16 offset range of this node's
        /// *rendered content only* (markdown delimiters like `**`/`` ` ``/`[`/`]` excluded) within
        /// the string `parseInlines` was given -- `text` for a paragraph, `content` for a heading/
        /// list-item/blockquote (see `MarkdownNode.BlockSource`). Add the block's own
        /// `contentOffset` to get the exact raw-file offset, no searching required -- this is what
        /// lets a `HighlightableParagraphText` selection convert directly to a raw source position
        /// instead of FAB-54's whitespace-tolerant regex re-search. See `.versoSourceOffset` in
        /// `HighlightableParagraphText.swift`, where this is actually consumed.
        case text(String, sourceRange: Range<Int>)
        case bold(String, sourceRange: Range<Int>)
        case italic(String, sourceRange: Range<Int>)
        case boldItalic(String, sourceRange: Range<Int>)
        case code(String, sourceRange: Range<Int>)
        case link(text: String, url: String, sourceRange: Range<Int>)
        /// FAB-54: `==text==` (Obsidian/CommonMark-extension convention). Rendered with a
        /// background wash in the reading view's selectable paragraph text
        /// (`HighlightableParagraphText`) -- SwiftUI `Text` doesn't support per-run background
        /// color on `AttributedString`, so this case falls back to plain, unstyled text wherever
        /// it appears outside a paragraph (headings, list items, table cells, etc.).
        case highlight(String, sourceRange: Range<Int>)
    }
}

// MARK: - Parser

struct MarkdownParser {
    static func parse(_ markdown: String) -> [MarkdownNode] {
        var nodes: [MarkdownNode] = []
        var paragraphBuffer: [String] = []
        // FAB-303 step 1: the source line index where the current paragraph's first line was
        // appended -- nil whenever `paragraphBuffer` is empty. Lets `flushParagraph` report an
        // exact `lineRange` instead of the paragraph having no idea where it came from.
        var paragraphStartLine: Int? = nil
        var codeBuffer: [String] = []
        var codeLang: String? = nil
        var inCodeBlock = false
        var orderedIndex = 1

        func flushParagraph() {
            // Not trimmed -- `untrimmedText` and `rawText` below are the *same length*, character
            // for character, since a paragraph's lines are joined with a single space in one and a
            // single newline in the other (both exactly 1 UTF-16 unit). That equal-length property
            // is what makes `contentOffset` below (how much leading whitespace was trimmed off
            // `untrimmedText`) also the exact offset of `text`'s content within `rawText` -- no
            // per-line mapping table needed, even for a multi-line paragraph (FAB-303 step 2).
            let untrimmedText = paragraphBuffer.joined(separator: " ")
            let text = untrimmedText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty, let startLine = paragraphStartLine {
                let rawText = paragraphBuffer.joined(separator: "\n")
                let leadingTrim = untrimmedText.prefix(while: { $0.isWhitespace }).utf16.count
                let source = MarkdownNode.BlockSource(
                    lineRange: startLine...(startLine + paragraphBuffer.count - 1),
                    rawText: rawText,
                    contentOffset: leadingTrim
                )
                nodes.append(.paragraph(inlines: parseInlines(text), source: source))
            }
            paragraphBuffer = []
            paragraphStartLine = nil
        }

        // FAB-303 step 1: `BlockSource` for a single-line block (heading/list-item/blockquote)
        // whose `content` is `line` minus a fixed-syntax prefix. UTF-16 count, matching this
        // file's `NSRange` conventions elsewhere -- computed from the lengths already in hand
        // rather than a hardcoded prefix width, so it can't drift out of sync with parsing.
        func singleLineSource(line: String, at index: Int, content: String) -> MarkdownNode.BlockSource {
            MarkdownNode.BlockSource(
                lineRange: index...index,
                rawText: line,
                contentOffset: line.utf16.count - content.utf16.count
            )
        }

        let lines = markdown.components(separatedBy: "\n")
        // Index-based (not `for line in lines`) so the table branch below can look ahead at the
        // next line (delimiter row) and consume a variable number of following rows (FAB-293).
        var i = 0
        while i < lines.count {
            let line = lines[i]

            // Code block toggle
            if line.hasPrefix("```") {
                if inCodeBlock {
                    nodes.append(.codeBlock(language: codeLang, code: codeBuffer.joined(separator: "\n")))
                    inCodeBlock = false
                    codeBuffer = []
                    codeLang = nil
                } else {
                    flushParagraph()
                    inCodeBlock = true
                    let lang = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                    codeLang = lang.isEmpty ? nil : lang
                }
                i += 1
                continue
            }

            if inCodeBlock {
                codeBuffer.append(line)
                i += 1
                continue
            }

            // Blank line flushes paragraph
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                flushParagraph()
                orderedIndex = 1
                i += 1
                continue
            }

            // Horizontal rule
            let trimmed = line.trimmingCharacters(in: .init(charactersIn: "-* _"))
            if trimmed.isEmpty && (line.hasPrefix("---") || line.hasPrefix("***") || line.hasPrefix("___")) {
                flushParagraph()
                nodes.append(.horizontalRule)
                i += 1
                continue
            }

            // Headings
            if line.hasPrefix("#") {
                let level = line.prefix(while: { $0 == "#" }).count
                if level <= 4, line.count > level, line[line.index(line.startIndex, offsetBy: level)] == " " {
                    flushParagraph()
                    let content = String(line.dropFirst(level + 1))
                    let source = singleLineSource(line: line, at: i, content: content)
                    nodes.append(.heading(level: level, inlines: parseInlines(content), source: source))
                    i += 1
                    continue
                }
            }

            // Blockquote
            if line.hasPrefix("> ") {
                flushParagraph()
                let content = String(line.dropFirst(2))
                let source = singleLineSource(line: line, at: i, content: content)
                nodes.append(.blockquote(inlines: parseInlines(content), source: source))
                i += 1
                continue
            }

            // Image (before unordered list check to catch `![`)
            if let imageMatch = imagePattern.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                flushParagraph()
                let alt = rangeString(line, imageMatch.range(at: 1))
                let url = rangeString(line, imageMatch.range(at: 2))
                nodes.append(.image(url: url, alt: alt))
                i += 1
                continue
            }

            // Unordered list
            if line.hasPrefix("- ") || line.hasPrefix("* ") || line.hasPrefix("+ ") {
                flushParagraph()
                let content = String(line.dropFirst(2))
                let source = singleLineSource(line: line, at: i, content: content)
                nodes.append(.unorderedListItem(inlines: parseInlines(content), source: source))
                i += 1
                continue
            }

            // Ordered list
            if let olMatch = orderedListPattern.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                flushParagraph()
                let idx = Int(rangeString(line, olMatch.range(at: 1))) ?? orderedIndex
                let content = rangeString(line, olMatch.range(at: 2))
                let source = singleLineSource(line: line, at: i, content: content)
                nodes.append(.orderedListItem(index: idx, inlines: parseInlines(content), source: source))
                orderedIndex = idx + 1
                i += 1
                continue
            }

            // GFM table (FAB-293): the current line is a candidate header row only if the *next*
            // line is a delimiter row (`|---|---|`, etc.) -- that lookahead is the only thing that
            // tells a table apart from an ordinary paragraph that merely contains a `|`.
            if line.contains("|"), i + 1 < lines.count, isTableDelimiterRow(lines[i + 1]) {
                flushParagraph()
                let headerCells = splitTableRowCells(line)
                let alignments = parseTableAlignments(fromDelimiterCells: splitTableRowCells(lines[i + 1]))
                var dataRows: [[String]] = []
                var j = i + 2
                while j < lines.count, lines[j].contains("|") {
                    dataRows.append(splitTableRowCells(lines[j]))
                    j += 1
                }
                let columnCount = headerCells.count
                nodes.append(.table(
                    headers: headerCells.map(parseInlines),
                    rows: dataRows.map { row in padded(row, to: columnCount).map(parseInlines) },
                    alignments: padded(alignments, to: columnCount, with: .leading)
                ))
                i = j
                continue
            }

            // Paragraph accumulation
            if paragraphBuffer.isEmpty {
                paragraphStartLine = i
            }
            paragraphBuffer.append(line)
            i += 1
        }

        flushParagraph()
        return nodes
    }

    // MARK: Table parsing (FAB-293)

    private static let tableDelimiterPattern = try! NSRegularExpression(
        pattern: #"^\s*\|?\s*:?-{1,}:?\s*(\|\s*:?-{1,}:?\s*)*\|?\s*$"#
    )

    private static func isTableDelimiterRow(_ line: String) -> Bool {
        let range = NSRange(line.startIndex..., in: line)
        return tableDelimiterPattern.firstMatch(in: line, range: range) != nil
    }

    /// Splits a table row on unescaped `|` (a literal `\|` in the source is a cell's own pipe
    /// character, not a separator), trims each cell, and drops a leading/trailing empty cell
    /// produced by the row's own outer pipes (`| A | B |` vs. `A | B`, both valid GFM).
    private static func splitTableRowCells(_ line: String) -> [String] {
        let pipePlaceholder = "\u{E000}" // Unicode Private Use Area -- won't collide with real content
        let protected = line.replacingOccurrences(of: "\\|", with: pipePlaceholder)
        var cells = protected.components(separatedBy: "|")
        if let first = cells.first, first.trimmingCharacters(in: .whitespaces).isEmpty {
            cells.removeFirst()
        }
        if let last = cells.last, last.trimmingCharacters(in: .whitespaces).isEmpty {
            cells.removeLast()
        }
        return cells.map {
            $0.replacingOccurrences(of: pipePlaceholder, with: "|")
                .trimmingCharacters(in: .whitespaces)
        }
    }

    private static func parseTableAlignments(fromDelimiterCells cells: [String]) -> [MarkdownNode.TableAlignment] {
        cells.map { cell in
            switch (cell.hasPrefix(":"), cell.hasSuffix(":")) {
            case (true, true): return .center
            case (false, true): return .trailing
            default: return .leading
            }
        }
    }

    /// Pads a ragged row/alignment list up to `count` with `fill`, or truncates down to it, so a
    /// malformed table (a row with too few/many cells) can't crash the renderer.
    private static func padded<T>(_ items: [T], to count: Int, with fill: T) -> [T] {
        if items.count < count {
            return items + Array(repeating: fill, count: count - items.count)
        }
        return Array(items.prefix(count))
    }

    private static func padded(_ items: [String], to count: Int) -> [String] {
        padded(items, to: count, with: "")
    }

    // MARK: Inline parsing

    static func parseInlines(_ raw: String) -> [MarkdownNode.InlineNode] {
        var result: [MarkdownNode.InlineNode] = []
        var remaining = raw
        // FAB-303 step 2: UTF-16 units of `raw` consumed (emitted as nodes) so far. `remaining` is
        // always a suffix of `raw`, so this running total -- rather than repeated `String.Index`
        // distance-from-start calls -- is all that's needed to report each node's exact absolute
        // offset within `raw`.
        var consumedUTF16 = 0

        while !remaining.isEmpty {
            // Find the earliest match among all inline patterns
            var earliestRange: Range<String.Index>? = nil
            var earliestPattern: InlinePattern? = nil

            for pattern in inlinePatterns {
                guard let range = remaining.range(of: pattern.regex, options: .regularExpression) else { continue }
                if earliestRange == nil || range.lowerBound < earliestRange!.lowerBound {
                    earliestRange = range
                    earliestPattern = pattern
                }
            }

            guard let matchRange = earliestRange, let pattern = earliestPattern else {
                // No more patterns — emit remaining as plain text
                let length = remaining.utf16.count
                result.append(.text(remaining, sourceRange: consumedUTF16..<(consumedUTF16 + length)))
                break
            }

            // Emit any plain text before the match
            let prefix = String(remaining[remaining.startIndex..<matchRange.lowerBound])
            if !prefix.isEmpty {
                let length = prefix.utf16.count
                result.append(.text(prefix, sourceRange: consumedUTF16..<(consumedUTF16 + length)))
                consumedUTF16 += length
            }

            // Emit the matched inline node -- `matchStart` is the full match's own absolute offset
            // (including its markdown delimiters); each pattern's `makeNode` narrows this down to
            // just the content span it actually returns.
            let matchString = String(remaining[matchRange])
            let matchStart = consumedUTF16
            result.append(pattern.makeNode(matchString, matchStart))
            consumedUTF16 += matchString.utf16.count

            remaining = String(remaining[matchRange.upperBound...])
        }

        return result
    }

    // MARK: Private helpers

    private struct InlinePattern {
        let regex: String
        /// (full matched string including delimiters, that match's absolute UTF-16 start offset)
        /// -> the node, with its own `sourceRange` narrowed to the content span within the match.
        let makeNode: (String, Int) -> MarkdownNode.InlineNode
    }

    /// FAB-54: `==text==` marker pattern -- exposed so `ArticleHighlighter` (`Services/`) can reuse
    /// the exact same regex when counting/removing existing highlights, rather than risking a
    /// second, hand-copied pattern drifting out of sync with this one.
    static let highlightMarkerPattern = #"==(.+?)=="#

    private static let inlinePatterns: [InlinePattern] = [
        // Bold+italic must come before bold and italic
        InlinePattern(regex: #"\*{3}(.+?)\*{3}|_{3}(.+?)_{3}"#) { match, matchStart in
            let (content, range) = extractFirstGroup(match, prefixLen: 3, matchStart: matchStart)
            return .boldItalic(content, sourceRange: range)
        },
        InlinePattern(regex: highlightMarkerPattern) { match, matchStart in
            let (content, range) = extractFirstGroup(match, prefixLen: 2, matchStart: matchStart)
            return .highlight(content, sourceRange: range)
        },
        InlinePattern(regex: #"\*{2}(.+?)\*{2}|_{2}(.+?)_{2}"#) { match, matchStart in
            let (content, range) = extractFirstGroup(match, prefixLen: 2, matchStart: matchStart)
            return .bold(content, sourceRange: range)
        },
        InlinePattern(regex: #"\*(.+?)\*|_(.+?)_"#) { match, matchStart in
            let (content, range) = extractFirstGroup(match, prefixLen: 1, matchStart: matchStart)
            return .italic(content, sourceRange: range)
        },
        InlinePattern(regex: #"`([^`]+)`"#) { match, matchStart in
            let (content, range) = extractFirstGroup(match, prefixLen: 1, matchStart: matchStart)
            return .code(content, sourceRange: range)
        },
        InlinePattern(regex: #"\[([^\]]+)\]\(([^)]+)\)"#) { match, matchStart in
            // Extract link text and URL using NSRegularExpression
            let pattern = try! NSRegularExpression(pattern: #"\[([^\]]+)\]\(([^)]+)\)"#)
            let nsMatch = pattern.firstMatch(in: match, range: NSRange(match.startIndex..., in: match))!
            let text = rangeString(match, nsMatch.range(at: 1))
            let url = rangeString(match, nsMatch.range(at: 2))
            // Content (the link label) starts right after the opening "[".
            let contentStart = matchStart + 1
            let range = contentStart..<(contentStart + text.utf16.count)
            return .link(text: text, url: url, sourceRange: range)
        },
    ]

    /// Strips `prefixLen` characters from each end of `match` (its markdown delimiters) and
    /// computes the resulting content's absolute `sourceRange`, given `matchStart` -- the full
    /// match's own absolute offset (delimiters included).
    private static func extractFirstGroup(_ match: String, prefixLen: Int, matchStart: Int) -> (String, Range<Int>) {
        let inner = String(match.dropFirst(prefixLen).dropLast(prefixLen))
        let contentStart = matchStart + prefixLen
        return (inner, contentStart..<(contentStart + inner.utf16.count))
    }

    private static let imagePattern = try! NSRegularExpression(pattern: #"!\[([^\]]*)\]\(([^)]+)\)"#)
    private static let orderedListPattern = try! NSRegularExpression(pattern: #"^(\d+)\.\s+(.+)$"#)

    private static func rangeString(_ s: String, _ nsRange: NSRange) -> String {
        guard nsRange.location != NSNotFound, let range = Range(nsRange, in: s) else { return "" }
        return String(s[range])
    }
}

// MARK: - View

extension MarkdownNode {
    var plainText: String {
        switch self {
        case .paragraph(let inlines, _), .heading(_, let inlines, _),
             .unorderedListItem(let inlines, _), .orderedListItem(_, let inlines, _),
             .blockquote(let inlines, _):
            return inlines.map(\.plainText).joined()
        case .codeBlock(_, let code): return code
        case .image(_, let alt): return alt
        case .horizontalRule: return ""
        case .table(let headers, let rows, _):
            return ([headers] + rows)
                .flatMap { row in row.map { cell in cell.map(\.plainText).joined() } }
                .joined(separator: " ")
        }
    }
}

extension MarkdownNode.InlineNode {
    var plainText: String {
        switch self {
        case .text(let s, _), .bold(let s, _), .italic(let s, _), .boldItalic(let s, _), .code(let s, _), .highlight(let s, _): return s
        case .link(let text, _, _): return text
        }
    }
}

struct MarkdownBodyView: View {
    let nodes: [MarkdownNode]
    let fontFamily: String
    let fontSize: CGFloat
    let lineSpacingValue: CGFloat
    let colors: ThemeColors
    var highlightedParagraphIndex: Int? = nil
    /// Directory of the article file — used to resolve relative image paths (e.g. `./Article.media/img.jpg`).
    var baseDirectoryURL: URL? = nil
    /// Called with (the paragraph's source line range, its new raw text) whenever the user adds or
    /// removes a highlight, so the caller can splice the change into the full article body and
    /// persist it. `nil` (the default) disables highlighting entirely — used by every preview/
    /// consumer that doesn't need it.
    ///
    /// FAB-303 step 1: `lineRange` (from `MarkdownNode.BlockSource`) replaces FAB-54's original
    /// `oldRawText` — the caller used to relocate the paragraph in the full document via
    /// `parsedContent.range(of: oldRawText)`, a literal text search that targeted the wrong
    /// paragraph when its exact text repeated elsewhere in the article. An exact line range can't
    /// have that ambiguity.
    var onHighlightAction: ((_ lineRange: ClosedRange<Int>, _ newRawText: String) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(nodes.enumerated()), id: \.offset) { index, node in
                blockView(for: node, index: index)
            }
        }
    }

    @ViewBuilder
    private func blockView(for node: MarkdownNode, index: Int) -> some View {
        let prevNode: MarkdownNode? = index > 0 ? nodes[index - 1] : nil
        let isListItem: Bool = {
            switch node {
            case .unorderedListItem, .orderedListItem: return true
            default: return false
            }
        }()
        let prevIsListItem: Bool = {
            switch prevNode {
            case .unorderedListItem, .orderedListItem: return true
            default: return false
            }
        }()

        Group {
            switch node {
            case .paragraph(let inlines, let source):
                // FAB-54: selectable (unlike every other block type here, which stays plain `Text`)
                // so the user can select a run of text and highlight it. Bridges to UIKit because
                // SwiftUI `Text` has no selection-change hook and doesn't honor a per-run background
                // color on `AttributedString` — both are needed to show/manage a highlight in place.
                HighlightableParagraphText(
                    inlines: inlines,
                    rawText: source.rawText,
                    lineRange: source.lineRange,
                    contentOffset: source.contentOffset,
                    fontFamily: fontFamily,
                    fontSize: fontSize,
                    lineSpacingValue: lineSpacingValue,
                    colors: colors,
                    onHighlightAction: onHighlightAction
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    highlightedParagraphIndex == index
                        ? colors.accent.opacity(0.15)
                        : Color.clear
                )

            case .heading(let level, let inlines, _):
                Text(inlineText(inlines))
                    .font(headingFont(level: level))
                    .foregroundColor(colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

            case .unorderedListItem(let inlines, _):
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("•")
                        .font(bodyFont)
                        .foregroundColor(colors.textSecondary)
                    Text(inlineText(inlines))
                        .font(bodyFont)
                        .lineSpacing(lineSpacingValue)
                        .foregroundColor(colors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

            case .orderedListItem(let idx, let inlines, _):
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(idx).")
                        .font(bodyFont)
                        .foregroundColor(colors.textSecondary)
                        .frame(minWidth: 24, alignment: .trailing)
                    Text(inlineText(inlines))
                        .font(bodyFont)
                        .lineSpacing(lineSpacingValue)
                        .foregroundColor(colors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

            case .blockquote(let inlines, _):
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(colors.accent)
                        .frame(width: 3)
                    Text(inlineText(inlines))
                        .font(bodyFont.italic())
                        .lineSpacing(lineSpacingValue)
                        .foregroundColor(colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

            case .codeBlock(_, let code):
                Text(code)
                    .font(.custom("SFMono-Regular", size: max(12, fontSize - 2)))
                    .foregroundColor(colors.textPrimary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

            case .image(let urlString, let alt):
                AsyncImageBlock(urlString: urlString, baseDirectoryURL: baseDirectoryURL, alt: alt, fontSize: fontSize, colors: colors)

            case .horizontalRule:
                Rectangle()
                    .fill(colors.border)
                    .frame(height: 1)

            case .table(let headers, let rows, let alignments):
                // Horizontal ScrollView so a table wider than the screen scrolls on its own,
                // rather than squeezing (or overflowing) the reading column (FAB-293).
                ScrollView(.horizontal, showsIndicators: false) {
                    Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 0) {
                        GridRow {
                            ForEach(Array(headers.enumerated()), id: \.offset) { col, cell in
                                Text(inlineText(cell))
                                    .font(bodyFont.bold())
                                    .foregroundColor(colors.textPrimary)
                                    .padding(8)
                                    .gridColumnAlignment(gridAlignment(for: alignments[safe: col] ?? .leading))
                            }
                        }
                        GridRow {
                            Rectangle()
                                .fill(colors.border)
                                .frame(height: 1)
                                .gridCellColumns(headers.count)
                        }
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                            GridRow {
                                ForEach(Array(row.enumerated()), id: \.offset) { col, cell in
                                    Text(inlineText(cell))
                                        .font(bodyFont)
                                        .foregroundColor(colors.textPrimary)
                                        .padding(8)
                                        .gridColumnAlignment(gridAlignment(for: alignments[safe: col] ?? .leading))
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.top, topSpacing(for: node, prevNode: prevNode, isListItem: isListItem, prevIsListItem: prevIsListItem))
    }

    private func gridAlignment(for alignment: MarkdownNode.TableAlignment) -> HorizontalAlignment {
        switch alignment {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }

    // MARK: Spacing

    private func topSpacing(for node: MarkdownNode, prevNode: MarkdownNode?, isListItem: Bool, prevIsListItem: Bool) -> CGFloat {
        guard prevNode != nil else { return 0 }
        switch node {
        case .heading: return 24
        case .horizontalRule: return 16
        case .unorderedListItem, .orderedListItem:
            return prevIsListItem ? 6 : 16
        default:
            return 16
        }
    }

    // MARK: Typography

    private var bodyFont: Font {
        fontFamily.isEmpty
            ? .system(size: fontSize)
            : .custom(fontFamily, size: fontSize)
    }

    private func headingFont(level: Int) -> Font {
        let t = VersoTypography.Reading(fontFamily: fontFamily)
        switch level {
        case 1: return t.h1
        case 2: return t.h2
        case 3: return t.h3
        default: return t.h4
        }
    }

    // MARK: Inline text rendering

    private func inlineText(_ inlines: [MarkdownNode.InlineNode]) -> AttributedString {
        inlines.reduce(AttributedString("")) { result, inline in
            result + textForInline(inline)
        }
    }

    private func textForInline(_ inline: MarkdownNode.InlineNode) -> AttributedString {
        switch inline {
        case .text(let s, _):
            return AttributedString(s)
        case .bold(let s, _):
            var a = AttributedString(s)
            a.swiftUI.font = bodyFont.bold()
            return a
        case .italic(let s, _):
            var a = AttributedString(s)
            a.swiftUI.font = bodyFont.italic()
            return a
        case .boldItalic(let s, _):
            var a = AttributedString(s)
            a.swiftUI.font = bodyFont.bold().italic()
            return a
        case .code(let s, _):
            var a = AttributedString(s)
            a.swiftUI.font = .custom("SFMono-Regular", size: max(12, fontSize - 2))
            a.swiftUI.foregroundColor = colors.accent
            return a
        case .link(let text, let url, _):
            var a = AttributedString(text)
            a.swiftUI.foregroundColor = colors.accent
            a.swiftUI.underlineStyle = .single
            if let resolved = URL(string: url) {
                a.link = resolved
            }
            return a
        case .highlight(let s, _):
            // Falls back to plain text outside a paragraph (headings, list items, table cells) —
            // SwiftUI `Text` can't paint a per-run background, so there's nothing meaningful to
            // style here; `HighlightableParagraphText` is what actually renders the highlight wash
            // for paragraphs, the only place FAB-54 targets.
            return AttributedString(s)
        }
    }
}

// MARK: - AsyncImageBlock

private struct AsyncImageBlock: View {
    let urlString: String
    var baseDirectoryURL: URL? = nil
    let alt: String
    let fontSize: CGFloat
    let colors: ThemeColors

    private var captionFontSize: CGFloat {
        max(11, fontSize - 4)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            imageContent
            if !trimmedCaption.isEmpty {
                Text(trimmedCaption)
                    .font(.system(size: captionFontSize))
                    .foregroundColor(colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel(trimmedCaption)
            }
        }
    }

    /// Resolves `urlString` to an absolute URL.
    /// Relative paths (starting with `./` or no scheme) are resolved against `baseDirectoryURL`
    /// so locally-saved images work as `file://` URLs.
    private var resolvedURL: URL? {
        if let base = baseDirectoryURL,
           !urlString.contains("://") {
            // Strip leading "./" if present before appending.
            let relative = urlString.hasPrefix("./") ? String(urlString.dropFirst(2)) : urlString
            return base.appendingPathComponent(relative)
        }
        return URL(string: urlString)
    }

    @ViewBuilder
    private var imageContent: some View {
        if let url = resolvedURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                case .failure:
                    placeholder
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 80)
                @unknown default:
                    placeholder
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .accessibilityLabel(trimmedCaption.isEmpty ? L10n.Reading.bodyImageAccessibilityLabel : trimmedCaption)
        } else {
            placeholder
        }
    }

    private var trimmedCaption: String {
        alt.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var placeholder: some View {
        Rectangle()
            .fill(colors.surface)
            .frame(maxWidth: .infinity, minHeight: 80)
            .overlay(
                Text(alt.isEmpty ? L10n.Reading.bodyImageAccessibilityLabel : alt)
                    .font(.system(size: max(12, captionFontSize)))
                    .foregroundColor(colors.textSecondary)
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        private let sampleMarkdown = """
        # The Quiet Revolution

        A paragraph with **bold**, _italic_, and ***bold italic*** text. Also `inline code` and a [link](https://example.com).

        ## Section Two

        > A blockquote with accent border.

        - First item
        - Second item
        - Third item

        1. One
        2. Two
        3. Three

        ```swift
        let x = 42
        print(x)
        ```

        ---

        ### H3 Subsection

        #### H4 Minor Head

        | Theme | Accent | Notes |
        | :--- | :---: | ---: |
        | Paper | Blue | Default |
        | Sepia | Amber | Warm |
        | Night | Blue | Dark |

        Final paragraph at the end.
        """

        var body: some View {
            ScrollView {
                MarkdownBodyView(
                    nodes: MarkdownParser.parse(sampleMarkdown),
                    fontFamily: "",
                    fontSize: 18,
                    lineSpacingValue: 9,
                    colors: ThemeManager().colors
                )
                .padding(24)
            }
            .background(Color(UIColor.systemBackground))
        }
    }
    return PreviewWrapper()
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
