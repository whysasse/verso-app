import Foundation

/// FAB-54: pure raw-text matching/wrapping logic behind reading-view highlights, kept UIKit-free
/// and directly unit-testable. Highlights are stored as `==text==` inline markers in the article's
/// Markdown body -- the Obsidian/CommonMark-extension convention: plain, portable, human-readable
/// in any editor, matching Verso's file-first philosophy (docs/OBSIDIAN_INTEGRATION.md) -- rather
/// than frontmatter offsets, which would silently misplace on any edit made outside Verso.
///
/// `MarkdownBodyView`'s `.paragraph` node carries the *raw* source text for exactly this purpose:
/// the text rendered on screen has Markdown syntax (`**`, `_`, backticks) stripped, so a selection
/// made against the rendered text can't be spliced back into the raw source by position alone --
/// it has to be re-located there.
enum ArticleHighlighter {

    /// Wraps the first literal, whitespace-tolerant occurrence of `selectedText` inside `rawText`
    /// with `==...==`. Returns `nil` when `selectedText` doesn't correspond to a clean, unformatted
    /// span of `rawText` -- most commonly because the selection crossed a bold/italic/code/link
    /// boundary, where the rendered plain text and the raw Markdown source diverge. Declining is
    /// intentional: better to no-op than to insert markers that land in the wrong place (verified
    /// by actually re-parsing the result, not by guessing at boundary rules -- see
    /// `highlightRoundTrips`).
    static func addHighlight(selecting selectedText: String, in rawText: String) -> String? {
        guard let range = literalRange(of: selectedText, in: rawText) else { return nil }
        let matched = String(rawText[range])
        let candidate = rawText.replacingCharacters(in: range, with: "==\(matched)==")
        return highlightRoundTrips(candidate: candidate, expectedContent: matched) ? candidate : nil
    }

    /// Removes the `index`-th (0-based, left-to-right source order) `==...==` span in `rawText`,
    /// unwrapping its content. `index` is expected to come from the same left-to-right order
    /// `MarkdownParser.parseInlines` encounters `.highlight` nodes in, so it lines up with whichever
    /// rendered highlight the user selected on screen -- an index-based lookup sidesteps the
    /// literal-text re-matching `addHighlight` needs, since there's no ambiguity about *which*
    /// existing highlight was selected.
    static func removeHighlight(at index: Int, in rawText: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: markerPattern) else { return nil }
        let nsRange = NSRange(rawText.startIndex..., in: rawText)
        let matches = regex.matches(in: rawText, range: nsRange)
        guard matches.indices.contains(index),
              let fullRange = Range(matches[index].range, in: rawText),
              let contentRange = Range(matches[index].range(at: 1), in: rawText) else {
            return nil
        }
        return rawText.replacingCharacters(in: fullRange, with: String(rawText[contentRange]))
    }

    /// The `==...==` marker regex, shared with `MarkdownParser.parseInlines` (`MarkdownBodyView.swift`)
    /// so both stay in lockstep -- `MarkdownParser.highlightMarkerPattern` is the single source of
    /// truth this points at, kept here (rather than the other way around) since `ArticleHighlighter`
    /// deliberately has no dependency in the other direction.
    private static var markerPattern: String { MarkdownParser.highlightMarkerPattern }

    /// Whitespace-tolerant literal search: `selectedText`'s own internal whitespace runs (including
    /// a line break, for the rare hand-wrapped paragraph -- see docs/DONE.md FAB-54) match any
    /// whitespace run in `rawText`, but every other character must match exactly. This is a literal
    /// search, not a fuzzy one -- it exists only to tolerate whitespace differences between the
    /// rendered (single-line, collapsed) text and the raw (possibly multi-line) source.
    private static func literalRange(of selectedText: String, in rawText: String) -> Range<String.Index>? {
        let trimmed = selectedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let tokens = trimmed.split(whereSeparator: { $0.isWhitespace })
        guard !tokens.isEmpty else { return nil }
        let pattern = tokens
            .map { NSRegularExpression.escapedPattern(for: String($0)) }
            .joined(separator: #"\s+"#)
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let nsRange = NSRange(rawText.startIndex..., in: rawText)
        guard let match = regex.firstMatch(in: rawText, range: nsRange),
              let range = Range(match.range, in: rawText) else {
            return nil
        }
        return range
    }

    /// Re-parses `candidate` and confirms the intended text actually became a standalone
    /// `.highlight` inline node with exactly `expectedContent`. This is the guard against the
    /// selection having crossed a formatting boundary: if it had, inserting `==...==` would parse
    /// into the wrong place (e.g. swallowed as literal `==...==` characters inside a surrounding
    /// `**bold**` span, since `.bold` doesn't recursively re-parse its own content) rather than
    /// becoming a real highlight -- checking the actual parser's output is more robust than trying
    /// to hand-enumerate every boundary case.
    ///
    /// Newlines are collapsed to spaces before checking: `candidate` is built from raw, possibly
    /// multi-line `rawText`, but `MarkdownParser.flushParagraph` always joins a paragraph's lines
    /// with a single space before real rendering ever sees it (`==(.+?)==`'s `.` doesn't cross a
    /// literal `\n` by default) -- so verifying against the un-collapsed candidate would reject a
    /// highlight that spans a source line-wrap even though it will render correctly once reopened.
    private static func highlightRoundTrips(candidate: String, expectedContent: String) -> Bool {
        let rendered = candidate.replacingOccurrences(of: "\n", with: " ")
        let renderedExpected = expectedContent.replacingOccurrences(of: "\n", with: " ")
        return MarkdownParser.parseInlines(rendered).contains {
            if case .highlight(let text) = $0 { return text == renderedExpected }
            return false
        }
    }
}
