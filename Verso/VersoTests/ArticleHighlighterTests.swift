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

    // MARK: - FAB-303 step 5: crossParagraphHighlightRanges

    /// Builds a `BlockSource` the way `MarkdownParser.flushParagraph` would for a single-line,
    /// no-leading/trailing-whitespace paragraph -- `contentOffset` is `0` and `rawText` is the
    /// content verbatim, which keeps these tests' expected offsets easy to read by hand.
    private func paragraphSource(_ rawText: String, lineRange: ClosedRange<Int> = 0...0) -> MarkdownNode.BlockSource {
        MarkdownNode.BlockSource(lineRange: lineRange, rawText: rawText, contentOffset: 0)
    }

    func testCrossParagraphHighlightRangesSpansTailAndHead() {
        let paragraphs = [
            paragraphSource("First paragraph here."),
            paragraphSource("Second paragraph here."),
        ]
        // Selection: "here." (offset 16) through the end of paragraph 0; "Second" (offset 0..6) at
        // the start of paragraph 1.
        let ranges = ArticleHighlighter.crossParagraphHighlightRanges(
            fromParagraphIndex: 0, rawStart: 16,
            toParagraphIndex: 1, rawEnd: 6,
            paragraphs: paragraphs
        )
        XCTAssertEqual(ranges?.count, 2)
        XCTAssertEqual(ranges?[0].paragraphIndex, 0)
        XCTAssertEqual(ranges?[0].rawRange, 16..<21) // "here." through the paragraph's own content end (21 chars total)
        XCTAssertEqual(ranges?[1].paragraphIndex, 1)
        XCTAssertEqual(ranges?[1].rawRange, 0..<6) // "Second" from the paragraph's own content start
    }

    func testCrossParagraphHighlightRangesWrapsEveryMiddleParagraphInFull() {
        let paragraphs = [
            paragraphSource("First."),
            paragraphSource("Middle one."),
            paragraphSource("Middle two."),
            paragraphSource("Last."),
        ]
        let ranges = ArticleHighlighter.crossParagraphHighlightRanges(
            fromParagraphIndex: 0, rawStart: 0,
            toParagraphIndex: 3, rawEnd: 5,
            paragraphs: paragraphs
        )
        XCTAssertEqual(ranges?.count, 4)
        XCTAssertEqual(ranges?[0].rawRange, 0..<6)   // all of "First."
        XCTAssertEqual(ranges?[1].rawRange, 0..<11)  // all of "Middle one."
        XCTAssertEqual(ranges?[2].rawRange, 0..<11)  // all of "Middle two."
        XCTAssertEqual(ranges?[3].rawRange, 0..<5)   // "Last." up to rawEnd
    }

    func testCrossParagraphHighlightRangesDeclinesWhenAnEndParagraphHasNothingToWrap() {
        let paragraphs = [paragraphSource("First."), paragraphSource("Last.")]
        // rawEnd: 0 makes the last paragraph's range 0..<0 -- empty, nothing safe to wrap there --
        // so the whole batch declines rather than writing a partial highlight.
        let ranges = ArticleHighlighter.crossParagraphHighlightRanges(
            fromParagraphIndex: 0, rawStart: 0,
            toParagraphIndex: 1, rawEnd: 0,
            paragraphs: paragraphs
        )
        XCTAssertNil(ranges)
    }

    func testCrossParagraphHighlightRangesTrimsTrailingWhitespaceFromParagraphContentEnd() {
        // A trailing space after "here." shouldn't be swept into the wrap when this paragraph is
        // the tail-wrapped first paragraph of a cross-paragraph selection.
        let paragraphs = [
            paragraphSource("Text here. "), // "Text here." is 10 chars, plus one trailing space
            paragraphSource("More text."),
        ]
        let ranges = ArticleHighlighter.crossParagraphHighlightRanges(
            fromParagraphIndex: 0, rawStart: 5,
            toParagraphIndex: 1, rawEnd: 4,
            paragraphs: paragraphs
        )
        XCTAssertEqual(ranges?[0].rawRange, 5..<10) // stops at "here." not the trailing space
    }

    func testCrossParagraphHighlightRangesDeclinesWhenParagraphIndicesAreOutOfOrder() {
        let paragraphs = [paragraphSource("A."), paragraphSource("B.")]
        let ranges = ArticleHighlighter.crossParagraphHighlightRanges(
            fromParagraphIndex: 1, rawStart: 0,
            toParagraphIndex: 0, rawEnd: 1,
            paragraphs: paragraphs
        )
        XCTAssertNil(ranges)
    }

    func testCrossParagraphHighlightRangesDeclinesWhenAParagraphIndexIsOutOfRange() {
        let paragraphs = [paragraphSource("A."), paragraphSource("B.")]
        let ranges = ArticleHighlighter.crossParagraphHighlightRanges(
            fromParagraphIndex: 0, rawStart: 0,
            toParagraphIndex: 5, rawEnd: 1,
            paragraphs: paragraphs
        )
        XCTAssertNil(ranges)
    }

    // MARK: - FAB-303 step 5: leadingHighlightIndex / trailingHighlightIndex

    func testLeadingHighlightIndexIsNilWithoutALeadingHighlight() {
        XCTAssertNil(ArticleHighlighter.leadingHighlightIndex(in: "Plain text, no highlight."))
    }

    func testLeadingHighlightIndexFindsAHighlightAtTheVeryStart() {
        XCTAssertEqual(ArticleHighlighter.leadingHighlightIndex(in: "==Leading== then plain text."), 0)
    }

    func testLeadingHighlightIndexIsNilWhenTheHighlightIsOnlyInTheMiddle() {
        XCTAssertNil(ArticleHighlighter.leadingHighlightIndex(in: "Plain, then ==highlighted== text."))
    }

    func testTrailingHighlightIndexIsNilWithoutATrailingHighlight() {
        XCTAssertNil(ArticleHighlighter.trailingHighlightIndex(in: "Plain text, no highlight."))
    }

    func testTrailingHighlightIndexFindsAHighlightAtTheVeryEnd() {
        XCTAssertEqual(ArticleHighlighter.trailingHighlightIndex(in: "Plain text then ==trailing=="), 0)
    }

    func testTrailingHighlightIndexIsNilWhenTrailingContentFollowsTheHighlight() {
        // Trailing punctuation after the marker means the highlight isn't the *last* inline node --
        // this checks node position, not "highlight is near the end" loosely.
        XCTAssertNil(ArticleHighlighter.trailingHighlightIndex(in: "Plain text then ==trailing==."))
    }

    func testTrailingHighlightIndexReportsTheHighlightsOwnIndexWhenSeveralPrecedeIt() {
        XCTAssertEqual(ArticleHighlighter.trailingHighlightIndex(in: "==one== and ==two== and ==three=="), 2)
    }

    func testAParagraphThatIsEntirelyOneHighlightIsBothLeadingAndTrailing() {
        XCTAssertEqual(ArticleHighlighter.leadingHighlightIndex(in: "==the whole thing=="), 0)
        XCTAssertEqual(ArticleHighlighter.trailingHighlightIndex(in: "==the whole thing=="), 0)
    }

    // MARK: - FAB-303 step 5: chainedHighlightPieces

    func testChainedHighlightPiecesReturnsJustTheTappedPieceWhenNothingChains() {
        let paragraphs = [
            paragraphSource("A ==lone== highlight."),
            paragraphSource("An unrelated paragraph."),
        ]
        let pieces = ArticleHighlighter.chainedHighlightPieces(startingAt: (0, 0), in: paragraphs)
        XCTAssertEqual(pieces.map(\.paragraphIndex), [0])
        XCTAssertEqual(pieces.map(\.highlightIndex), [0])
    }

    func testChainedHighlightPiecesLinksTwoParagraphsRegardlessOfWhichPieceWasTapped() {
        let paragraphs = [
            paragraphSource("Some text, then ==the tail=="),
            paragraphSource("==the head== continues here."),
        ]
        let fromTail = ArticleHighlighter.chainedHighlightPieces(startingAt: (0, 0), in: paragraphs)
        let fromHead = ArticleHighlighter.chainedHighlightPieces(startingAt: (1, 0), in: paragraphs)

        let expected: [(paragraphIndex: Int, highlightIndex: Int)] = [(0, 0), (1, 0)]
        XCTAssertEqual(fromTail.map(\.paragraphIndex), expected.map(\.paragraphIndex))
        XCTAssertEqual(fromTail.map(\.highlightIndex), expected.map(\.highlightIndex))
        XCTAssertEqual(fromHead.map(\.paragraphIndex), expected.map(\.paragraphIndex))
        XCTAssertEqual(fromHead.map(\.highlightIndex), expected.map(\.highlightIndex))
    }

    func testChainedHighlightPiecesWalksThroughThreeLinkedParagraphs() {
        let paragraphs = [
            paragraphSource("Start of it, ==piece one=="),
            paragraphSource("==piece two=="),
            paragraphSource("==piece three== and then more."),
        ]
        let pieces = ArticleHighlighter.chainedHighlightPieces(startingAt: (1, 0), in: paragraphs)
        XCTAssertEqual(pieces.map(\.paragraphIndex), [0, 1, 2])
        XCTAssertEqual(pieces.map(\.highlightIndex), [0, 0, 0])
    }

    func testChainedHighlightPiecesDoesNotChainWhenTheNeighborsHighlightIsntAtTheTouchingEdge() {
        let paragraphs = [
            paragraphSource("Some text, then ==the tail=="),
            // Paragraph 1 has a highlight, but it's not the *leading* node -- there's plain text
            // before it -- so it can't be the continuation of paragraph 0's trailing highlight.
            paragraphSource("Unrelated lead-in, then ==a separate highlight==."),
        ]
        let pieces = ArticleHighlighter.chainedHighlightPieces(startingAt: (0, 0), in: paragraphs)
        XCTAssertEqual(pieces.map(\.paragraphIndex), [0])
    }
}
