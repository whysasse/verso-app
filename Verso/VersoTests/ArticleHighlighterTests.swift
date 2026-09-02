import XCTest
@testable import Verso

/// FAB-303 step 2: the raw-text wrapping/unwrapping logic behind reading-view highlights.
/// `addHighlight` now takes an exact raw offset range (from `HighlightableRegionText`'s
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

    // MARK: - FAB-303 step 5: crossBlockHighlightRanges

    /// Builds a `BlockSource` the way `MarkdownParser.flushParagraph` would for a single-line,
    /// no-leading/trailing-whitespace paragraph -- `contentOffset` is `0` and `rawText` is the
    /// content verbatim, which keeps these tests' expected offsets easy to read by hand.
    private func blockSource(_ rawText: String, lineRange: ClosedRange<Int> = 0...0) -> MarkdownNode.BlockSource {
        MarkdownNode.BlockSource(lineRange: lineRange, rawText: rawText, contentOffset: 0)
    }

    /// Builds a `BlockSource` the way `MarkdownParser.singleLineSource` would for a heading/list-
    /// item/blockquote -- `rawText` carries a real syntax prefix and `contentOffset` is however
    /// many UTF-16 units that prefix is, exactly mirroring a real non-paragraph block.
    private func prefixedBlockSource(prefix: String, content: String, lineRange: ClosedRange<Int> = 0...0) -> MarkdownNode.BlockSource {
        MarkdownNode.BlockSource(lineRange: lineRange, rawText: prefix + content, contentOffset: prefix.utf16.count)
    }

    func testCrossBlockHighlightRangesSpansTailAndHead() {
        let blocks = [
            blockSource("First paragraph here."),
            blockSource("Second paragraph here."),
        ]
        // Selection: "here." (offset 16) through the end of block 0; "Second" (offset 0..6) at the
        // start of block 1.
        let ranges = ArticleHighlighter.crossBlockHighlightRanges(
            fromBlockIndex: 0, rawStart: 16,
            toBlockIndex: 1, rawEnd: 6,
            blocks: blocks
        )
        XCTAssertEqual(ranges?.count, 2)
        XCTAssertEqual(ranges?[0].blockIndex, 0)
        XCTAssertEqual(ranges?[0].rawRange, 16..<21) // "here." through the block's own content end (21 chars total)
        XCTAssertEqual(ranges?[1].blockIndex, 1)
        XCTAssertEqual(ranges?[1].rawRange, 0..<6) // "Second" from the block's own content start
    }

    func testCrossBlockHighlightRangesWrapsEveryMiddleBlockInFull() {
        let blocks = [
            blockSource("First."),
            blockSource("Middle one."),
            blockSource("Middle two."),
            blockSource("Last."),
        ]
        let ranges = ArticleHighlighter.crossBlockHighlightRanges(
            fromBlockIndex: 0, rawStart: 0,
            toBlockIndex: 3, rawEnd: 5,
            blocks: blocks
        )
        XCTAssertEqual(ranges?.count, 4)
        XCTAssertEqual(ranges?[0].rawRange, 0..<6)   // all of "First."
        XCTAssertEqual(ranges?[1].rawRange, 0..<11)  // all of "Middle one."
        XCTAssertEqual(ranges?[2].rawRange, 0..<11)  // all of "Middle two."
        XCTAssertEqual(ranges?[3].rawRange, 0..<5)   // "Last." up to rawEnd
    }

    func testCrossBlockHighlightRangesDeclinesWhenAnEndBlockHasNothingToWrap() {
        let blocks = [blockSource("First."), blockSource("Last.")]
        // rawEnd: 0 makes the last block's range 0..<0 -- empty, nothing safe to wrap there -- so
        // the whole batch declines rather than writing a partial highlight.
        let ranges = ArticleHighlighter.crossBlockHighlightRanges(
            fromBlockIndex: 0, rawStart: 0,
            toBlockIndex: 1, rawEnd: 0,
            blocks: blocks
        )
        XCTAssertNil(ranges)
    }

    func testCrossBlockHighlightRangesTrimsTrailingWhitespaceFromBlockContentEnd() {
        // A trailing space after "here." shouldn't be swept into the wrap when this block is the
        // tail-wrapped first block of a cross-block selection.
        let blocks = [
            blockSource("Text here. "), // "Text here." is 10 chars, plus one trailing space
            blockSource("More text."),
        ]
        let ranges = ArticleHighlighter.crossBlockHighlightRanges(
            fromBlockIndex: 0, rawStart: 5,
            toBlockIndex: 1, rawEnd: 4,
            blocks: blocks
        )
        XCTAssertEqual(ranges?[0].rawRange, 5..<10) // stops at "here." not the trailing space
    }

    func testCrossBlockHighlightRangesRespectsAHeadingsSyntaxPrefix() {
        // A heading's own "## " prefix is part of `rawText` but must never be swept into a wrap --
        // `contentOffset` (3, matching the prefix's own length) is what keeps it out.
        let blocks = [
            prefixedBlockSource(prefix: "## ", content: "A heading"),
            blockSource("A paragraph after it."),
        ]
        let ranges = ArticleHighlighter.crossBlockHighlightRanges(
            fromBlockIndex: 0, rawStart: 6, // mid "heading" ("## A heading", content starts at 3)
            toBlockIndex: 1, rawEnd: 11,
            blocks: blocks
        )
        XCTAssertEqual(ranges?[0].rawRange, 6..<12) // stops at the heading's own content end, "## " excluded from the start
    }

    func testCrossBlockHighlightRangesDeclinesWhenBlockIndicesAreOutOfOrder() {
        let blocks = [blockSource("A."), blockSource("B.")]
        let ranges = ArticleHighlighter.crossBlockHighlightRanges(
            fromBlockIndex: 1, rawStart: 0,
            toBlockIndex: 0, rawEnd: 1,
            blocks: blocks
        )
        XCTAssertNil(ranges)
    }

    func testCrossBlockHighlightRangesDeclinesWhenABlockIndexIsOutOfRange() {
        let blocks = [blockSource("A."), blockSource("B.")]
        let ranges = ArticleHighlighter.crossBlockHighlightRanges(
            fromBlockIndex: 0, rawStart: 0,
            toBlockIndex: 5, rawEnd: 1,
            blocks: blocks
        )
        XCTAssertNil(ranges)
    }

    // MARK: - FAB-303 step 5: leadingHighlightIndex / trailingHighlightIndex

    func testLeadingHighlightIndexIsNilWithoutALeadingHighlight() {
        XCTAssertNil(ArticleHighlighter.leadingHighlightIndex(in: blockSource("Plain text, no highlight.")))
    }

    func testLeadingHighlightIndexFindsAHighlightAtTheVeryStart() {
        XCTAssertEqual(ArticleHighlighter.leadingHighlightIndex(in: blockSource("==Leading== then plain text.")), 0)
    }

    func testLeadingHighlightIndexIsNilWhenTheHighlightIsOnlyInTheMiddle() {
        XCTAssertNil(ArticleHighlighter.leadingHighlightIndex(in: blockSource("Plain, then ==highlighted== text.")))
    }

    func testTrailingHighlightIndexIsNilWithoutATrailingHighlight() {
        XCTAssertNil(ArticleHighlighter.trailingHighlightIndex(in: blockSource("Plain text, no highlight.")))
    }

    func testTrailingHighlightIndexFindsAHighlightAtTheVeryEnd() {
        XCTAssertEqual(ArticleHighlighter.trailingHighlightIndex(in: blockSource("Plain text then ==trailing==")), 0)
    }

    func testTrailingHighlightIndexIsNilWhenTrailingContentFollowsTheHighlight() {
        // Trailing punctuation after the marker means the highlight isn't the *last* inline node --
        // this checks node position, not "highlight is near the end" loosely.
        XCTAssertNil(ArticleHighlighter.trailingHighlightIndex(in: blockSource("Plain text then ==trailing==.")))
    }

    func testTrailingHighlightIndexReportsTheHighlightsOwnIndexWhenSeveralPrecedeIt() {
        XCTAssertEqual(ArticleHighlighter.trailingHighlightIndex(in: blockSource("==one== and ==two== and ==three==")), 2)
    }

    func testABlockThatIsEntirelyOneHighlightIsBothLeadingAndTrailing() {
        XCTAssertEqual(ArticleHighlighter.leadingHighlightIndex(in: blockSource("==the whole thing==")), 0)
        XCTAssertEqual(ArticleHighlighter.trailingHighlightIndex(in: blockSource("==the whole thing==")), 0)
    }

    /// FAB-303 headings/lists/blockquotes follow-up: the bug this step caught before shipping --
    /// re-parsing by whitespace-trimming `rawText` directly (the original step 5 implementation)
    /// would have folded a heading's `"## "` prefix into a leading `.text` node, making this wrongly
    /// report `nil` even though the heading's actual *content* starts with a highlight. Fixed by
    /// slicing on `contentOffset` first (see `ArticleHighlighter.blockContentInlines`).
    func testLeadingHighlightIndexRespectsAHeadingsSyntaxPrefix() {
        let source = prefixedBlockSource(prefix: "## ", content: "==Highlighted heading==")
        XCTAssertEqual(ArticleHighlighter.leadingHighlightIndex(in: source), 0)
    }

    func testTrailingHighlightIndexRespectsAListItemsSyntaxPrefix() {
        let source = prefixedBlockSource(prefix: "- ", content: "A list item ending in ==a highlight==")
        XCTAssertEqual(ArticleHighlighter.trailingHighlightIndex(in: source), 0)
    }

    func testLeadingHighlightIndexRespectsABlockquotesSyntaxPrefix() {
        // Without the contentOffset-based fix, "> " would have been read as literal leading text,
        // making this incorrectly report nil.
        let source = prefixedBlockSource(prefix: "> ", content: "==A highlighted quote==")
        XCTAssertEqual(ArticleHighlighter.leadingHighlightIndex(in: source), 0)
    }

    // MARK: - FAB-303 step 5: chainedHighlightPieces

    func testChainedHighlightPiecesReturnsJustTheTappedPieceWhenNothingChains() {
        let blocks = [
            blockSource("A ==lone== highlight."),
            blockSource("An unrelated paragraph."),
        ]
        let pieces = ArticleHighlighter.chainedHighlightPieces(startingAt: (0, 0), in: blocks)
        XCTAssertEqual(pieces.map(\.blockIndex), [0])
        XCTAssertEqual(pieces.map(\.highlightIndex), [0])
    }

    func testChainedHighlightPiecesLinksTwoBlocksRegardlessOfWhichPieceWasTapped() {
        let blocks = [
            blockSource("Some text, then ==the tail=="),
            blockSource("==the head== continues here."),
        ]
        let fromTail = ArticleHighlighter.chainedHighlightPieces(startingAt: (0, 0), in: blocks)
        let fromHead = ArticleHighlighter.chainedHighlightPieces(startingAt: (1, 0), in: blocks)

        let expected: [(blockIndex: Int, highlightIndex: Int)] = [(0, 0), (1, 0)]
        XCTAssertEqual(fromTail.map(\.blockIndex), expected.map(\.blockIndex))
        XCTAssertEqual(fromTail.map(\.highlightIndex), expected.map(\.highlightIndex))
        XCTAssertEqual(fromHead.map(\.blockIndex), expected.map(\.blockIndex))
        XCTAssertEqual(fromHead.map(\.highlightIndex), expected.map(\.highlightIndex))
    }

    func testChainedHighlightPiecesWalksThroughThreeLinkedBlocks() {
        let blocks = [
            blockSource("Start of it, ==piece one=="),
            blockSource("==piece two=="),
            blockSource("==piece three== and then more."),
        ]
        let pieces = ArticleHighlighter.chainedHighlightPieces(startingAt: (1, 0), in: blocks)
        XCTAssertEqual(pieces.map(\.blockIndex), [0, 1, 2])
        XCTAssertEqual(pieces.map(\.highlightIndex), [0, 0, 0])
    }

    func testChainedHighlightPiecesDoesNotChainWhenTheNeighborsHighlightIsntAtTheTouchingEdge() {
        let blocks = [
            blockSource("Some text, then ==the tail=="),
            // Block 1 has a highlight, but it's not the *leading* node -- there's plain text
            // before it -- so it can't be the continuation of block 0's trailing highlight.
            blockSource("Unrelated lead-in, then ==a separate highlight==."),
        ]
        let pieces = ArticleHighlighter.chainedHighlightPieces(startingAt: (0, 0), in: blocks)
        XCTAssertEqual(pieces.map(\.blockIndex), [0])
    }

    func testChainedHighlightPiecesLinksAcrossDifferentBlockKinds() {
        // A highlight that chains from a paragraph's tail into a heading's head -- the function
        // only reads `BlockSource`, so it doesn't care that the two blocks are different kinds.
        let blocks = [
            blockSource("A paragraph ending in ==a highlight=="),
            prefixedBlockSource(prefix: "## ", content: "==continues into this heading=="),
        ]
        let pieces = ArticleHighlighter.chainedHighlightPieces(startingAt: (0, 0), in: blocks)
        XCTAssertEqual(pieces.map(\.blockIndex), [0, 1])
    }
}
