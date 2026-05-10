import Foundation
import OSLog

private let logger = Logger(subsystem: "com.fabiosasseron.verso.ShareExtension", category: "parsing")
private let appGroupID = AppConstants.appGroupID

enum ShareState {
    case idle
    case saving
    case success(title: String)
    case failure(URL)
}

@MainActor
final class ShareViewModel: ObservableObject {
    @Published var state: ShareState = .idle

    func save(url: URL) {
        state = .saving
        Task {
            do {
                let html = try await fetchHTML(from: url)
                let article = try SwiftSoupParser.parse(html: html, url: url)
                try writePending(article)
                logger.info("Saved article: \(article.title, privacy: .public)")
                state = .success(title: article.title)
            } catch {
                logger.warning("Parse failed for \(url.absoluteString, privacy: .public): \(error.localizedDescription, privacy: .public)")
                // Write a minimal stub so the URL isn't lost
                let stub = PendingArticle(id: UUID(), url: url, title: url.host ?? url.absoluteString, contentMarkdown: "", dateAdded: Date())
                try? writePending(stub)
                state = .failure(url)
            }
        }
    }

    // MARK: - Private

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
