import XCTest
@testable import Verso

/// Coverage for FAB-295's stable-filename scheme (`{articleStem}-01.jpg`, …) replacing the
/// previous random-UUID naming. The network download itself stays untested here, as before
/// this change — there's no existing mocking seam for `URLSession` in this target, and adding
/// one is out of scope for this fix.
final class ArticleMarkdownImageLocalizerTests: XCTestCase {

    private var tempDir: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("ArticleMarkdownImageLocalizerTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let tempDir {
            try? FileManager.default.removeItem(at: tempDir)
        }
        tempDir = nil
        try super.tearDownWithError()
    }

    // MARK: - truncatedFilenameStem

    func testStemUnderLimitIsUnchanged() {
        let stem = "2026-08-30 Article A Short Title"
        XCTAssertEqual(ArticleMarkdownImageLocalizer.truncatedFilenameStem(stem, maxLength: 80), stem)
    }

    func testStemAtExactLimitIsUnchanged() {
        let stem = String(repeating: "a", count: 80)
        XCTAssertEqual(ArticleMarkdownImageLocalizer.truncatedFilenameStem(stem, maxLength: 80), stem)
    }

    func testStemOverLimitIsTruncated() {
        let stem = String(repeating: "a", count: 120)
        let result = ArticleMarkdownImageLocalizer.truncatedFilenameStem(stem, maxLength: 80)
        XCTAssertEqual(result.count, 80)
        XCTAssertEqual(result, String(repeating: "a", count: 80))
    }

    // MARK: - uniqueMediaFilename

    func testReturnsPlainNameWhenNoCollision() {
        let name = ArticleMarkdownImageLocalizer.uniqueMediaFilename(base: "My Article-01", ext: "jpg", in: tempDir)
        XCTAssertEqual(name, "My Article-01.jpg")
    }

    func testAppendsLetterSuffixOnFirstCollision() throws {
        try Data().write(to: tempDir.appendingPathComponent("My Article-01.jpg"))
        let name = ArticleMarkdownImageLocalizer.uniqueMediaFilename(base: "My Article-01", ext: "jpg", in: tempDir)
        XCTAssertEqual(name, "My Article-01-b.jpg")
    }

    func testAppendsNextLetterWhenEarlierLettersAlsoTaken() throws {
        try Data().write(to: tempDir.appendingPathComponent("My Article-01.jpg"))
        try Data().write(to: tempDir.appendingPathComponent("My Article-01-b.jpg"))
        try Data().write(to: tempDir.appendingPathComponent("My Article-01-c.jpg"))
        let name = ArticleMarkdownImageLocalizer.uniqueMediaFilename(base: "My Article-01", ext: "jpg", in: tempDir)
        XCTAssertEqual(name, "My Article-01-d.jpg")
    }

    func testCollisionSuffixIsVisuallyDistinctFromDocumentOrderNumbering() throws {
        // Guards against a naming scheme where a collision suffix could be confused with the
        // "-01"/"-02" document-order numbering (e.g. both being digits).
        try Data().write(to: tempDir.appendingPathComponent("My Article-01.jpg"))
        let name = ArticleMarkdownImageLocalizer.uniqueMediaFilename(base: "My Article-01", ext: "jpg", in: tempDir)
        XCTAssertFalse(name.contains("-02"))
        XCTAssertTrue(name.contains("-b"))
    }
}
