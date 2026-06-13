import Foundation
import OSLog

private let logger = Logger(subsystem: "com.fabiosasseron.verso.ShareExtension", category: "parsing")
private let appGroupID = AppConstants.appGroupID

enum ShareState: Equatable {
    case idle
    case saving
    case duplicatePrompt(pending: PendingArticle, existingPath: String, existingTitle: String)
    case success(title: String, isUpdate: Bool)
    case failure(URL)
}

@MainActor
final class ShareViewModel: ObservableObject {
    @Published var state: ShareState = .idle

    private var lastLoadedURL: URL?

    func save(url: URL) {
        lastLoadedURL = url
        state = .saving
        Task {
            await performSave(url: url)
        }
    }

    func chooseUpdateExisting(pending: PendingArticle, existingPath: String) {
        Task {
            do {
                var copy = pending
                copy.duplicateResolution = .replaceExisting(path: existingPath)
                try writePending(copy)
                logger.info("Updated existing article at path (share): \(existingPath, privacy: .public)")
                state = .success(title: copy.title, isUpdate: true)
            } catch {
                logger.warning("Failed pending write (update): \(error.localizedDescription, privacy: .public)")
                if let u = lastLoadedURL {
                    state = .failure(u)
                }
            }
        }
    }

    func chooseSaveCopy(pending: PendingArticle) {
        Task {
            do {
                var copy = pending
                copy.title = ShareDuplicateArticleTitle.titleByAppendingCopySuffix(to: pending.title)
                copy.duplicateResolution = .saveCopy
                try writePending(copy)
                logger.info("Saved copy (share): \(copy.title, privacy: .public)")
                state = .success(title: copy.title, isUpdate: false)
            } catch {
                logger.warning("Failed pending write (copy): \(error.localizedDescription, privacy: .public)")
                if let u = lastLoadedURL {
                    state = .failure(u)
                }
            }
        }
    }

    // MARK: - Private

    private func performSave(url: URL) async {
        do {
            let html = try await fetchHTML(from: url)
            let article = try SwiftSoupParser.parse(html: html, url: url)

            if let libraryURL = LibraryBookmarkResolver.resolveLibraryFolderURL() {
                let accessed = libraryURL.startAccessingSecurityScopedResource()
                defer {
                    if accessed { libraryURL.stopAccessingSecurityScopedResource() }
                }
                if let match = ArticleDuplicateFinder.findDuplicate(of: article.url, libraryFolder: libraryURL) {
                    state = .duplicatePrompt(
                        pending: article,
                        existingPath: match.fileURL.path,
                        existingTitle: match.existingTitle
                    )
                    return
                }
            }

            try writePending(article)
            logger.info("Saved article: \(article.title, privacy: .public)")
            state = .success(title: article.title, isUpdate: false)
        } catch {
            logger.warning("Parse failed for \(url.absoluteString, privacy: .public): \(error.localizedDescription, privacy: .public)")
            let stub = PendingArticle(
                id: UUID(),
                url: url,
                title: url.host ?? url.absoluteString,
                contentMarkdown: "",
                dateAdded: Date()
            )
            try? writePending(stub)
            state = .failure(url)
        }
    }

    private func fetchHTML(from url: URL) async throws -> String {
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )
        let session = URLSession(configuration: .ephemeral)
        let (data, _) = try await session.data(for: request)
        return String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) ?? ""
    }

    private func writePending(_ article: PendingArticle) throws {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            throw ShareExtensionError.appGroupUnavailable
        }
        let pendingDir = container.appendingPathComponent("pending", isDirectory: true)
        try FileManager.default.createDirectory(at: pendingDir, withIntermediateDirectories: true)
        let fileURL = pendingDir.appendingPathComponent("\(article.id.uuidString).json")
        let data = try JSONEncoder().encode(article)
        try data.write(to: fileURL, options: .atomicWrite)
    }
}

enum ShareExtensionError: Error {
    case invalidURL
    case appGroupUnavailable
}
