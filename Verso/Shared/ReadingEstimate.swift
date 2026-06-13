import Foundation

/// Single source of truth for reading-time estimation.
///
/// The word count is derived from the **article's own content**, so the estimate
/// reflects the language the article is written in — not the app's UI locale.
/// See `docs/LOCALIZATION.md` §3.
enum ReadingEstimate {
    /// Average adult silent reading speed. Documented MVP constant (`docs/LOCALIZATION.md` §3).
    /// Centralized here so iOS (and, later, the Share Extension and Web) share one value.
    static let wordsPerMinute = 220

    /// Estimated minutes to read `text`, rounded up (`⌈wordCount ÷ WPM⌉`).
    /// Returns `nil` for empty/whitespace-only text so callers can hide the label.
    static func minutes(for text: String) -> Int? {
        let wordCount = text.split { $0.isWhitespace || $0.isNewline }.count
        guard wordCount > 0 else { return nil }
        let minutes = (Double(wordCount) / Double(wordsPerMinute)).rounded(.up)
        return max(1, Int(minutes))
    }
}
