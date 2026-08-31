import XCTest
@testable import Verso

/// FAB-290: manually-added Markdown files (no frontmatter, or frontmatter with no `title`) must be
/// adopted with graceful defaults instead of skipped. See docs/BACKLOG.md FAB-290 and
/// docs/OBSIDIAN_INTEGRATION.md §9.
final class MarkdownReaderTests: XCTestCase {

    private var tempDir: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("MarkdownReaderTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let tempDir {
            try? FileManager.default.removeItem(at: tempDir)
        }
        tempDir = nil
        try super.tearDownWithError()
    }

    @discardableResult
    private func write(_ content: String, name: String) throws -> URL {
        let url = tempDir.appendingPathComponent(name)
        try content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    // MARK: - No frontmatter at all

    func testNoFrontmatterUsesWholeFileAsBodyAndDoesNotThrow() throws {
        let url = try write("Just some plain text I dropped into the folder.\n\nA second paragraph.", name: "meeting-notes.md")
        let article = try MarkdownReader.read(fileURL: url)
        XCTAssertEqual(article.contentMarkdown, "Just some plain text I dropped into the folder.\n\nA second paragraph.")
        XCTAssertEqual(article.status, .unread)
        XCTAssertNil(article.tags)
        XCTAssertNil(article.url)
        XCTAssertTrue(article.needsAdoption)
    }

    func testNoFrontmatterFallsBackToFilenameTitle() throws {
        let url = try write("Body only, no frontmatter.", name: "meeting-notes.md")
        let article = try MarkdownReader.read(fileURL: url)
        XCTAssertEqual(article.title, "meeting-notes")
    }

    func testNoFrontmatterStripsLeadingDatePrefixFromFilenameTitle() throws {
        let url = try write("Body only, no frontmatter.", name: "2026-04-19 The Future of Reading Apps.md")
        let article = try MarkdownReader.read(fileURL: url)
        XCTAssertEqual(article.title, "The Future of Reading Apps")
    }

    func testNoFrontmatterUsesFileCreationDateForDateAdded() throws {
        let url = try write("Body only.", name: "note.md")
        let article = try MarkdownReader.read(fileURL: url)
        let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
        let creationDate = try XCTUnwrap(attrs[.creationDate] as? Date)
        XCTAssertEqual(article.dateAdded.timeIntervalSince1970, creationDate.timeIntervalSince1970, accuracy: 1)
    }

    func testReadAllSurfacesFileWithNoFrontmatterInsteadOfSkippingIt() throws {
        try write("A note with no frontmatter at all.", name: "raw-note.md")
        let articles = MarkdownReader.readAll(from: tempDir)
        XCTAssertEqual(articles.count, 1)
        XCTAssertEqual(articles.first?.title, "raw-note")
    }

    // MARK: - Frontmatter present, no `title` key

    func testFrontmatterWithoutTitleFallsBackToFilename() throws {
        let content = """
        ---
        status: reading
        tags: ["design", "ux"]
        ---
        Body content here.
        """
        let url = try write(content, name: "2026-04-19 The Future of Reading Apps.md")
        let article = try MarkdownReader.read(fileURL: url)
        XCTAssertEqual(article.title, "The Future of Reading Apps")
        XCTAssertEqual(article.status, .reading)
        XCTAssertEqual(article.tags, ["design", "ux"])
        XCTAssertEqual(article.contentMarkdown, "Body content here.")
        XCTAssertTrue(article.needsAdoption)
    }

    func testEmptyTitleValueFallsBackToFilenameJustLikeMissingKey() throws {
        let content = """
        ---
        title:
        status: unread
        ---
        Body.
        """
        let url = try write(content, name: "untitled-note.md")
        let article = try MarkdownReader.read(fileURL: url)
        XCTAssertEqual(article.title, "untitled-note")
        XCTAssertTrue(article.needsAdoption)
    }

    // MARK: - Frontmatter with unrecognized custom keys

    func testUnrecognizedFrontmatterKeysArePreservedVerbatim() throws {
        let content = """
        ---
        title: "My Note"
        aliases: [alt-name]
        cssclass: reading-note
        status: unread
        ---
        Body.
        """
        let url = try write(content, name: "obsidian-note.md")
        let article = try MarkdownReader.read(fileURL: url)
        XCTAssertEqual(article.title, "My Note")
        XCTAssertEqual(article.unrecognizedFrontmatterLines, ["aliases: [alt-name]", "cssclass: reading-note"])
        // A title was present, so this file is already Verso-legible and doesn't need adopting.
        XCTAssertFalse(article.needsAdoption)
    }

    func testUnrecognizedKeysPreservedEvenWhenTitleIsAlsoMissing() throws {
        let content = """
        ---
        aliases: [alt-name]
        status: reading
        ---
        Body.
        """
        let url = try write(content, name: "note.md")
        let article = try MarkdownReader.read(fileURL: url)
        XCTAssertEqual(article.title, "note")
        XCTAssertEqual(article.unrecognizedFrontmatterLines, ["aliases: [alt-name]"])
        XCTAssertTrue(article.needsAdoption)
    }

    // MARK: - Existing graceful-degradation behavior preserved

    func testMissingStatusDefaultsToUnread() throws {
        let content = """
        ---
        title: "A Title"
        ---
        Body.
        """
        let url = try write(content, name: "note.md")
        let article = try MarkdownReader.read(fileURL: url)
        XCTAssertEqual(article.status, .unread)
    }

    func testCompleteFrontmatterDoesNotNeedAdoption() throws {
        let content = """
        ---
        title: "A Title"
        status: read
        added: 2026-04-19
        ---
        Body.
        """
        let url = try write(content, name: "note.md")
        let article = try MarkdownReader.read(fileURL: url)
        XCTAssertFalse(article.needsAdoption)
        XCTAssertTrue(article.unrecognizedFrontmatterLines.isEmpty)
    }

    // MARK: - archived / archived_at (FAB-297)

    func testLegacyStatusArchivedBackfillsToReadPlusArchived() throws {
        let content = """
        ---
        title: "A Title"
        status: archived
        ---
        Body.
        """
        let url = try write(content, name: "note.md")
        let article = try MarkdownReader.read(fileURL: url)
        XCTAssertEqual(article.status, .read)
        XCTAssertTrue(article.archived)
        // Lazy back-fill (FAB-290 precedent): reading doesn't rewrite the file on disk.
        XCTAssertEqual(try String(contentsOf: url, encoding: .utf8), content)
    }

    func testArchivedTrueWithArchivedAtRoundTrips() throws {
        let content = """
        ---
        title: "A Title"
        status: read
        archived: true
        archived_at: 2026-08-30
        ---
        Body.
        """
        let url = try write(content, name: "note.md")
        let article = try MarkdownReader.read(fileURL: url)
        XCTAssertEqual(article.status, .read)
        XCTAssertTrue(article.archived)
        let expectedDate = Self.dateFormatter.date(from: "2026-08-30")
        XCTAssertEqual(article.archivedAt, expectedDate)
    }

    func testMissingArchivedDefaultsToFalse() throws {
        let content = """
        ---
        title: "A Title"
        status: unread
        ---
        Body.
        """
        let url = try write(content, name: "note.md")
        let article = try MarkdownReader.read(fileURL: url)
        XCTAssertFalse(article.archived)
        XCTAssertNil(article.archivedAt)
    }

    // MARK: - synthesizedTitle

    func testSynthesizedTitleStripsExtensionAndDatePrefix() {
        let url = URL(fileURLWithPath: "/tmp/2026-04-19 The Future of Reading Apps.md")
        XCTAssertEqual(MarkdownReader.synthesizedTitle(from: url), "The Future of Reading Apps")
    }

    func testSynthesizedTitleWithoutDatePrefixReturnsFilename() {
        let url = URL(fileURLWithPath: "/tmp/meeting-notes.md")
        XCTAssertEqual(MarkdownReader.synthesizedTitle(from: url), "meeting-notes")
    }
}
