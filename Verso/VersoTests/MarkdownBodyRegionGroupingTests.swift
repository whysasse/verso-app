import XCTest
@testable import Verso

/// FAB-303 step 4 (originally paragraphs only) and its headings/lists/blockquotes follow-up:
/// `groupIntoRenderUnits` -- the pure, UIKit-free part of merging consecutive "text blocks" into
/// one shared selectable region. Everything downstream of it (the actual `UITextView` merging,
/// spacing, fonts, TTS wash) needs a real device to verify; this function is the one piece of this
/// work that doesn't. See `MarkdownBodyView.swift`.
final class MarkdownBodyRegionGroupingTests: XCTestCase {

    func testConsecutiveParagraphsGroupIntoOneRegion() throws {
        let nodes = MarkdownParser.parse("""
        First paragraph.

        Second paragraph.

        Third paragraph.
        """)
        let units = groupIntoRenderUnits(nodes)

        XCTAssertEqual(units.count, 1)
        guard case .textRegion(let blocks) = units[0] else {
            return XCTFail("expected a single text region")
        }
        XCTAssertEqual(blocks.count, 3)
        XCTAssertEqual(blocks.map(\.nodeIndex), [0, 1, 2])
        for block in blocks {
            guard case .paragraph = block.kind else { return XCTFail("expected every block to be a paragraph") }
        }
    }

    func testAHeadingMergesIntoTheSameRegionAsAnAdjacentParagraph() throws {
        let nodes = MarkdownParser.parse("""
        ## A heading

        A paragraph right after it.
        """)
        let units = groupIntoRenderUnits(nodes)

        XCTAssertEqual(units.count, 1)
        guard case .textRegion(let blocks) = units[0] else {
            return XCTFail("expected the heading and paragraph to share one region")
        }
        XCTAssertEqual(blocks.count, 2)
        guard case .heading(let level) = blocks[0].kind else { return XCTFail("expected a heading first") }
        XCTAssertEqual(level, 2)
        guard case .paragraph = blocks[1].kind else { return XCTFail("expected a paragraph second") }
    }

    func testAListRunMergesIntoTheSameRegionAsAnAdjacentBlockquote() throws {
        let nodes = MarkdownParser.parse("""
        - First item
        - Second item

        > A quote right after the list
        """)
        let units = groupIntoRenderUnits(nodes)

        XCTAssertEqual(units.count, 1)
        guard case .textRegion(let blocks) = units[0] else {
            return XCTFail("expected the list and blockquote to share one region")
        }
        XCTAssertEqual(blocks.count, 3)
        guard case .unorderedListItem = blocks[0].kind else { return XCTFail("expected an unordered list item first") }
        guard case .unorderedListItem = blocks[1].kind else { return XCTFail("expected an unordered list item second") }
        guard case .blockquote = blocks[2].kind else { return XCTFail("expected a blockquote third") }
    }

    func testAnOrderedListItemCarriesItsOwnIndex() throws {
        let nodes = MarkdownParser.parse("""
        1. One
        2. Two
        """)
        let units = groupIntoRenderUnits(nodes)

        guard case .textRegion(let blocks) = units[0] else { return XCTFail("expected one region") }
        guard case .orderedListItem(let firstIndex) = blocks[0].kind else { return XCTFail("expected an ordered list item first") }
        XCTAssertEqual(firstIndex, 1)
        guard case .orderedListItem(let secondIndex) = blocks[1].kind else { return XCTFail("expected an ordered list item second") }
        XCTAssertEqual(secondIndex, 2)
    }

    func testEveryNonTextBlockTypeStillBreaksTheGroup() throws {
        let nodes = MarkdownParser.parse("""
        A paragraph.

        ```
        code
        ```

        Another paragraph.

        ---

        A final paragraph.
        """)
        let units = groupIntoRenderUnits(nodes)

        // paragraph, code block, paragraph, rule, paragraph -- image/codeBlock/table/rule are the
        // only four things that still break a region; everything else (paragraph, heading, list
        // item, blockquote) merges into whichever region it's adjacent to.
        XCTAssertEqual(units.count, 5)
        guard case .textRegion = units[0] else { return XCTFail("expected leading region") }
        guard case .single(_, .codeBlock) = units[1] else { return XCTFail("expected code block") }
        guard case .textRegion = units[2] else { return XCTFail("expected middle region") }
        guard case .single(_, .horizontalRule) = units[3] else { return XCTFail("expected horizontal rule") }
        guard case .textRegion = units[4] else { return XCTFail("expected trailing region") }
    }

