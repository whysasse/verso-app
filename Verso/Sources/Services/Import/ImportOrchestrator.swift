import CoreData
import Foundation
import OSLog

private let logger = Logger(subsystem: "com.fabiosasseron.verso", category: "import")

enum ImportState: Equatable {
    case idle
    case parsing
    case writing(progress: Double)
    case done(imported: Int, skipped: Int)
    case failed(String)

    static func == (lhs: ImportState, rhs: ImportState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.parsing, .parsing): return true
        case (.writing(let a), .writing(let b)): return a == b
        case (.done(let a, let b), .done(let c, let d)): return a == c && b == d
        case (.failed(let a), .failed(let b)): return a == b
        default: return false
        }
    }
}

@MainActor
final class ImportOrchestrator: ObservableObject {
    @Published var state: ImportState = .idle

    func importFile(at url: URL, folderURL: URL, context: NSManagedObjectContext) async {
        state = .parsing

        let articles: [ParsedArticle]
        do {
            let parser = try ImportFormatDetector.parser(for: url)
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            articles = try parser.parse(url)
        } catch {
            logger.error("Import parse failed: \(error.localizedDescription, privacy: .public)")
            state = .failed(error.localizedDescription)
            return
        }

        guard !articles.isEmpty else {
            state = .done(imported: 0, skipped: 0)
            return
        }

        let folderAccessed = folderURL.startAccessingSecurityScopedResource()
        defer { if folderAccessed { folderURL.stopAccessingSecurityScopedResource() } }

        var imported = 0
        var skipped = 0

        for (index, article) in articles.enumerated() {
            state = .writing(progress: Double(index) / Double(articles.count))
            do {
                let fileURL = try MarkdownWriter.write(article: article, to: folderURL)
                insertIntoCoreData(article: article, filePath: fileURL, context: context)
                imported += 1
                logger.info("Imported: \(article.title, privacy: .public)")
            } catch MarkdownWriterError.emptyTitle {
                skipped += 1
            } catch {
                logger.warning("Skipped \(article.title, privacy: .public): \(error.localizedDescription, privacy: .public)")
                skipped += 1
            }
        }

        do {
            try context.save()
        } catch {
            logger.error("Core Data save failed after import: \(error.localizedDescription, privacy: .public)")
        }

        state = .done(imported: imported, skipped: skipped)
    }

    func reset() {
        state = .idle
    }

    // MARK: - Private

    private func insertIntoCoreData(article: ParsedArticle, filePath: URL, context: NSManagedObjectContext) {
        _ = Article.create(
            in: context,
            filePath: filePath.path,
            title: article.title,
            url: article.url,
            status: article.status,
            dateAdded: article.dateAdded,
            source: article.url.flatMap { URL(string: $0.absoluteString)?.host },
            author: article.author,
            siteName: article.siteName
        )
    }
}
