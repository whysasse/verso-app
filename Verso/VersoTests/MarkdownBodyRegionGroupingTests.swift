import XCTest
@testable import Verso

/// FAB-303 step 4: `groupIntoRenderUnits` -- the pure, UIKit-free part of merging consecutive
/// paragraphs into one shared selectable region. Everything downstream of it (the actual
/// `UITextView` merging, spacing, TTS wash) needs a real device to verify; this function is the
/// one piece of this step that doesn't. See `MarkdownBodyView.swift`.
final class MarkdownBodyRegionGroupingTests: XCTestCase {

    func testConsecutiveParagraphsGroupIntoOneRegion() throws {
        let nodes = MarkdownParser.parse("""
        First paragraph.

        Second paragraph.

        Third paragraph.
        """)
        let units = groupIntoRenderUnits(nodes)

        XCTAssertEqual(units.count, 1)
        guard case .paragraphRegion(let paragraphs) = units[0] else {
            return XCTFail("expected a single paragraph region")
        }
        XCTAssertEqual(paragraphs.count, 3)
        XCTAssertEqual(paragraphs.map(\.nodeIndex), [0, 1, 2])
    }

    func testHeadingBreaksTheGroupIntoTwoRegions() throws {
        let nodes = MarkdownParser.parse("""
        First paragraph.

        ## A heading

        Second paragraph.
        """)
        let units = groupIntoRenderUnits(nodes)

        XCTAssertEqual(units.count, 3)
        guard case .paragraphRegion(let firstRegion) = units[0] else { return XCTFail("expected a leading region") }
        XCTAssertEqual(firstRegion.count, 1)

        guard case .single(let headingIndex, let headingNode) = units[1] else { return XCTFail("expected the heading as a singleton unit") }
        XCTAssertEqual(headingIndex, 1)
        guard case .heading = headingNode else { return XCTFail("expected a heading node") }

        guard case .paragraphRegion(let secondRegion) = units[2] else { return XCTFail("expected a trailing region") }
        XCTAssertEqual(secondRegion.count, 1)
        XCTAssertEqual(secondRegion[0].nodeIndex, 2)
    }

    func testEveryNonParagraphTypeBreaksTheGroup() throws {
        let nodes = MarkdownParser.parse("""
        A paragraph.

        - a list item

        > a quote

        ```
        code
        ```

        ---

        Another paragraph.
        """)
        let units = groupIntoRenderUnits(nodes)

        // paragraph, list item, blockquote, code block, rule, paragraph -- each of the four
        // non-paragraph types ends the region it follows and starts a fresh one after.
        XCTAssertEqual(units.count, 6)
        guard case .paragraphRegion = units[0] else { return XCTFail("expected leading paragraph region") }
        guard case .single(_, .unorderedListItem) = units[1] else { return XCTFail("expected list item") }
        guard case .single(_, .blockquote) = units[2] else { return XCTFail("expected blockquote") }
        guard case .single(_, .codeBlock) = units[3] else { return XCTFail("expected code block") }
        guard case .single(_, .horizontalRule) = units[4] else { return XCTFail("expected horizontal rule") }
        guard case .paragraphRegion = units[5] else { return XCTFail("expected trailing paragraph region") }
    }

    func testALoneParagraphBetweenTwoNonParagraphsIsItsOwnRegionOfOne() throws {
        let nodes = MarkdownParser.parse("""
        ## Heading one

        A single paragraph.

        ## Heading two
        """)
        let units = groupIntoRenderUnits(nodes)

        XCTAssertEqual(units.count, 3)
        guard case .paragraphRegion(let paragraphs) = units[1] else { return XCTFail("expected a paragraph region in the middle") }
        XCTAssertEqual(paragraphs.count, 1)
    }

    func testNoParagraphsProducesNoRegions() throws {
        let nodes = MarkdownParser.parse("""
        ## Just a heading

        ---
        """)
        let units = groupIntoRenderUnits(nodes)

        XCTAssertEqual(units.count, 2)
        for unit in units {
            if case .paragraphRegion = unit {
                XCTFail("expected no paragraph regions")
            }
        }
    }

    func testEmptyNodeListProducesNoUnits() throws {
        XCTAssertTrue(groupIntoRenderUnits([]).isEmpty)
    }
}
