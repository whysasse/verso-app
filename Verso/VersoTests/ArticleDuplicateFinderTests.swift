import XCTest
@testable import Verso

/// FAB-296: `scanDirectory` used to pass `.skipsSubdirectoryDescendants`, so an article
/// living in any subfolder besides the library root or `Archive/` was invisible to the
/// duplicate check. See docs/DONE.md FAB-296.
final class ArticleDuplicateFinderTests: XCTestCase {

    private var tempDir: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("ArticleDuplicateFinderTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let tempDir {
            try? FileManager.default.removeItem(at: tempDir)
        }
        tempDir = nil
        try super.tearDownWithError()
    }

    private func writeArticle(named name: String, url: String, title: String, in directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let contents = """
        ---
        title: "\(title)"
        url: \(url)
        added: 2026-08-31T00:00:00Z
        status: unread
        ---
        Body text.
        """
        try contents.write(to: directory.appendingPathComponent(name), atomically: true, encoding: .utf8)
    }

    func testFindsMatchAtLibraryRoot() throws {
        try writeArticle(named: "Root Article.md", url: "https://example.com/a", title: "Root Article", in: tempDir)

        let match = ArticleDuplicateFinder.findDuplicate(
            of: URL(string: "https://example.com/a")!,
            libraryFolder: tempDir
        )

        XCTAssertEqual(match?.existingTitle, "Root Article")
    }

    func testFindsMatchInArchive() throws {
        let archive = tempDir.appendingPathComponent("Archive", isDirectory: true)
        try writeArticle(named: "Archived.md", url: "https://example.com/b", title: "Archived", in: archive)

        let match = ArticleDuplicateFinder.findDuplicate(
            of: URL(string: "https://example.com/b")!,
            libraryFolder: tempDir
        )

        XCTAssertEqual(match?.existingTitle, "Archived")
    }

    func testFindsMatchInNestedSubfolder() throws {
        let nested = tempDir
            .appendingPathComponent("Reading Lists", isDirectory: true)
            .appendingPathComponent("Deep Dives", isDirectory: true)
        try writeArticle(named: "Nested.md", url: "https://example.com/c", title: "Nested", in: nested)

        let match = ArticleDuplicateFinder.findDuplicate(
            of: URL(string: "https://example.com/c")!,
            libraryFolder: tempDir
        )

        XCTAssertEqual(match?.existingTitle, "Nested")
    }

    func testDoesNotDescendIntoMediaFolders() throws {
        // A `.media` sidecar folder never contains `.md` files, but prove a stray one
        // (e.g. from a corrupted state) doesn't produce a false match or crash the scan.
        let media = tempDir.appendingPathComponent("Some Article.media", isDirectory: true)
        try writeArticle(named: "not-really-an-article.md", url: "https://example.com/d", title: "Fake", in: media)

        let match = ArticleDuplicateFinder.findDuplicate(
            of: URL(string: "https://example.com/d")!,
            libraryFolder: tempDir
        )

        XCTAssertNil(match)
    }

    func testMatchesThroughTrackingParameterNormalization() throws {
        try writeArticle(
            named: "Medium Article.md",
            url: "https://medium.com/@author/title-abc123",
            title: "Medium Article",
            in: tempDir
        )

        let match = ArticleDuplicateFinder.findDuplicate(
            of: URL(string: "https://medium.com/@author/title-abc123?source=friends_link&sk=deadbeef")!,
            libraryFolder: tempDir
        )

        XCTAssertEqual(match?.existingTitle, "Medium Article")
    }

    func testNoMatchReturnsNil() throws {
        try writeArticle(named: "Unrelated.md", url: "https://example.com/x", title: "Unrelated", in: tempDir)

        let match = ArticleDuplicateFinder.findDuplicate(
            of: URL(string: "https://example.com/y")!,
            libraryFolder: tempDir
        )

        XCTAssertNil(match)
    }
}
