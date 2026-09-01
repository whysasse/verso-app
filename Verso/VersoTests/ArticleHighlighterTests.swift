import XCTest
@testable import Verso

/// FAB-54: the raw-text matching/wrapping logic behind reading-view highlights. This is the
/// riskiest part of the feature (a rendered selection has to be re-located in the raw Markdown
/// source, which has syntax the rendered text doesn't), so it gets direct coverage independent of
/// any UIKit/SwiftUI plumbing. See `ArticleHighlighter.swift`.
final class ArticleHighlighterTests: XCTestCase {

    // MARK: - addHighlight

    func testAddHighlightWrapsLiteralMatch() {
        let result = ArticleHighlighter.addHighlight(
            selecting: "quick brown",
            in: "The quick brown fox jumps."
        )
        XCTAssertEqual(result, "The ==quick brown== fox jumps.")
    }

    func testAddHighlightIsWhitespaceTolerantAcrossALineWrap() {
        // The rendered selection ("quick brown", single space) has to still find its match even
        // though the raw source wrapped mid-phrase onto a second line.
        let result = ArticleHighlighter.addHighlight(
            selecting: "quick brown",
            in: "The quick\nbrown fox jumps."
        )
        XCTAssertEqual(result, "The ==quick\nbrown== fox jumps.")
    }

    func testAddHighlightDeclinesWhenSelectionCrossesABoldBoundary() {
        // Rendered plain text would read "quick brown" (bold markers stripped), but the raw source
        // has "**" sitting between them -- not a literal, unformatted run, so this must decline
        // rather than produce something like "The **quick=**= brown== fox." (nonsense output the
        // parser would never intend).
        let result = ArticleHighlighter.addHighlight(
            selecting: "quick brown",
            in: "The **quick** brown fox."
        )
        XCTAssertNil(result)
    }

    func testAddHighlightDeclinesWhenTextIsNotFound() {
        let result = ArticleHighlighter.addHighlight(
            selecting: "a phrase that is not in the source",
            in: "The quick brown fox jumps."
        )
        XCTAssertNil(result)
    }

    func testAddHighlightTargetsTheFirstOccurrenceWhenTextRepeats() {
        let result = ArticleHighlighter.addHighlight(
            selecting: "cat dog",
            in: "cat dog cat dog"
        )
        XCTAssertEqual(result, "==cat dog== cat dog")
    }

    func testAddHighlightIgnoresLeadingAndTrailingWhitespaceInSelection() {
        let result = ArticleHighlighter.addHighlight(
            selecting: "  quick brown  ",
            in: "The quick brown fox jumps."
        )
        XCTAssertEqual(result, "The ==quick brown== fox jumps.")
    }

    func testAddHighlightOnEmptySelectionDeclines() {
        XCTAssertNil(ArticleHighlighter.addHighlight(selecting: "   ", in: "The quick brown fox."))
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
        guard let highlighted = ArticleHighlighter.addHighlight(selecting: "quick brown", in: original) else {
            return XCTFail("expected addHighlight to succeed")
        }
        let restored = ArticleHighlighter.removeHighlight(at: 0, in: highlighted)
        XCTAssertEqual(restored, original)
    }
}
