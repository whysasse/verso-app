import XCTest
@testable import Verso

/// FAB-290: the one-time "adoption" of a manually-added Markdown file -- merging Verso's
/// frontmatter into whatever was already on disk (without dropping unrecognized keys) and renaming
/// the file to the `YYYY-MM-DD Title.md` convention. See docs/BACKLOG.md FAB-290.
final class MarkdownWriterTests: XCTestCase {

    private var tempDir: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("MarkdownWriterTests-\(UUID().uuidString)", isDirectory: true)
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

    // MARK: - buildFrontmatter(preservingUnrecognized:)

    func testBuildFrontmatterWithoutUnrecognizedLinesMatchesPlainVariant() throws {
        let article = ParsedArticle(
            id: UUID(), filePath: tempDir.appendingPathComponent("a.md"), title: "A Title", url: nil,
            contentMarkdown: "Body.", tags: nil, scrollPosition: nil, dateAdded: Date(),
            status: .unread, author: nil, siteName: nil
        )
        XCTAssertEqual(MarkdownWriter.buildFrontmatter(for: article), MarkdownWriter.buildFrontmatter(for: article, preservingUnrecognized: []))
    }

    func testBuildFrontmatterAppendsUnrecognizedLinesBeforeClosingDelimiter() throws {
        let article = ParsedArticle(
            id: UUID(), filePath: tempDir.appendingPathComponent("a.md"), title: "A Title", url: nil,
            contentMarkdown: "Body.", tags: nil, scrollPosition: nil, dateAdded: Date(),
            status: .unread, author: nil, siteName: nil
        )
        let frontmatter = MarkdownWriter.buildFrontmatter(for: article, preservingUnrecognized: ["aliases: [alt-name]", "cssclass: reading-note"])
        let lines = frontmatter.trimmingCharacters(in: .newlines).components(separatedBy: "\n")
        XCTAssertEqual(lines.first, "---")
        XCTAssertEqual(lines.last, "---")
        // Closing delimiter still terminates the block, with the unrecognized lines just before it.
        XCTAssertEqual(lines[lines.count - 2], "cssclass: reading-note")
        XCTAssertEqual(lines[lines.count - 3], "aliases: [alt-name]")
    }

    // MARK: - adoptIfNeeded: no-op for already-adopted files

    func testAdoptIfNeededReturnsNilAndTouchesNothingWhenFileAlreadyHasTitle() throws {
        let content = """
        ---
        title: "A Title"
        status: unread
        added: 2026-04-19
        ---
        Body.
        """
        let url = try write(content, name: "2026-04-19 A Title.md")
        let originalContent = try String(contentsOf: url, encoding: .utf8)

        let result = try MarkdownWriter.adoptIfNeeded(fileURL: url, in: tempDir)

        XCTAssertNil(result)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertEqual(try String(contentsOf: url, encoding: .utf8), originalContent)
    }

    // MARK: - adoptIfNeeded: no frontmatter at all

