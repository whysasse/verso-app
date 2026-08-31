import Foundation
import CoreData

/// Finds articles related to a given one via TF-IDF cosine similarity (FAB-298; see
/// `RelatedArticlesScoring` for the actual algorithm). This type is the thin Core Data-facing
/// wrapper: it owns the `viewContext` fetch and the file-read fallback, then hands plain-value
/// documents to the pure scorer and maps the winning scores back to `Article` objects.
///
/// `@MainActor` because `viewContext` is main-thread-confined (see HANDOFF.md's Core Data
/// threading rule, and `ArticleLibraryService` for the same pattern) -- but the scoring itself,
/// the expensive part, runs in a detached task off the main actor.
@MainActor
final class RelatedArticlesService {

    /// Finds up to 3 related, non-archived articles for `article`, scored by
    /// `RelatedArticlesScoring`. Returns `[]` when nothing clears the threshold -- callers should
    /// hide the Related Articles section entirely in that case (already the case in
    /// `ArticleReaderView`, unchanged by this fix).
    func related(to article: Article, in context: NSManagedObjectContext) async -> [Article] {
        let currentPath = article.filePath

        // 1. Main-actor Core Data fetch + snapshot into plain values. No file I/O here yet --
        // `searchableBody` is already the plain text this needs for the common case (FAB-298 fix
        // item 2: the old implementation re-read every article's file from disk on every open).
        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "archived == NO")
        let candidates = ((try? context.fetch(fetchRequest)) ?? []).filter { $0.filePath != currentPath }
        guard !candidates.isEmpty else { return [] }

        var articlesByPath: [String: Article] = [:]
        var snapshots: [(key: String, title: String, cachedBody: String?, tags: [String])] = []
        for candidate in candidates {
            articlesByPath[candidate.filePath] = candidate
            snapshots.append((
                key: candidate.filePath,
                title: candidate.title,
                cachedBody: candidate.searchableBody,
                tags: candidate.tagList
            ))
        }
        let currentSnapshot = (
            title: article.title,
            cachedBody: article.searchableBody,
            tags: article.tagList
        )

        // 2. Off the main actor: fall back to a file read only for the rare snapshot missing a
        // cached body (searchableBody is populated by every ArticleLibraryService.rebuildCache),
        // then run the actual scoring -- the part that's too expensive to do on the main actor
        // for a large library.
        let scored = await Task.detached(priority: .userInitiated) { () -> [(key: String, score: Double)] in
            func body(forPath path: String, cached: String?) -> String {
                if let cached { return cached }
                guard !path.isEmpty else { return "" }
                return (try? MarkdownReader.read(fileURL: URL(fileURLWithPath: path)).contentMarkdown) ?? ""
            }

            let currentDoc = RelatedArticlesDocument(
                key: currentPath,
                title: currentSnapshot.title,
                body: body(forPath: currentPath, cached: currentSnapshot.cachedBody),
                tags: currentSnapshot.tags
            )
            let candidateDocs = snapshots.map { snapshot in
                RelatedArticlesDocument(
                    key: snapshot.key,
                    title: snapshot.title,
                    body: body(forPath: snapshot.key, cached: snapshot.cachedBody),
                    tags: snapshot.tags
                )
            }
            return RelatedArticlesScoring.score(current: currentDoc, candidates: candidateDocs)
        }.value

        // 3. Back on the main actor: map winning keys back to the Article objects fetched in step 1.
        return scored.compactMap { articlesByPath[$0.key] }
    }
}
