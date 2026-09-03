import Foundation
import WebKit
import OSLog

private let logger = Logger(subsystem: "com.fabiosasseron.verso", category: "parsing")

/// Parses an article URL using Mozilla's Readability.js inside a hidden WKWebView.
/// Must be used from the main thread.
@MainActor
final class ReadabilityParser: NSObject {

    private var webView: WKWebView?
    private var continuation: CheckedContinuation<PendingArticle, Error>?
    private var targetURL: URL?

    // MARK: - Public

    func parse(url: URL) async throws -> PendingArticle {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.targetURL = url

            let config = WKWebViewConfiguration()
            config.websiteDataStore = .nonPersistent()
            let wv = WKWebView(frame: .zero, configuration: config)
            wv.navigationDelegate = self
            self.webView = wv

            // Load a blank page first; actual fetch is done via URLSession to avoid
            // cross-origin restrictions when injecting Readability.js.
            Task { [weak self] in
                guard let self else { return }
                do {
                    let html = try await fetchHTML(from: url)
                    await self.injectAndParse(html: html, url: url)
                } catch {
                    logger.warning("ReadabilityParser network error for \(url.absoluteString, privacy: .public): \(error.localizedDescription, privacy: .public)")
                    self.finish(throwing: ArticleParsingError.networkFailed(url, underlyingError: error))
                }
            }
        }
    }

    // MARK: - Private

    private func fetchHTML(from url: URL) async throws -> String {
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        let (data, _) = try await URLSession.shared.data(for: request)
        return String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) ?? ""
    }

    private func injectAndParse(html: String, url: URL) async {
        guard let wv = webView else { return }
        guard loadReadabilityJS() != nil else {
            logger.error("Readability.js resource not found in bundle")
            finish(throwing: ArticleParsingError.readabilityFailed(url))
            return
        }

        // Load the fetched HTML into the WebView with the correct base URL so
        // Readability.js can resolve relative links.
        wv.loadHTMLString(html, baseURL: url)

        // navigationDelegate didFinish will fire next, where we inject the JS.
    }

    private func loadReadabilityJS() -> String? {
        guard let url = Bundle.main.url(forResource: "Readability", withExtension: "js", subdirectory: "readability") else {
            return nil
        }
        return try? String(contentsOf: url, encoding: .utf8)
    }

    private func runReadability(in webView: WKWebView, sourceURL: URL) {
        guard let readabilityJS = loadReadabilityJS() else {
            finish(throwing: ArticleParsingError.readabilityFailed(sourceURL))
            return
        }

        let runnerJS = """
        (function() {
            try {
                \(readabilityJS)
                var reader = new Readability(document);
                var article = reader.parse();
                if (!article) { return JSON.stringify({error: "parse_returned_null"}); }
                return JSON.stringify({
                    title: article.title || "",
                    content: article.content || "",
                    excerpt: article.excerpt || "",
                    byline: article.byline || "",
                    siteName: article.siteName || ""
                });
            } catch(e) {
                return JSON.stringify({error: e.toString()});
            }
        })();
        """

        webView.evaluateJavaScript(runnerJS) { [weak self] result, error in
            guard let self else { return }

            if let error {
                logger.warning("Readability.js JS evaluation error: \(error.localizedDescription, privacy: .public)")
                self.finish(throwing: ArticleParsingError.readabilityFailed(sourceURL))
                return
            }

            guard let jsonString = result as? String,
                  let data = jsonString.data(using: .utf8),
                  let parsed = try? JSONDecoder().decode(ReadabilityResult.self, from: data),
                  parsed.error == nil,
                  !parsed.title.isEmpty || !parsed.content.isEmpty
            else {
                logger.warning("Readability.js returned empty or error result for \(sourceURL.absoluteString, privacy: .public)")
                self.finish(throwing: ArticleParsingError.readabilityFailed(sourceURL))
                return
            }

            let trimmedByline = parsed.byline?.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedSite = parsed.siteName?.trimmingCharacters(in: .whitespacesAndNewlines)
            let siteName = (trimmedSite?.isEmpty == false) ? trimmedSite : nil
            // FAB-332: drop a trailing " | CNN" / " - Site" publisher suffix once, here, so the
            // card, top bar, and H1 -- which all render this same `title` -- inherit the fix.
            let trimmedTitle = HTMLToMarkdownConverter.stripPublisherTitleSuffix(
                parsed.title.trimmingCharacters(in: .whitespacesAndNewlines),
                siteName: siteName,
                host: sourceURL.host
            )
            let markdown = HTMLToMarkdownConverter.convert(
                parsed.content,
                articleTitle: trimmedTitle.isEmpty ? nil : trimmedTitle,
                baseURL: sourceURL
            )
            let article = PendingArticle(
                id: UUID(),
                url: sourceURL,
                title: trimmedTitle,
                contentMarkdown: markdown,
                dateAdded: Date(),
                author: (trimmedByline?.isEmpty == false) ? trimmedByline : nil,
                siteName: siteName
            )
            self.finish(with: article)
        }
    }

    private func finish(with article: PendingArticle) {
        let c = continuation
        continuation = nil
        webView = nil
        c?.resume(returning: article)
    }

    private func finish(throwing error: Error) {
        let c = continuation
        continuation = nil
        webView = nil
        c?.resume(throwing: error)
    }
}

// MARK: - WKNavigationDelegate

extension ReadabilityParser: WKNavigationDelegate {
    nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor [weak self] in
            guard let self, let url = self.targetURL else { return }
            self.runReadability(in: webView, sourceURL: url)
        }
    }

    nonisolated func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Task { @MainActor [weak self] in
            guard let self, let url = self.targetURL else { return }
            logger.warning("WKWebView navigation failed for \(url.absoluteString, privacy: .public): \(error.localizedDescription, privacy: .public)")
            self.finish(throwing: ArticleParsingError.readabilityFailed(url))
        }
    }
}

// MARK: - Supporting types

private struct ReadabilityResult: Decodable {
    let title: String
    let content: String
    let excerpt: String?
    let byline: String?
    let siteName: String?
    let error: String?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        title = (try? c.decode(String.self, forKey: .title)) ?? ""
        content = (try? c.decode(String.self, forKey: .content)) ?? ""
        excerpt = try? c.decode(String.self, forKey: .excerpt)
        byline = try? c.decode(String.self, forKey: .byline)
        siteName = try? c.decode(String.self, forKey: .siteName)
        error = try? c.decode(String.self, forKey: .error)
    }

    enum CodingKeys: String, CodingKey {
        case title, content, excerpt, byline, siteName, error
    }
}
