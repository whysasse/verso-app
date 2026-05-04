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
                    excerpt: article.excerpt || ""
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

            let markdown = HTMLToMarkdownConverter.convert(parsed.content)
            let article = PendingArticle(
                id: UUID(),
                url: sourceURL,
                title: parsed.title.trimmingCharacters(in: .whitespacesAndNewlines),
                contentMarkdown: markdown,
                dateAdded: Date()
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
    let error: String?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        title = (try? c.decode(String.self, forKey: .title)) ?? ""
        content = (try? c.decode(String.self, forKey: .content)) ?? ""
        excerpt = try? c.decode(String.self, forKey: .excerpt)
        error = try? c.decode(String.self, forKey: .error)
    }

    enum CodingKeys: String, CodingKey { case title, content, excerpt, error }
}

// MARK: - Minimal HTML → Markdown converter (shared use)

enum HTMLToMarkdownConverter {
    /// Very lightweight conversion: strips tags and preserves block structure.
    /// For a richer conversion SwiftSoupParser handles the full traversal.
    static func convert(_ html: String) -> String {
        var text = html
        // Block elements → newlines
        for tag in ["</p>", "</div>", "</li>", "<br>", "<br/>", "<br />", "</h1>", "</h2>", "</h3>", "</h4>", "</h5>", "</h6>"] {
            text = text.replacingOccurrences(of: tag, with: "\n", options: .caseInsensitive)
        }
        // Strip remaining tags
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        // Decode common HTML entities
        text = text
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&nbsp;", with: " ")
        // Collapse excessive blank lines
        while text.contains("\n\n\n") {
            text = text.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
