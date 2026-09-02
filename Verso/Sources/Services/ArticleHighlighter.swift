import Foundation

/// Pure raw-text wrapping/unwrapping logic behind reading-view highlights, kept UIKit-free and
/// directly unit-testable. Highlights are stored as `==text==` inline markers in the article's
/// Markdown body -- the Obsidian/CommonMark-extension convention: plain, portable, human-readable
/// in any editor, matching Verso's file-first philosophy (docs/OBSIDIAN_INTEGRATION.md) -- rather
/// than frontmatter offsets, which would silently misplace on any edit made outside Verso.
///
/// FAB-303 step 2: `HighlightableRegionText` tags every rendered run with the exact raw offset
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

    // MARK: - FAB-303: merge with an existing highlight

    /// Wraps `range` fresh, first absorbing (and stripping the markers of) every existing
    /// `==...==` highlight that overlaps or is directly adjacent to it -- so extending a selection
    /// into, out of, or across an existing highlight produces one bigger highlight instead of a
    /// broken or nested one. Identical to `addHighlight(atRawOffsetRange:in:)` when nothing touches
    /// `range` at all -- this supersedes that function as the same-block call in
    /// `HighlightableUITextView.applyAddHighlight`, not a separate branch alongside it.
    ///
    /// Why this was needed, not just "nice to have": the old decline-on-touch check only ever
    /// looked at a selection's two *boundary* positions. A selection that starts and ends in
    /// ordinary text but fully *encloses* an existing highlight in the middle never touched either
    /// boundary, so it fell through to a plain wrap -- nesting a fresh `==...==` around text that
    /// already contained one, corrupting the file. Expanding to cover every touched highlight
    /// (however it's touched -- at an edge or fully enclosed) before wrapping closes that path,
    /// since a merge has to find all of them anyway.
    ///
    /// Works transitively: if the expanded range now touches *another* highlight it didn't
    /// originally reach, that one gets absorbed too, so a chain of mutually-adjacent highlights
    /// merges in one action. Returns `nil` if `range` doesn't fall within `rawText`.
    static func addOrMergeHighlight(atRawOffsetRange range: Range<Int>, in rawText: String) -> String? {
        let highlightRanges = existingHighlightRanges(in: rawText)

        var unionStart = range.lowerBound
        var unionEnd = range.upperBound
        var expanded = true
        while expanded {
            expanded = false
            for highlightRange in highlightRanges where rangesTouch(highlightRange, unionStart..<unionEnd) {
                if highlightRange.lowerBound < unionStart {
                    unionStart = highlightRange.lowerBound
                    expanded = true
                }
                if highlightRange.upperBound > unionEnd {
                    unionEnd = highlightRange.upperBound
                    expanded = true
                }
            }
        }

        let nsRange = NSRange(location: unionStart, length: unionEnd - unionStart)
        guard let sliceRange = Range(nsRange, in: rawText) else { return nil }
        let content = String(rawText[sliceRange])
        let stripped = content.replacingOccurrences(of: markerPattern, with: "$1", options: .regularExpression)
        return rawText.replacingCharacters(in: sliceRange, with: "==\(stripped)==")
    }

    /// Whether any existing `==...==` marker in `rawText` overlaps or is directly adjacent to
    /// `range`. A same-block write always merges instead (`addOrMergeHighlight`, above), but a
    /// cross-block write can't -- actually merging across a block break needs finding every touched
    /// piece across blocks and re-verifying each one's boundaries after stripping, the same order of
    /// complexity as merging itself, which is why it's deliberately not attempted here (see
    /// `docs/BACKLOG.md`'s FAB-303 checklist). So a cross-block write uses this to decline instead
    /// of silently wrapping over -- and corrupting -- an existing highlight it doesn't know how to
    /// merge with.
    static func rangeTouchesExistingHighlight(_ range: Range<Int>, in rawText: String) -> Bool {
        existingHighlightRanges(in: rawText).contains { rangesTouch($0, range) }
    }

    /// Every existing `==...==` match in `rawText` as a raw UTF-16 range, delimiters included --
    /// the same coordinate space as `.versoFullSourceRange` and everything else in this file.
    private static func existingHighlightRanges(in rawText: String) -> [Range<Int>] {
        guard let regex = try? NSRegularExpression(pattern: markerPattern) else { return [] }
        let nsRange = NSRange(rawText.startIndex..., in: rawText)
        return regex.matches(in: rawText, range: nsRange).compactMap { match in
            guard match.range.location != NSNotFound else { return nil }
            return match.range.location..<(match.range.location + match.range.length)
        }
    }

    /// Whether `a` and `b` overlap *or* touch with zero gap between them (one ending exactly where
    /// the other begins) -- both count as "adjacent" per Fabio's original decision (2026-09-01):
    /// "Selection overlapping or directly adjacent to an existing highlight" merges.
    private static func rangesTouch(_ a: Range<Int>, _ b: Range<Int>) -> Bool {
        a.lowerBound <= b.upperBound && b.lowerBound <= a.upperBound
    }

    // MARK: - FAB-303 step 5: cross-block write

    /// A selection whose two ends land in *different* blocks of the same region can't be wrapped
    /// with one `addHighlight(atRawOffsetRange:in:)` call -- one `==...==` pair can never span the
    /// blank line between two blocks (see `docs/BACKLOG.md`'s FAB-303 "constraint everything else
    /// follows from"). This computes one wrap range per block instead: the *tail* of the first
    /// block (from `rawStart` to its own content end), *all* of every block strictly between, and
    /// the *head* of the last block (from its own content start to `rawEnd`). `rawStart`/`rawEnd`
    /// are expected to already be resolved, safe raw offsets -- e.g. from `HighlightableUITextView`'s
    /// existing snap-outward logic -- this function only decides *how many pairs* and *where each
    /// one goes*, not whether a boundary is safe to wrap at all. Pure and UIKit-free, unlike the
    /// view code that will call it, so it's directly testable. Block-kind-agnostic -- works the same
    /// whether the blocks touched are paragraphs, headings, list items, or blockquotes, since it
    /// only ever reads a block's `BlockSource`, not its kind.
    ///
    /// Returns `nil` if the block indices are out of order or out of range, or if any computed
    /// range ends up empty or inverted (nothing safe to wrap in that block) -- the caller declines
    /// the whole action rather than writing a partial set of highlights.
    static func crossBlockHighlightRanges(
        fromBlockIndex startIndex: Int,
        rawStart: Int,
        toBlockIndex endIndex: Int,
        rawEnd: Int,
        blocks: [MarkdownNode.BlockSource]
    ) -> [(blockIndex: Int, rawRange: Range<Int>)]? {
        guard startIndex < endIndex,
              blocks.indices.contains(startIndex),
              blocks.indices.contains(endIndex) else {
            return nil
        }

        var result: [(blockIndex: Int, rawRange: Range<Int>)] = []
        for blockIndex in startIndex...endIndex {
            let range: Range<Int>
            if blockIndex == startIndex {
                range = rawStart..<fullContentRange(of: blocks[blockIndex]).upperBound
            } else if blockIndex == endIndex {
                range = fullContentRange(of: blocks[blockIndex]).lowerBound..<rawEnd
            } else {
                range = fullContentRange(of: blocks[blockIndex])
            }
            guard range.lowerBound < range.upperBound else { return nil }
            result.append((blockIndex, range))
        }
        return result
    }

    /// This block's own content bounds (UTF-16, same coordinate space as `.versoSourceOffset`/
    /// `.versoFullSourceRange`) -- `rawText` with any leading syntax (a heading's `"## "`, a list
    /// item's `"- "`/`"1. "`, a blockquote's `"> "`) *and* leading/trailing whitespace excluded. The
    /// leading bound is just `contentOffset` -- already exactly this for every block type, per
    /// `MarkdownParser.flushParagraph`/`singleLineSource` (FAB-303 step 1 made this generic across
    /// all five "text block" kinds specifically so callers like this one wouldn't need to special-
    /// case any of them). The trailing bound mirrors that same file's leading-trim computation, just
    /// from the other end, so it's provably the same trim rule rather than a fresh assumption.
    private static func fullContentRange(of source: MarkdownNode.BlockSource) -> Range<Int> {
        let trailingTrim = source.rawText.reversed().prefix(while: { $0.isWhitespace }).count
        return source.contentOffset..<(source.rawText.utf16.count - trailingTrim)
    }

    // MARK: - FAB-303 step 5: chained (cross-block) remove

    /// Whether `source`'s block *first* inline node is a highlight -- i.e. its content begins
    /// directly with `==` -- and if so, that highlight's 0-based index within this one block
    /// (always `0`, since it's the first node `MarkdownParser.parseInlines` encounters). `nil` when
    /// the block doesn't start with a highlight, including when it has no content at all.
    ///
    /// Re-parses just `source`'s own content (via `fullContentRange`, above -- syntax prefix and
    /// surrounding whitespace excluded) rather than requiring the caller to already have the parsed
    /// `[InlineNode]` -- cheap for one block's worth of text, and only called on a Remove Highlight
    /// tap, not on every render.
    ///
    /// FAB-303 headings/lists/blockquotes follow-up: originally this whitespace-trimmed `rawText`
    /// directly, which is only correct for a paragraph -- a heading/list-item/blockquote's `rawText`
    /// carries its own syntax prefix (`"## "`, `"- "`, `"> "`), which whitespace-trimming doesn't
    /// remove, so re-parsing it would have folded that literal prefix into a leading `.text` node
    /// and made "does this block start with a highlight" wrong for every non-paragraph block. Fixed
    /// by slicing on `contentOffset` (via `fullContentRange`) instead, which already excludes any
    /// such prefix for every block kind.
    static func leadingHighlightIndex(in source: MarkdownNode.BlockSource) -> Int? {
        guard case .highlight = blockContentInlines(of: source).first else { return nil }
        return 0
    }

    /// Same as `leadingHighlightIndex`, for whether the block's *last* inline node is a highlight --
    /// its index is however many highlights precede it, which (since it's the last node) is just
    /// "this block's total highlight count, minus one."
    static func trailingHighlightIndex(in source: MarkdownNode.BlockSource) -> Int? {
        let nodes = blockContentInlines(of: source)
        guard case .highlight = nodes.last else { return nil }
        let highlightCount = nodes.reduce(into: 0) { count, node in
            if case .highlight = node { count += 1 }
        }
        return highlightCount - 1
    }

    private static func blockContentInlines(of source: MarkdownNode.BlockSource) -> [MarkdownNode.InlineNode] {
        let contentRange = fullContentRange(of: source)
        let nsRange = NSRange(location: contentRange.lowerBound, length: contentRange.count)
        guard let range = Range(nsRange, in: source.rawText) else { return [] }
        return MarkdownParser.parseInlines(String(source.rawText[range]))
    }

    /// From the one highlight piece the user actually tapped (`start`), walks outward through
    /// `blocks` in both directions while each neighbor genuinely chains onto it: the current piece
    /// is its own block's leading (or trailing) highlight, *and* the block right before (or after)
    /// it has a highlight ending (or starting) exactly at its own edge. When both hold, nothing but
    /// the block break itself sits between the two pieces -- from the reader's point of view it's
    /// one continuous highlight, not two, so Remove Highlight has to take out every linked piece in
    /// one action (Fabio's decision, 2026-09-01), regardless of which piece was tapped. Works the
    /// same across a mix of block kinds -- a highlight can chain from a paragraph's tail into a list
    /// item's head, for instance -- since it only reads each block's `BlockSource`. Returns every
    /// linked `(blockIndex, highlightIndex)` piece, in block order; when nothing chains, that's just
    /// `[start]`.
    static func chainedHighlightPieces(
        startingAt start: (blockIndex: Int, highlightIndex: Int),
        in blocks: [MarkdownNode.BlockSource]
    ) -> [(blockIndex: Int, highlightIndex: Int)] {
        guard blocks.indices.contains(start.blockIndex) else { return [start] }
        var pieces: [(blockIndex: Int, highlightIndex: Int)] = [start]

        var blockIndex = start.blockIndex
        var highlightIndex = start.highlightIndex
        while leadingHighlightIndex(in: blocks[blockIndex]) == highlightIndex,
              blockIndex > 0 {
            guard let previousIndex = trailingHighlightIndex(in: blocks[blockIndex - 1]) else { break }
            blockIndex -= 1
            highlightIndex = previousIndex
            pieces.insert((blockIndex, highlightIndex), at: 0)
        }

        blockIndex = start.blockIndex
        highlightIndex = start.highlightIndex
        while trailingHighlightIndex(in: blocks[blockIndex]) == highlightIndex,
              blockIndex + 1 < blocks.count {
            guard let nextIndex = leadingHighlightIndex(in: blocks[blockIndex + 1]) else { break }
            blockIndex += 1
            highlightIndex = nextIndex
            pieces.append((blockIndex, highlightIndex))
        }

        return pieces
    }
}
