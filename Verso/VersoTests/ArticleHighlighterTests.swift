import XCTest
@testable import Verso

/// FAB-303 step 2: the raw-text wrapping/unwrapping logic behind reading-view highlights.
/// `addHighlight` now takes an exact raw offset range (from `HighlightableParagraphText`'s
/// `.versoSourceOffset`-tagged runs) rather than searching for rendered text in the raw source --
/// see `ArticleHighlighter.swift` for why that search (and its re-parse safety check) is gone.
final class ArticleHighlighterTests: XCTestCase {

    // MARK: - addHighlight

    func testAddHighlightWrapsTheExactOffsetRange() {
        let rawText = "The quick brown fox jumps."
        // "quick brown" starts right after "The " (4 chars) and is 11 chars long.
        let result = ArticleHighlighter.addHighlight(atRawOffsetRange: 4..<15, in: rawText)
        XCTAssertEqual(result, "The ==quick brown== fox jumps.")
    }

    func testAddHighlightWrapsAtTheStartOfTheText() {
        let result = ArticleHighlighter.addHighlight(atRawOffsetRange: 0..<3, in: "The quick fox.")
        XCTAssertEqual(result, "==The== quick fox.")
    }

    func testAddHighlightWrapsTheEntireText() {
        let rawText = "All of it."
        let result = ArticleHighlighter.addHighlight(atRawOffsetRange: 0..<rawText.utf16.count, in: rawText)
        XCTAssertEqual(result, "==All of it.==")
    }

    func testAddHighlightDeclinesWhenRangeExceedsTheTextLength() {
        let result = ArticleHighlighter.addHighlight(atRawOffsetRange: 10..<100, in: "Too short.")
        XCTAssertNil(result)
    }

    func testAddHighlightDeclinesOnAnEmptyRange() {
        let result = ArticleHighlighter.addHighlight(atRawOffsetRange: 4..<4, in: "The quick fox.")
        // An empty range wraps nothing meaningful -- `NSRange(length: 0)` is technically valid, so
        // this documents the actual (harmless but pointless) behavior rather than asserting a nil
        // this function has no reason to produce.
        XCTAssertEqual(result, "The ====quick fox.")
    }

    func testAddHighlightHandlesMultiByteCharactersByUTF16Offset() {
        // "café" -- "é" is a single UTF-16 unit (unlike, say, an emoji), so plain character
        // counting and UTF-16 counting agree here; this pins that assumption down explicitly
        // rather than leaving it implicit.
        let rawText = "café today"
        XCTAssertEqual(rawText.utf16.count, 10)
        let result = ArticleHighlighter.addHighlight(atRawOffsetRange: 0..<4, in: rawText)
        XCTAssertEqual(result, "==café== today")
    }

    // MARK: - removeHighlight

    func testRemoveHighlightUnwrapsTheGivenIndex() {
        let result = ArticleHighlighter.removeHighlight(
            at: 1,
            in: "A ==first== and ==second== highlight."
        )
        XCTAssertEqual(result, "A ==first== and second highlight.")
    }

    func testRemoveHighlightAtIndexZeroUnwrapsTheFirstOccurrence() {
        let result = ArticleHighlighter.removeHighlight(
            at: 0,
            in: "A ==first== and ==second== highlight."
        )
        XCTAssertEqual(result, "A first and ==second== highlight.")
    }

    func testRemoveHighlightReturnsNilForOutOfRangeIndex() {
        XCTAssertNil(ArticleHighlighter.removeHighlight(at: 3, in: "A ==only== one."))
    }

    func testRemoveHighlightReturnsNilWhenThereAreNoHighlights() {
        XCTAssertNil(ArticleHighlighter.removeHighlight(at: 0, in: "No highlights here."))
    }

    // MARK: - Round trip

    func testAddThenRemoveRestoresTheOriginalText() {
        let original = "The quick brown fox jumps."
        guard let highlighted = ArticleHighlighter.addHighlight(atRawOffsetRange: 4..<15, in: original) else {
            return XCTFail("expected addHighlight to succeed")
        }
        XCTAssertEqual(highlighted, "The ==quick brown== fox jumps.")
        let restored = ArticleHighlighter.removeHighlight(at: 0, in: highlighted)
        XCTAssertEqual(restored, original)
    }
}
