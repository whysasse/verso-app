import Foundation

/// Pure raw-text wrapping/unwrapping logic behind reading-view highlights, kept UIKit-free and
/// directly unit-testable. Highlights are stored as `==text==` inline markers in the article's
/// Markdown body -- the Obsidian/CommonMark-extension convention: plain, portable, human-readable
/// in any editor, matching Verso's file-first philosophy (docs/OBSIDIAN_INTEGRATION.md) -- rather
/// than frontmatter offsets, which would silently misplace on any edit made outside Verso.
///
/// FAB-303 step 2: `HighlightableParagraphText` tags every rendered run with the exact raw offset
/// it came from (`.versoSourceOffset`), so a selection converts to a raw position directly --
/// no searching. (FAB-54 originally re-found the *rendered* selected text inside the raw source
/// with a whitespace-tolerant regex, then re-parsed the result to check it landed somewhere sane;
/// both are gone now that the mapping is tracked instead of guessed at afterward.)
enum ArticleHighlighter {

    /// Wraps the exact raw offset range `rawOffsetRange` (UTF-16, from `.versoSourceOffset`-tagged
    /// runs) with `==...==`. No searching, no re-parse check: the caller only calls this once it
    /// has confirmed both ends of the selection landed inside the *same* tagged inline run, which
    /// makes the wrap provably safe -- there's nothing but plain content between two offsets
    /// inside one homogeneous run, so it can't split a delimiter or land mid-syntax.
    ///
    /// A selection spanning *two different* runs (e.g. starting in plain text, ending inside
    /// `**bold**`) still has to decline -- slicing raw text between two offsets there would split
    /// the `**` delimiters and corrupt the file. That's FAB-303 step 3's job ("snap outward" to
    /// the run's edge instead of splitting it); this function assumes the caller has already ruled
    /// the cross-run case out. Returns `nil` if `rawOffsetRange` doesn't fall within `rawText`.
    static func addHighlight(atRawOffsetRange rawOffsetRange: Range<Int>, in rawText: String) -> String? {
        let nsRange = NSRange(location: rawOffsetRange.lowerBound, length: rawOffsetRange.count)
        guard let range = Range(nsRange, in: rawText) else { return nil }
        let matched = rawText[range]
        return rawText.replacingCharacters(in: range, with: "==\(matched)==")
    }

    /// Removes the `index`-th (0-based, left-to-right source order) `==...==` span in `rawText`,
    /// unwrapping its content. `index` is expected to come from the same left-to-right order
    /// `MarkdownParser.parseInlines` encounters `.highlight` nodes in, so it lines up with whichever
    /// rendered highlight the user selected on screen -- an index-based lookup sidesteps any
    /// position mapping, since there's no ambiguity about *which* existing highlight was selected.
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

    // MARK: - FAB-303 step 5: cross-paragraph write

    /// A selection whose two ends land in *different* paragraphs of the same region can't be
    /// wrapped with one `addHighlight(atRawOffsetRange:in:)` call -- one `==...==` pair can never
    /// span the blank line between two paragraphs (see `docs/BACKLOG.md`'s FAB-303 "constraint
    /// everything else follows from"). This computes one wrap range per paragraph instead: the
    /// *tail* of the first paragraph (from `rawStart` to its own content end), *all* of every
    /// paragraph strictly between, and the *head* of the last paragraph (from its own content start
    /// to `rawEnd`). `rawStart`/`rawEnd` are expected to already be resolved, safe raw offsets --
    /// e.g. from `HighlightableUITextView`'s existing snap-outward logic -- this function only
    /// decides *how many pairs* and *where each one goes*, not whether a boundary is safe to wrap at
    /// all. Pure and UIKit-free, unlike the view code that will call it, so it's directly testable.
    ///
    /// Returns `nil` if the paragraph indices are out of order or out of range, or if any computed
    /// range ends up empty or inverted (nothing safe to wrap in that paragraph) -- the caller
    /// declines the whole action rather than writing a partial set of highlights.
    static func crossParagraphHighlightRanges(
        fromParagraphIndex startIndex: Int,
        rawStart: Int,
        toParagraphIndex endIndex: Int,
        rawEnd: Int,
        paragraphs: [MarkdownNode.BlockSource]
    ) -> [(paragraphIndex: Int, rawRange: Range<Int>)]? {
        guard startIndex < endIndex,
              paragraphs.indices.contains(startIndex),
              paragraphs.indices.contains(endIndex) else {
            return nil
        }

        var result: [(paragraphIndex: Int, rawRange: Range<Int>)] = []
        for paragraphIndex in startIndex...endIndex {
            let range: Range<Int>
            if paragraphIndex == startIndex {
                range = rawStart..<fullContentRange(of: paragraphs[paragraphIndex]).upperBound
            } else if paragraphIndex == endIndex {
                range = fullContentRange(of: paragraphs[paragraphIndex]).lowerBound..<rawEnd
            } else {
                range = fullContentRange(of: paragraphs[paragraphIndex])
            }
            guard range.lowerBound < range.upperBound else { return nil }
            result.append((paragraphIndex, range))
        }
        return result
    }