    func testAdoptIfNeededRenamesFileWithNoFrontmatter() throws {
        let url = try write("Just some plain text I dropped into the folder.", name: "meeting-notes.md")
        let creationDate = try XCTUnwrap(FileManager.default.attributesOfItem(atPath: url.path)[.creationDate] as? Date)
        let expectedDateStr = Self.dateFormatter.string(from: creationDate)

        let newURL = try XCTUnwrap(try MarkdownWriter.adoptIfNeeded(fileURL: url, in: tempDir))

        XCTAssertEqual(newURL.lastPathComponent, "\(expectedDateStr) meeting-notes.md")
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path), "old file should be removed after adoption")
        XCTAssertTrue(FileManager.default.fileExists(atPath: newURL.path))

        let adopted = try String(contentsOf: newURL, encoding: .utf8)
        XCTAssertTrue(adopted.contains("title: \"meeting-notes\""))
        XCTAssertTrue(adopted.contains("status: unread"))
        XCTAssertTrue(adopted.hasSuffix("Just some plain text I dropped into the folder."))

        // Re-reading the adopted file no longer needs adoption.
        let reread = try MarkdownReader.read(fileURL: newURL)
        XCTAssertFalse(reread.needsAdoption)
    }

    // MARK: - adoptIfNeeded: missing title, merges unrecognized keys

    func testAdoptIfNeededMergesUnrecognizedKeysAndRenamesUsingFilenameTitle() throws {
        let content = """
        ---
        aliases: [old-name]
        cssclass: reading-note
        status: reading
        tags: ["design"]
        added: 2026-04-19
        ---
        Some body content.
        """
        let url = try write(content, name: "2026-04-19 The Future of Reading Apps.md")

        let newURL = try XCTUnwrap(try MarkdownWriter.adoptIfNeeded(fileURL: url, in: tempDir))

        XCTAssertEqual(newURL.lastPathComponent, "2026-04-19 The Future of Reading Apps.md", "already-conventional filename shouldn't be perturbed")
        let adopted = try String(contentsOf: newURL, encoding: .utf8)
        XCTAssertTrue(adopted.contains("title: \"The Future of Reading Apps\""))
        XCTAssertTrue(adopted.contains("status: reading"))
        XCTAssertTrue(adopted.contains("aliases: [old-name]"), "unrecognized key must survive the merge")
        XCTAssertTrue(adopted.contains("cssclass: reading-note"), "unrecognized key must survive the merge")

        let reread = try MarkdownReader.read(fileURL: newURL)
        XCTAssertFalse(reread.needsAdoption)
        XCTAssertEqual(reread.status, .reading)
        XCTAssertEqual(reread.tags, ["design"])
    }

    func testAdoptIfNeededRenamesWhenFilenameDoesNotMatchConvention() throws {
        let content = """
        ---
        aliases: [old-name]
        status: unread
        ---
        Body.
        """
        let url = try write(content, name: "random-obsidian-filename.md")

        let newURL = try XCTUnwrap(try MarkdownWriter.adoptIfNeeded(fileURL: url, in: tempDir))

        XCTAssertNotEqual(newURL.lastPathComponent, "random-obsidian-filename.md")
        XCTAssertTrue(newURL.lastPathComponent.hasSuffix("random-obsidian-filename.md"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    }

    // MARK: - adoptIfNeeded: filename collision handling

    func testAdoptIfNeededUsesUniqueFilenameOnCollision() throws {
        let source = try write("Body only, no frontmatter.", name: "meeting-notes.md")
        let creationDate = try XCTUnwrap(FileManager.default.attributesOfItem(atPath: source.path)[.creationDate] as? Date)
        let dateStr = Self.dateFormatter.string(from: creationDate)

        // A file already occupies the exact name adoption would produce.
        try write("---\ntitle: \"meeting-notes\"\nstatus: unread\n---\nExisting.", name: "\(dateStr) meeting-notes.md")

        let newURL = try XCTUnwrap(try MarkdownWriter.adoptIfNeeded(fileURL: source, in: tempDir))

        XCTAssertEqual(newURL.lastPathComponent, "\(dateStr) meeting-notes (2).md")
        XCTAssertTrue(FileManager.default.fileExists(atPath: newURL.path))
        // The pre-existing file at the base name is untouched.
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("\(dateStr) meeting-notes.md").path))
    }

    // MARK: - delete/archive: `.media` sidecar folder (FAB-295)

    private func makeMediaFolder(forArticleNamed name: String) throws -> URL {
        let stem = (name as NSString).deletingPathExtension
        let mediaDir = tempDir.appendingPathComponent("\(stem).media", isDirectory: true)
        try FileManager.default.createDirectory(at: mediaDir, withIntermediateDirectories: true)
        try Data([0x01]).write(to: mediaDir.appendingPathComponent("\(stem)-01.jpg"))
        return mediaDir
    }

    func testDeleteRemovesSiblingMediaFolder() throws {
        let articleURL = try write("---\ntitle: \"A\"\nstatus: unread\n---\nBody.", name: "Article.md")
        let mediaDir = try makeMediaFolder(forArticleNamed: "Article.md")

        try MarkdownWriter.delete(at: articleURL.path)

        XCTAssertFalse(FileManager.default.fileExists(atPath: articleURL.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: mediaDir.path), "Orphaned .media folder should be removed alongside the article")
    }

    func testDeleteWithNoMediaFolderStillDeletesArticle() throws {
        let articleURL = try write("---\ntitle: \"A\"\nstatus: unread\n---\nBody.", name: "Article.md")

        try MarkdownWriter.delete(at: articleURL.path)

        XCTAssertFalse(FileManager.default.fileExists(atPath: articleURL.path))
    }

    func testArchiveMovesSiblingMediaFolderIntoArchiveSubfolder() throws {
        let articleURL = try write("---\ntitle: \"A\"\nstatus: unread\n---\nBody.", name: "Article.md")
        _ = try makeMediaFolder(forArticleNamed: "Article.md")

        let destination = try MarkdownWriter.archive(filePath: articleURL.path, in: tempDir)

        XCTAssertFalse(FileManager.default.fileExists(atPath: tempDir.appendingPathComponent("Article.media").path))
        let archivedMediaDir = destination.deletingLastPathComponent().appendingPathComponent("Article.media", isDirectory: true)
        XCTAssertTrue(FileManager.default.fileExists(atPath: archivedMediaDir.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: archivedMediaDir.appendingPathComponent("Article-01.jpg").path))
    }

    func testArchiveWithNoMediaFolderStillArchivesArticle() throws {
        let articleURL = try write("---\ntitle: \"A\"\nstatus: unread\n---\nBody.", name: "Article.md")

        let destination = try MarkdownWriter.archive(filePath: articleURL.path, in: tempDir)

        XCTAssertTrue(FileManager.default.fileExists(atPath: destination.path))
        XCTAssertEqual(destination.lastPathComponent, "Article.md")
    }
}
