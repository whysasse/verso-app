import XCTest
import CoreData
@testable import Verso

/// FAB-304 (cause 3): `rebuildCache` used to trust that security-scoped access to the folder was
/// already open and treat an empty/failed read as "the user deleted every article," wiping the
/// entire Core Data cache. See ArticleLibraryService.swift and docs/BACKLOG.md FAB-304 for the full
/// story — `VersoApp` stopped access on `scenePhase == .background` and never reopened it before the
/// next `.active`-triggered rebuild, so the first backgrounding of a session onward raced an empty
/// read against whatever unrelated bracket happened to be open elsewhere.
final class ArticleLibraryServiceTests: XCTestCase {

    private var tempDir: URL!
    private var container: NSPersistentContainer!
    private var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("ArticleLibraryServiceTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        // A fresh in-memory container per test, isolated from both other tests and from whatever
        // `CoreDataStack.shared` the hosting app has already loaded. Deliberately reuses the app's
        // already-loaded `NSManagedObjectModel` *instance* (rather than `CoreDataStackValue.preview`,
        // which loads its own copy of the model from disk): this test target runs hosted inside the
        // Verso app, so `CoreDataStack.shared` loads the real on-disk model as a side effect of the
        // app launching. Loading a second, distinct `NSManagedObjectModel` for the same `Article`
        // class makes Core Data unable to disambiguate which `NSEntityDescription` the class belongs
        // to ("Multiple NSEntityDescriptions claim the NSManagedObject subclass 'Article'"), which
        // silently misroutes fetches/inserts. Sharing the one already-loaded model instance avoids
        // that entirely while still giving each test its own throwaway store.
        let model = CoreDataStack.shared.persistentContainer.managedObjectModel
        let freshContainer = NSPersistentContainer(name: "Verso", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        freshContainer.persistentStoreDescriptions = [description]
        var loadError: Error?
        freshContainer.loadPersistentStores { _, error in loadError = error }
        if let loadError { throw loadError }
        container = freshContainer
        context = freshContainer.viewContext
    }

    override func tearDownWithError() throws {
        if let tempDir {
            try? FileManager.default.removeItem(at: tempDir)
        }
        tempDir = nil
        context = nil
        container = nil
        try super.tearDownWithError()
    }

    @discardableResult
    private func write(_ content: String, name: String) throws -> URL {
        let url = tempDir.appendingPathComponent(name)
        try content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func fetchAllArticles() throws -> [Article] {
        try context.fetch(NSFetchRequest<Article>(entityName: "Article"))
    }

    // MARK: - Normal upsert/reconcile still works

    func test_rebuildCache_upsertsNewFilesAndRemovesGenuinelyDeletedOnes() async throws {
        try write("""
        ---
        title: "Kept Article"
        status: unread
        ---
        Body.
        """, name: "kept.md")

        // Pre-existing cache row for a file that no longer exists on disk.
        _ = Article.create(in: context, filePath: tempDir.appendingPathComponent("gone.md").path, title: "Gone Article")
        try context.save()

        let service = await ArticleLibraryService()
        await service.rebuildCache(from: tempDir, context: context)

        let articles = try fetchAllArticles()
        XCTAssertEqual(articles.map(\.title), ["Kept Article"], "the real file should be upserted and the vanished one's stale row removed")
    }

    // MARK: - FAB-304 cause 3: empty/failed read must not wipe an existing cache

    func test_rebuildCache_emptyFolderWithNoPriorCache_staysEmpty() async throws {
        // No files written to tempDir, and nothing cached yet — legitimately nothing to do.
        let service = await ArticleLibraryService()
        await service.rebuildCache(from: tempDir, context: context)

        XCTAssertEqual(try fetchAllArticles().count, 0)
    }

    func test_rebuildCache_suspiciouslyEmptyReadWithExistingCache_doesNotWipeCache() async throws {
        // Simulate the FAB-304 race directly: existing Core Data rows from a prior successful
        // rebuild, but this rebuild's folder read comes back with zero files — e.g. security-scoped
        // access wasn't (yet) open, or the volume was briefly unreachable. The real files were never
        // touched; only the read failed. The cache must survive.
        let existing = Article.create(in: context, filePath: tempDir.appendingPathComponent("article.md").path, title: "Still Reading", status: .reading)
        existing.scrollPosition = NSNumber(value: 0.42)
        try context.save()

        // A nonexistent subdirectory reproduces "the read came back empty" without needing to
        // simulate an actual security-scoped access failure.
        let unreadableDir = tempDir.appendingPathComponent("does-not-exist", isDirectory: true)

        let service = await ArticleLibraryService()
        await service.rebuildCache(from: unreadableDir, context: context)

        let articles = try fetchAllArticles()
        XCTAssertEqual(articles.count, 1, "a failed/empty read must not be treated as \"every article was deleted\"")
        XCTAssertEqual(articles.first?.title, "Still Reading")
        XCTAssertEqual(articles.first?.statusEnum, .reading, "status must not revert to unread on a bad read")
        XCTAssertEqual(articles.first?.scrollPosition?.doubleValue, 0.42)
    }
}