    /// This paragraph's own content bounds (UTF-16, same coordinate space as `.versoSourceOffset`/
    /// `.versoFullSourceRange`) -- `rawText` with leading/trailing whitespace excluded. The leading
    /// bound is just `contentOffset` (already exactly this, per `MarkdownParser.flushParagraph`);
    /// the trailing bound mirrors that same file's leading-trim computation, just from the other
    /// end, so it's provably the same trim rule rather than a fresh assumption.
    private static func fullContentRange(of source: MarkdownNode.BlockSource) -> Range<Int> {
        let trailingTrim = source.rawText.reversed().prefix(while: { $0.isWhitespace }).count
        return source.contentOffset..<(source.rawText.utf16.count - trailingTrim)
    }

    // MARK: - FAB-303 step 5: chained (cross-paragraph) remove

    /// Whether paragraph `rawText`'s *first* inline node is a highlight -- i.e. its content begins
    /// directly with `==` -- and if so, that highlight's 0-based index within this one paragraph
    /// (always `0`, since it's the first node `MarkdownParser.parseInlines` encounters). `nil` when
    /// the paragraph doesn't start with a highlight, including when it has no content at all.
    ///
    /// Re-parses `rawText` (trimmed the same way `MarkdownParser.flushParagraph` trims it before
    /// parsing in the first place) rather than requiring the caller to already have the parsed
    /// `[InlineNode]` -- cheap for one paragraph's worth of text, and only called on a Remove
    /// Highlight tap, not on every render.
    static func leadingHighlightIndex(in rawText: String) -> Int? {
        guard case .highlight = trimmedInlines(of: rawText).first else { return nil }
        return 0
    }

    /// Same as `leadingHighlightIndex`, for whether the paragraph's *last* inline node is a
    /// highlight -- its index is however many highlights precede it, which (since it's the last
    /// node) is just "this paragraph's total highlight count, minus one."
    static func trailingHighlightIndex(in rawText: String) -> Int? {
        let nodes = trimmedInlines(of: rawText)
        guard case .highlight = nodes.last else { return nil }
        let highlightCount = nodes.reduce(into: 0) { count, node in
            if case .highlight = node { count += 1 }
        }
        return highlightCount - 1
    }

    private static func trimmedInlines(of rawText: String) -> [MarkdownNode.InlineNode] {
        MarkdownParser.parseInlines(rawText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    /// From the one highlight piece the user actually tapped (`start`), walks outward through
    /// `paragraphs` in both directions while each neighbor genuinely chains onto it: the current
    /// piece is its own paragraph's leading (or trailing) highlight, *and* the paragraph right
    /// before (or after) it has a highlight ending (or starting) exactly at its own edge. When both
    /// hold, nothing but the paragraph break itself sits between the two pieces -- from the reader's
    /// point of view it's one continuous highlight, not two, so Remove Highlight has to take out
    /// every linked piece in one action (Fabio's decision, 2026-09-01), regardless of which piece
    /// was tapped. Returns every linked `(paragraphIndex, highlightIndex)` piece, in paragraph
    /// order; when nothing chains, that's just `[start]`.
    static func chainedHighlightPieces(
        startingAt start: (paragraphIndex: Int, highlightIndex: Int),
        in paragraphs: [MarkdownNode.BlockSource]
    ) -> [(paragraphIndex: Int, highlightIndex: Int)] {
        guard paragraphs.indices.contains(start.paragraphIndex) else { return [start] }
        var pieces: [(paragraphIndex: Int, highlightIndex: Int)] = [start]

        var paragraphIndex = start.paragraphIndex
        var highlightIndex = start.highlightIndex
        while leadingHighlightIndex(in: paragraphs[paragraphIndex].rawText) == highlightIndex,
              paragraphIndex > 0 {
            guard let previousIndex = trailingHighlightIndex(in: paragraphs[paragraphIndex - 1].rawText) else { break }
            paragraphIndex -= 1
            highlightIndex = previousIndex
            pieces.insert((paragraphIndex, highlightIndex), at: 0)
        }

        paragraphIndex = start.paragraphIndex
        highlightIndex = start.highlightIndex
        while trailingHighlightIndex(in: paragraphs[paragraphIndex].rawText) == highlightIndex,
              paragraphIndex + 1 < paragraphs.count {
            guard let nextIndex = leadingHighlightIndex(in: paragraphs[paragraphIndex + 1].rawText) else { break }
            paragraphIndex += 1
            highlightIndex = nextIndex
            pieces.append((paragraphIndex, highlightIndex))
        }

        return pieces
    }
}
