import XCTest
@testable import Verso

final class GoodLinksParserTests: XCTestCase {

    private var tempDir: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("GoodLinksParserTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let tempDir {
            try? FileManager.default.removeItem(at: tempDir)
        }
        tempDir = nil
        try super.tearDownWithError()
    }

    private func writeJSON(_ string: String, name: String = "export.json") throws -> URL {
        guard let data = string.data(using: .utf8) else {
            XCTFail("UTF-8 encode failed")
            fatalError()
        }
        let url = tempDir.appendingPathComponent(name)
        try data.write(to: url)
        return url
    }

    func testNativeTopLevelArrayParses() throws {
        let url = try writeJSON(
            """
            [
              {
                "url": "https://example.com/a",
                "title": "Article A",
                "tags": ["swift", "ios"],
                "addedAt": 1715376000.5,
                "starred": false,
                "summary": ""
              }
            ]
            """
        )
        let parser = GoodLinksParser()
        XCTAssertTrue(parser.canParse(url))
        let articles = try parser.parse(url)
        XCTAssertEqual(articles.count, 1)
        XCTAssertEqual(articles[0].title, "Article A")
        XCTAssertEqual(articles[0].url?.absoluteString, "https://example.com/a")
        XCTAssertEqual(articles[0].tags, ["swift", "ios"])
        XCTAssertEqual(articles[0].status, .unread)
        let expected = Date(timeIntervalSince1970: 1715376000.5)
        XCTAssertEqual(articles[0].dateAdded.timeIntervalSince1970, expected.timeIntervalSince1970, accuracy: 0.001)
    }

    func testNativeTopLevelArrayWithReadAtParsesAsRead() throws {
        let url = try writeJSON(
            """
            [
              {
                "url": "https://example.com/a",
                "title": "Article A",
                "tags": ["swift", "ios"],
                "addedAt": 1715376000.5,
                "readAt": 1715380000.0,
                "starred": false,
                "summary": ""
              }
            ]
            """
        )
        let parser = GoodLinksParser()
        XCTAssertTrue(parser.canParse(url))
        let articles = try parser.parse(url)
        XCTAssertEqual(articles.count, 1)
        XCTAssertEqual(articles[0].status, .read)
    }

    func testNativeBookmarksWrappedInItemsObject() throws {
        let url = try writeJSON(
            """
            {
              "items": [
                {
                  "url": "https://example.com/b",
                  "title": "Article B",
                  "tags": [],
                  "addedAt": 1700000000
                }
              ]
            }
            """
        )
        let parser = GoodLinksParser()
        XCTAssertTrue(parser.canParse(url))
        let articles = try parser.parse(url)
        XCTAssertEqual(articles.count, 1)
        XCTAssertEqual(articles[0].title, "Article B")
        XCTAssertEqual(articles[0].url?.absoluteString, "https://example.com/b")
    }

    func testLegacyItemsWithISO8601Dates() throws {
        let url = try writeJSON(
            """
            {
              "items": [
                {
                  "title": "Legacy",
                  "url": "https://example.com/legacy",
                  "tags": ["t1"],
                  "created_at": "2024-05-10T12:00:00.123Z",
                  "read_at": "2024-05-11T08:00:00Z"
                }
              ]
            }
            """
        )
        let parser = GoodLinksParser()
        XCTAssertTrue(parser.canParse(url))
        let articles = try parser.parse(url)
        XCTAssertEqual(articles.count, 1)
        XCTAssertEqual(articles[0].title, "Legacy")
        XCTAssertEqual(articles[0].status, .read)
        XCTAssertGreaterThan(articles[0].dateAdded.timeIntervalSince1970, 1_714_000_000)
    }

    func testMatterStyleArrayIsNotParsedAsGoodLinks() throws {
        let url = try writeJSON(
            """
            [
              {
                "content": { "title": "Matter", "url": "https://example.com/m" },
                "saved_at": "2024-01-01T00:00:00Z"
              }
            ]
            """,
            name: "matterish.json"
        )
        let parser = GoodLinksParser()
        XCTAssertFalse(parser.canParse(url))
    }

    func testEmptyArrayReturnsEmptyWithoutCrash() throws {
        let url = try writeJSON("[]")
        let parser = GoodLinksParser()
        // canParse returns false for an empty array (no rows to inspect)
        XCTAssertFalse(parser.canParse(url))
    }

    func testImportFormatDetectorSelectsGoodLinksForNativeExport() throws {
        let url = try writeJSON(
            """
            [{"url":"https://q.test/","title":"Q","tags":[],"addedAt":1.0}]
            """,
            name: "gl.json"
        )
        let parser = try ImportFormatDetector.parser(for: url)
        XCTAssertTrue(parser is GoodLinksParser)
    }
}