    func testATableStillBreaksTheGroup() throws {
        let nodes = MarkdownParser.parse("""
        A paragraph.

        | A | B |
        | --- | --- |
        | 1 | 2 |

        Another paragraph.
        """)
        let units = groupIntoRenderUnits(nodes)

        XCTAssertEqual(units.count, 3)
        guard case .textRegion = units[0] else { return XCTFail("expected leading region") }
        guard case .single(_, .table) = units[1] else { return XCTFail("expected table") }
        guard case .textRegion = units[2] else { return XCTFail("expected trailing region") }
    }

    func testAnImageStillBreaksTheGroup() throws {
        let nodes = MarkdownParser.parse("""
        A paragraph.

        ![alt](image.jpg)

        Another paragraph.
        """)
        let units = groupIntoRenderUnits(nodes)

        XCTAssertEqual(units.count, 3)
        guard case .textRegion = units[0] else { return XCTFail("expected leading region") }
        guard case .single(_, .image) = units[1] else { return XCTFail("expected image") }
        guard case .textRegion = units[2] else { return XCTFail("expected trailing region") }
    }

    func testEntireMixedDocumentMergesIntoOneRegionWhenNothingBreaksIt() throws {
        let nodes = MarkdownParser.parse("""
        # Title

        An opening paragraph.

        ## Section

        - A bullet
        - Another bullet

        1. Step one
        2. Step two

        > A closing thought.
        """)
        let units = groupIntoRenderUnits(nodes)

        XCTAssertEqual(units.count, 1)
        guard case .textRegion(let blocks) = units[0] else { return XCTFail("expected one region") }
        XCTAssertEqual(blocks.count, 8)
    }

    func testNoTextBlocksProducesNoRegions() throws {
        let nodes = MarkdownParser.parse("""
        ```
        code only
        ```

        ---
        """)
        let units = groupIntoRenderUnits(nodes)

        XCTAssertEqual(units.count, 2)
        for unit in units {
            if case .textRegion = unit {
                XCTFail("expected no text regions")
            }
        }
    }

    func testEmptyNodeListProducesNoUnits() throws {
        XCTAssertTrue(groupIntoRenderUnits([]).isEmpty)
    }

    // MARK: - regionBlockSpacing

    func testRegionBlockSpacingHasNoSpaceWhenNothingPrecedes() {
        XCTAssertEqual(regionBlockSpacing(for: .paragraph, hasPrevious: false, previousIsListItem: false), 0)
        XCTAssertEqual(regionBlockSpacing(for: .heading(level: 1), hasPrevious: false, previousIsListItem: false), 0)
    }

    func testRegionBlockSpacingPutsTwentyFourPointsBeforeAHeading() {
        XCTAssertEqual(regionBlockSpacing(for: .heading(level: 2), hasPrevious: true, previousIsListItem: false), 24)
        // Even right after a list item -- a heading always gets its own 24pt, no list-sibling case.
        XCTAssertEqual(regionBlockSpacing(for: .heading(level: 2), hasPrevious: true, previousIsListItem: true), 24)
    }

    func testRegionBlockSpacingPutsSixPointsBetweenSiblingListItems() {
        XCTAssertEqual(regionBlockSpacing(for: .unorderedListItem, hasPrevious: true, previousIsListItem: true), 6)
        XCTAssertEqual(regionBlockSpacing(for: .orderedListItem(index: 2), hasPrevious: true, previousIsListItem: true), 6)
    }

    func testRegionBlockSpacingPutsSixteenPointsBeforeAListItemNotFollowingAnotherOne() {
        XCTAssertEqual(regionBlockSpacing(for: .unorderedListItem, hasPrevious: true, previousIsListItem: false), 16)
    }

    func testRegionBlockSpacingDefaultsToSixteenPoints() {
        XCTAssertEqual(regionBlockSpacing(for: .paragraph, hasPrevious: true, previousIsListItem: false), 16)
        XCTAssertEqual(regionBlockSpacing(for: .blockquote, hasPrevious: true, previousIsListItem: false), 16)
    }
}
