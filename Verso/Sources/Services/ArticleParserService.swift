import Foundation
import OSLog

private let logger = Logger(subsystem: "com.fabiosasseron.verso", category: "parsing")

/// Orchestrates article parsing: tries Readability.js first, falls back to SwiftSoup.
/// Must be used from the main actor because `ReadabilityParser` requires the main thread.
@MainActor
final class ArticleParserService {

    private let readabilityParser = ReadabilityParser()

    /// Parses the article at `url`, returning a `PendingArticle` on success.
    /// Throws `ArticleParsingError.allParsersFailed` if both parsers fail.
    func parse(url: URL) async throws -> PendingArticle {
        // 1. Try Readability.js
        do {
            let article = try await readabilityParser.parse(url: url)
            logger.info("Readability.js succeeded for \(url.host ?? url.absoluteString, privacy: .public)")
            return article
        } catch {
            logger.info("Readability.js failed for \(url.host ?? url.absoluteString, privacy: .public), trying SwiftSoup")
        }

        // 2. Fetch HTML and try SwiftSoup
        do {
            let html = try await fetchHTML(from: url)
            let article = try SwiftSoupParser.parse(html: html, url: url)
            logger.info("SwiftSoup succeeded for \(url.host ?? url.absoluteString, privacy: .public)")
            return article
        } catch {
            logger.warning("SwiftSoup also failed for \(url.host ?? url.absoluteString, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }

        let error = ArticleParsingError.allParsersFailed(url)
        AnalyticsService.shared.track("article.parseFailed", parameters: ["errorType": "allParsersFailed"])
        throw error
    }

    // MARK: - Private

    private func fetchHTML(from url: URL) async throws -> String {
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) ?? ""
        } catch {
            throw ArticleParsingError.networkFailed(url, underlyingError: error)
        }
    }
}
