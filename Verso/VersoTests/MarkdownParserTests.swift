import XCTest
@testable import Verso

/// FAB-293: GFM pipe tables. `MarkdownNode`/`MarkdownParser` previously had no concept of a
/// table at all -- pipe rows fell through to the paragraph accumulator and got joined with
/// spaces into one run-on line.
final class MarkdownParserTests: XCTestCase {

    // MARK: - Helpers

    private func cellText(_ inlines: [MarkdownNode.InlineNode]) -> String {
        inlines.map(\.plainText).joined()
    }

    private func onlyTable(in markdown: String) throws -> (headers: [[MarkdownNode.InlineNode]], rows: [[[MarkdownNode.InlineNode]]], alignments: [MarkdownNode.TableAlignment]) {
        let nodes = MarkdownParser.parse(markdown)
        guard case .table(let headers, let rows, let alignments) = nodes.first(where: {
            if case .table = $0 { return true }
            return false
        }) else {
            XCTFail("expected a .table node in \(nodes)")
            return ([], [], [])
        }
        return (headers, rows, alignments)
    }

    // MARK: - Basic table

    func testBasicThreeColumnTableParsesHeaderAndRows() throws {
        let markdown = """
        | Name | Role | Years |
        |---|---|---|
        | Ada | Engineer | 12 |
        | Grace | Admiral | 44 |
        """
        let table = try onlyTable(in: markdown)

        XCTAssertEqual(table.headers.map(cellText), ["Name", "Role", "Years"])
        XCTAssertEqual(table.rows.map { $0.map(cellText) }, [
            ["Ada", "Engineer", "12"],
            ["Grace", "Admiral", "44"],
        ])
    }

    func testTableIsTheOnlyNodeAndSurroundingParagraphsSurvive() throws {
        let markdown = """
        Before the table.

        | A | B |
        |---|---|
        | 1 | 2 |

        After the table.
        """
        let nodes = MarkdownParser.parse(markdown)

        XCTAssertEqual(nodes.count, 3)
        guard case .paragraph(let before, _) = nodes[0] else { return XCTFail("expected leading paragraph") }
        XCTAssertEqual(cellText(before), "Before the table.")
        guard case .table = nodes[1] else { return XCTFail("expected table") }
        guard case .paragraph(let after, _) = nodes[2] else { return XCTFail("expected trailing paragraph") }
        XCTAssertEqual(cellText(after), "After the table.")
    }

    // MARK: - Alignment

    func testAlignmentColonsProduceCorrectPerColumnAlignment() throws {
        let markdown = """
        | Left | Center | Right |
        | :--- | :---: | ---: |
        | a | b | c |
        """
        let table = try onlyTable(in: markdown)

        XCTAssertEqual(table.alignments, [.leading, .center, .trailing])
    }

    func testDelimiterRowWithoutColonsDefaultsToLeadingAlignment() throws {
        let markdown = """
        | A | B |
        | --- | --- |
        | 1 | 2 |
        """
        let table = try onlyTable(in: markdown)

        XCTAssertEqual(table.alignments, [.leading, .leading])
    }

    // MARK: - Ragged rows

    func testShortRowIsPaddedToHeaderColumnCount() throws {
        let markdown = """
        | A | B | C |
        |---|---|---|
        | 1 | 2 |
        """
        let table = try onlyTable(in: markdown)

        XCTAssertEqual(table.rows.count, 1)
        XCTAssertEqual(table.rows[0].map(cellText), ["1", "2", ""])
    }

    func testLongRowIsTruncatedToHeaderColumnCount() throws {
        let markdown = """
        | A | B |
        |---|---|
        | 1 | 2 | 3 | 4 |
        """
        let table = try onlyTable(in: markdown)

        XCTAssertEqual(table.rows.count, 1)
        XCTAssertEqual(table.rows[0].map(cellText), ["1", "2"])
    }

    // MARK: - Escaped pipe

    func testEscapedPipeInsideACellIsNotTreatedAsASeparator() throws {
        let markdown = """
        | A | B |
        |---|---|
        | x \\| y | z |
        """
        let table = try onlyTable(in: markdown)

        XCTAssertEqual(table.rows.count, 1)
        XCTAssertEqual(table.rows[0].map(cellText), ["x | y", "z"])
    }

    // MARK: - False-positive guard (regression)

    func testPipeLineWithNoDelimiterRowStaysAParagraph() throws {
        let markdown = "The meeting ran from 2 | 3pm and covered topics | budgets."
        let nodes = MarkdownParser.parse(markdown)

        XCTAssertEqual(nodes.count, 1)
        guard case .paragraph(let inlines, _) = nodes[0] else { return XCTFail("expected a plain paragraph, not a table") }
        XCTAssertEqual(cellText(inlines), markdown)
    }

    func testTableFollowedByOrdinaryPipeParagraphKeepsTheLatterAsAParagraph() throws {
        let markdown = """
        | A | B |
        |---|---|
        | 1 | 2 |

        Not a table, just a sentence with a | in it.
        """
        let nodes = MarkdownParser.parse(markdown)

        XCTAssertEqual(nodes.count, 2)
        guard case .table = nodes[0] else { return XCTFail("expected table first") }
        guard case .paragraph(let inlines, _) = nodes[1] else { return XCTFail("expected trailing paragraph") }
        XCTAssertTrue(cellText(inlines).contains("Not a table"))
    }

