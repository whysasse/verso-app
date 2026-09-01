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
}