    // MARK: - plainText

    func testTablePlainTextJoinsAllCellsWithASpace() throws {
        let markdown = """
        | A | B |
        |---|---|
        | 1 | 2 |
        """
        let nodes = MarkdownParser.parse(markdown)
        guard case .table = nodes.first else { return XCTFail("expected table") }
        XCTAssertEqual(nodes[0].plainText, "A B 1 2")
    }

    // MARK: - Highlight markers (FAB-54)

    func testHighlightMarkerParsesAsHighlightInlineNode() throws {
        let nodes = MarkdownParser.parse("Some ==highlighted text== in a sentence.")

        guard case .paragraph(let inlines, _) = nodes[0] else { return XCTFail("expected paragraph") }
        let highlights = inlines.compactMap { inline -> String? in
            if case .highlight(let s) = inline { return s }
            return nil
        }
        XCTAssertEqual(highlights, ["highlighted text"])
        XCTAssertEqual(cellText(inlines), "Some highlighted text in a sentence.")
    }

    func testMultipleHighlightMarkersInOneParagraphParseInOrder() throws {
        let nodes = MarkdownParser.parse("==First== normal ==second== more.")

        guard case .paragraph(let inlines, _) = nodes[0] else { return XCTFail("expected paragraph") }
        let highlights = inlines.compactMap { inline -> String? in
            if case .highlight(let s) = inline { return s }
            return nil
        }
        XCTAssertEqual(highlights, ["First", "second"])
    }

    func testParagraphRawTextPreservesOriginalSourceLines() throws {
        let markdown = """
        Line one of the paragraph
        line two of the paragraph.

        A second paragraph.
        """
        let nodes = MarkdownParser.parse(markdown)

        guard case .paragraph(_, let firstSource) = nodes[0] else { return XCTFail("expected paragraph") }
        XCTAssertEqual(firstSource.rawText, "Line one of the paragraph\nline two of the paragraph.")
        XCTAssertEqual(firstSource.lineRange, 0...1)
        XCTAssertEqual(firstSource.contentOffset, 0)

        guard case .paragraph(_, let secondSource) = nodes[1] else { return XCTFail("expected paragraph") }
        XCTAssertEqual(secondSource.rawText, "A second paragraph.")
        XCTAssertEqual(secondSource.lineRange, 3...3)
        XCTAssertEqual(secondSource.contentOffset, 0)
    }

    // MARK: - BlockSource: line ranges and contentOffset (FAB-303 step 1)

    func testHeadingSourceLineRangeAndContentOffset() throws {
        let nodes = MarkdownParser.parse("### A heading")

        guard case .heading(_, _, let source) = nodes[0] else { return XCTFail("expected heading") }
        XCTAssertEqual(source.lineRange, 0...0)
        XCTAssertEqual(source.rawText, "### A heading")
        XCTAssertEqual(source.contentOffset, 4) // "### " -- level 3 + 1
    }

    func testHeadingContentOffsetScalesWithLevel() throws {
        for level in 1...4 {
            let prefix = String(repeating: "#", count: level)
            let nodes = MarkdownParser.parse("\(prefix) Title")
            guard case .heading(let parsedLevel, _, let source) = nodes[0] else {
                return XCTFail("expected heading at level \(level)")
            }
            XCTAssertEqual(parsedLevel, level)
            XCTAssertEqual(source.contentOffset, level + 1, "level \(level)")
        }
    }

    func testBlockquoteSourceLineRangeAndContentOffset() throws {
        let nodes = MarkdownParser.parse("> A quoted line")

        guard case .blockquote(_, let source) = nodes[0] else { return XCTFail("expected blockquote") }
        XCTAssertEqual(source.lineRange, 0...0)
        XCTAssertEqual(source.rawText, "> A quoted line")
        XCTAssertEqual(source.contentOffset, 2) // "> "
    }

    func testUnorderedListItemContentOffsetForEachMarker() throws {
        for marker in ["-", "*", "+"] {
            let nodes = MarkdownParser.parse("\(marker) An item")
            guard case .unorderedListItem(_, let source) = nodes[0] else {
                return XCTFail("expected unordered list item for marker \(marker)")
            }
            XCTAssertEqual(source.contentOffset, 2, "marker \(marker)") // "- " / "* " / "+ "
        }
    }

    func testOrderedListItemContentOffsetGrowsWithDigitCount() throws {
        let nodes = MarkdownParser.parse("""
        1. First
        10. Tenth
        """)

        guard case .orderedListItem(_, _, let firstSource) = nodes[0] else { return XCTFail("expected item 1") }
        XCTAssertEqual(firstSource.lineRange, 0...0)
        XCTAssertEqual(firstSource.contentOffset, 3) // "1. "

        guard case .orderedListItem(_, _, let tenthSource) = nodes[1] else { return XCTFail("expected item 10") }
        XCTAssertEqual(tenthSource.lineRange, 1...1)
        XCTAssertEqual(tenthSource.contentOffset, 4) // "10. " -- two-digit index widens the prefix
    }
}
