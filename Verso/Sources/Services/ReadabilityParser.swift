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

            let trimmedTitle = parsed.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let markdown = HTMLToMarkdownConverter.convert(
                parsed.content,
                articleTitle: trimmedTitle.isEmpty ? nil : trimmedTitle,
                baseURL: sourceURL
            )
            let trimmedByline = parsed.byline?.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedSite = parsed.siteName?.trimmingCharacters(in: .whitespacesAndNewlines)
            let article = PendingArticle(
                id: UUID(),
                url: sourceURL,
                title: parsed.title.trimmingCharacters(in: .whitespacesAndNewlines),
                contentMarkdown: markdown,
                dateAdded: Date(),
                author: (trimmedByline?.isEmpty == false) ? trimmedByline : nil,
                siteName: (trimmedSite?.isEmpty == false) ? trimmedSite : nil
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

// MARK: - Minimal HTML → Markdown converter (shared use)

enum HTMLToMarkdownConverter {
    /// Very lightweight conversion: strips tags and preserves block structure.
    /// For a richer conversion SwiftSoupParser handles the full traversal.
    static func convert(_ html: String, articleTitle: String? = nil, baseURL: URL? = nil) -> String {
        var text = html
        text = stripLightboxChrome(from: text)
        text = collapsePictureBlocksToSingleImg(in: text, baseURL: baseURL)
        text = insertMarkdownImages(from: text, baseURL: baseURL)
        // Block elements → newlines
        for tag in ["</p>", "</div>", "</li>", "<br>", "<br/>", "<br />", "</h1>", "</h2>", "</h3>", "</h4>", "</h5>", "</h6>", "</figcaption>", "</figure>"] {
            text = text.replacingOccurrences(of: tag, with: "\n", options: .caseInsensitive)
        }
        // Strip remaining tags
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        // Decode common HTML entities
        text = decodeBasicHTMLEntities(text)
        // Collapse excessive blank lines
        while text.contains("\n\n\n") {
            text = text.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }
        text = sanitizeMarkdownBody(text, articleTitle: articleTitle)
        return text
    }

    /// Normalizes Readability / saved markdown: drop lightbox UI lines, repeated title blocks, and duplicate paragraphs.
    /// Also used when loading an article from disk so older saves get the same cleanup.
    static func sanitizeMarkdownBody(_ markdown: String, articleTitle: String?) -> String {
        var text = markdown
        while text.contains("\n\n\n") {
            text = text.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }
        text = stripFullscreenNoiseFromMarkdown(text)
        text = stripLeadingTitleEcho(markdown: text, title: articleTitle)
        text = stripAllBlocksMatchingTitle(markdown: text, title: articleTitle)
        text = collapseMarkdownDuplicateBlocks(text)
        text = collapseImageCaptionEcho(text)
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Guardian / modern sites often wrap the editorial image in `<picture>` and lazy‑load URLs in `srcset` / `data-src`.
    /// Replaces `<img …>` tags with Markdown image syntax so FAB-140 can localize remote URLs on save.
    private static func insertMarkdownImages(from html: String, baseURL: URL?) -> String {
        guard let regex = try? NSRegularExpression(pattern: #"<img[^>]*?>"#, options: [.caseInsensitive]) else {
            return html
        }
        let immutable = html as NSString
        var replacements: [(NSRange, String)] = []
        for match in regex.matches(in: html, options: [], range: NSRange(location: 0, length: immutable.length)) {
            guard match.range.location != NSNotFound else { continue }
            let tag = immutable.substring(with: match.range)
            guard let resolved = resolvedHTTPImageURL(forImgTag: tag, baseURL: baseURL) else { continue }
            let altRaw = attributeValue(attribute: "alt", in: tag)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let alt = markdownSafeAltText(altRaw)
            let md = "\n\n![\(alt)](\(resolved))\n\n"
            replacements.append((match.range, md))
        }
        guard !replacements.isEmpty else { return html }
        replacements.sort { $0.0.location > $1.0.location }
        let mutable = NSMutableString(string: html)
        for pair in replacements {
            mutable.replaceCharacters(in: pair.0, with: pair.1)
        }
        return mutable as String
    }

    /// Avoid breaking `![](url)` markdown when captions contain `]` (rare from publishers).
    private static func markdownSafeAltText(_ raw: String) -> String {
        raw.replacingOccurrences(of: "]", with: ")")
            .replacingOccurrences(of: "[", with: "(")
    }

    // MARK: - HTML cleanup (Readability / news layouts)

    private static func stripLightboxChrome(from html: String) -> String {
        var s = html
        let patterns = [
            #"<a\b[^>]*>[\s\S]*?(?:View image in fullscreen|open image in fullscreen|view fullscreen|full screen image)[\s\S]*?</a>"#,
            #"<button\b[^>]*>[\s\S]*?(?:View image in fullscreen|open image in fullscreen|view fullscreen)[\s\S]*?</button>"#,
            #"<span\b[^>]*>[\s\S]*?(?:View image in fullscreen|open image in fullscreen)[\s\S]*?</span>"#,
        ]
        for p in patterns {
            guard let re = try? NSRegularExpression(pattern: p, options: [.caseInsensitive, .dotMatchesLineSeparators]) else { continue }
            let range = NSRange(s.startIndex..<s.endIndex, in: s)
            s = re.stringByReplacingMatches(in: s, options: [], range: range, withTemplate: "")
        }
        return s
    }

    /// Collapse `<picture>…</picture>` to a single `<img>` carrying the best-resolved URL for downstream `insertMarkdownImages`.
    /// Unwrap Guardian-style `<picture>` blocks so URLs in `<source srcset>` are visible as a plain `<img>`.
    private static func collapsePictureBlocksToSingleImg(in html: String, baseURL: URL?) -> String {
        guard let re = try? NSRegularExpression(pattern: #"<picture\b[^>]*>([\s\S]*?)</picture>"#, options: [.caseInsensitive]) else {
            return html
        }
        var work = NSMutableString(string: html)
        while true {
            let full = NSString(string: work as String)
            let search = NSRange(location: 0, length: full.length)
            guard let match = re.firstMatch(in: work as String, options: [], range: search),
                  match.numberOfRanges > 1 else { break }
            let inner = full.substring(with: match.range(at: 1))
            if let pair = bestImageURLAndAlt(inHTMLFragment: inner, baseURL: baseURL) {
                let escSrc = pair.url
                    .replacingOccurrences(of: "&", with: "&amp;")
                    .replacingOccurrences(of: "\"", with: "&quot;")
                let escAlt = pair.alt
                    .replacingOccurrences(of: "&", with: "&amp;")
                    .replacingOccurrences(of: "\"", with: "&quot;")
                let replacement = "<img src=\"\(escSrc)\" alt=\"\(escAlt)\" />"
                work.replaceCharacters(in: match.range, with: replacement)
            } else {
                // Drop wrapper only — keeps nested `<img>` / text so we don't spin forever matching the same markup.
                work.replaceCharacters(in: match.range, with: inner)
            }
        }
        return work as String
    }

    private static func bestImageURLAndAlt(inHTMLFragment inner: String, baseURL: URL?) -> (url: String, alt: String)? {
        var bestURL: String?
        var altOut = ""
        if let imgRe = try? NSRegularExpression(pattern: #"<img[^>]*>"#, options: [.caseInsensitive]) {
            let i = inner as NSString
            let imgMatches = imgRe.matches(in: inner, options: [], range: NSRange(location: 0, length: i.length))
            for m in imgMatches.reversed() {
                let tag = i.substring(with: m.range)
                if let u = resolvedHTTPImageURL(forImgTag: tag, baseURL: baseURL) {
                    bestURL = u
                    altOut = attributeValue(attribute: "alt", in: tag)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    break
                }
            }
        }
        if bestURL == nil, let srcRe = try? NSRegularExpression(pattern: #"<source\b[^>]*>"#, options: [.caseInsensitive]) {
            let i = inner as NSString
            for m in srcRe.matches(in: inner, options: [], range: NSRange(location: 0, length: i.length)) {
                let tag = i.substring(with: m.range)
                if let ss = attributeValue(attribute: "srcset", in: tag),
                   let u = firstHTTPURL(inSrcset: ss, baseURL: baseURL) {
                    bestURL = u
                    break
                }
            }
        }
        guard let url = bestURL else { return nil }
        return (url, altOut)
    }

    private static func resolvedHTTPImageURL(forImgTag tag: String, baseURL: URL?) -> String? {
        if let ss = attributeValue(attribute: "srcset", in: tag),
           let u = firstHTTPURL(inSrcset: ss, baseURL: baseURL) {
            return u
        }
        let lazyKeys = ["data-src", "data-lazy-src", "data-original", "data-print-url", "data-intermediate"]
        for key in lazyKeys {
            if let raw = attributeValue(attribute: key, in: tag)?
                .trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty,
               let u = canonicalImageURLString(raw, baseURL: baseURL) {
                return u
            }
        }
        if let raw = attributeValue(attribute: "src", in: tag)?
            .trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty {
            return canonicalImageURLString(raw, baseURL: baseURL)
        }
        return nil
    }

    private static func firstHTTPURL(inSrcset srcset: String, baseURL: URL?) -> String? {
        let parts = srcset.split(separator: ",")
        for part in parts {
            let trimmed = part.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let firstToken = trimmed.split(whereSeparator: { $0.isWhitespace }).map(String.init).first ?? trimmed
            if let u = canonicalImageURLString(String(firstToken), baseURL: baseURL) {
                return u
            }
        }
        return nil
    }

    private static func canonicalImageURLString(_ raw: String, baseURL: URL?) -> String? {
        var t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        t = decodeBasicHTMLEntities(t)
        guard !t.isEmpty else { return nil }
        let lower = t.lowercased()
        if lower.hasPrefix("data:") || lower.hasPrefix("javascript:") { return nil }
        if lower.hasPrefix("//") {
            t = "https:" + t
        }
        if let u = URL(string: t), let scheme = u.scheme?.lowercased(), scheme.hasPrefix("http") {
            return u.absoluteString
        }
        if t.hasPrefix("/"), let base = baseURL, let u = URL(string: t, relativeTo: base),
           let scheme = u.scheme?.lowercased(), scheme.hasPrefix("http") {
            return u.absoluteString
        }
        if !t.contains("://"), t.contains("."), t.hasPrefix("www.") {
            return canonicalImageURLString("https://" + t, baseURL: baseURL)
        }
        return nil
    }

    private static func decodeBasicHTMLEntities(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&nbsp;", with: " ")
    }

    // MARK: - Markdown post-process

    private static let fullscreenLineFingerprints: Set<String> = [
        "view image in fullscreen",
        "open image in fullscreen",
        "view fullscreen",
        "full screen image",
        "tap to expand image",
        "tap to expand",
        "click to view larger image",
    ]

    /// Removes standalone UI lines (often left after HTML strip) and blocks that are only that label.
    private static func stripFullscreenNoiseFromMarkdown(_ markdown: String) -> String {
        let blocks = markdown.components(separatedBy: "\n\n")
        var out: [String] = []
        for block in blocks {
            let trimmed = block.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }

            let nonEmptyLines = trimmed.split(separator: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            if nonEmptyLines.count == 1,
               fullscreenLineFingerprints.contains(lineFingerprint(String(nonEmptyLines[0]))) {
                continue
            }

            let lines = trimmed.components(separatedBy: "\n")
            let kept: [String] = lines.compactMap { raw in
                let L = raw.trimmingCharacters(in: .whitespaces)
                if L.isEmpty { return nil }
                if fullscreenLineFingerprints.contains(lineFingerprint(L)) { return nil }
                return raw.trimmingCharacters(in: .whitespaces)
            }
            guard !kept.isEmpty else { continue }
            out.append(kept.joined(separator: "\n"))
        }
        return out.joined(separator: "\n\n")
    }

    private static func lineFingerprint(_ line: String) -> String {
        fingerprint(block: line)
    }

    /// Drops any paragraph / heading block that matches the article title (header already shows it).
    private static func stripAllBlocksMatchingTitle(markdown: String, title: String?) -> String {
        guard let title = title?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else { return markdown }
        let nTitle = fingerprint(block: title)
        let blocks = markdown.components(separatedBy: "\n\n")
        var out: [String] = []
        for block in blocks {
            let trimmed = block.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }
            var rest = trimmed
            while rest.hasPrefix("#") {
                rest = String(rest.dropFirst()).trimmingCharacters(in: .whitespaces)
            }
            if fingerprint(block: rest) == nTitle { continue }
            out.append(trimmed)
        }
        return out.joined(separator: "\n\n")
    }

    private static func stripLeadingTitleEcho(markdown: String, title: String?) -> String {
        guard let title = title?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else { return markdown }
        var blocks = markdown.components(separatedBy: "\n\n")
        let nTitle = fingerprint(block: title)

        func stripHashes(_ s: String) -> String {
            var rest = s.trimmingCharacters(in: .whitespacesAndNewlines)
            while rest.hasPrefix("#") {
                rest = String(rest.dropFirst()).trimmingCharacters(in: .whitespaces)
            }
            return rest
        }

        var safety = 0
        while safety < 12, let first = blocks.first {
            let trimmedHead = first.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedHead.isEmpty {
                blocks.removeFirst()
                safety += 1
                continue
            }
            let fp = fingerprint(block: stripHashes(first))
            if fp == nTitle || fp.isEmpty {
                blocks.removeFirst()
                safety += 1
                continue
            }
            break
        }
        return blocks.joined(separator: "\n\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func collapseMarkdownDuplicateBlocks(_ markdown: String) -> String {
        let blocks = markdown.components(separatedBy: "\n\n")
        var out: [String] = []
        var lastPrinted: String?
        for b in blocks {
            let trimmed = b.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }
            let fp = fingerprint(block: trimmed)
            if fp == lastPrinted { continue }
            out.append(trimmed)
            lastPrinted = fp
        }
        return out.joined(separator: "\n\n")
    }

    /// When `![caption](url)` is immediately followed by the same caption as body text, drop the redundant paragraph.
    private static func collapseImageCaptionEcho(_ markdown: String) -> String {
        let blocks = markdown.components(separatedBy: "\n\n")
        guard blocks.count >= 2 else { return markdown }
        var out: [String] = []
        var i = 0
        let imageLine = try? NSRegularExpression(pattern: #"^!\[([^\]]*)\]\([^)]+\)\s*$"#, options: [])
        while i < blocks.count {
            let b = blocks[i].trimmingCharacters(in: .whitespacesAndNewlines)
            let range = NSRange(b.startIndex..<b.endIndex, in: b)
            if i + 1 < blocks.count, imageLine != nil {
                let next = blocks[i + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                if let m = imageLine?.firstMatch(in: b, options: [], range: range),
                   m.numberOfRanges > 1,
                   let r = Range(m.range(at: 1), in: b) {
                    let alt = String(b[r]).trimmingCharacters(in: .whitespacesAndNewlines)
                    if !alt.isEmpty, fingerprint(block: alt) == fingerprint(block: next) {
                        out.append(blocks[i].trimmingCharacters(in: .whitespacesAndNewlines))
                        i += 2
                        continue
                    }
                }
            }
            out.append(blocks[i].trimmingCharacters(in: .whitespacesAndNewlines))
            i += 1
        }
        return out.joined(separator: "\n\n")
    }

    private static func fingerprint(block: String) -> String {
        var b = block
        b = b.replacingOccurrences(of: "\u{2019}", with: "'")
        b = b.replacingOccurrences(of: "\u{2018}", with: "'")
        b = b.replacingOccurrences(of: "\u{201c}", with: "\"")
        b = b.replacingOccurrences(of: "\u{201d}", with: "\"")
        b = b.replacingOccurrences(of: "\u{2013}", with: "-")
        b = b.replacingOccurrences(of: "\u{2014}", with: "-")
        return b
            .lowercased()
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func attributeValue(attribute: String, in tag: String) -> String? {
        guard let sepRange = tag.range(of: "\(attribute)=", options: .caseInsensitive) else { return nil }
        var rest = tag[sepRange.upperBound...]
        while let c = rest.first, c.isWhitespace {
            rest = rest.dropFirst()
        }
        guard let delim = rest.first else { return nil }
        switch delim {
        case "\"":
            rest = rest.dropFirst()
            guard let end = rest.firstIndex(of: "\"") else { return "" }
            return String(rest[..<end])
        case "'":
            rest = rest.dropFirst()
            guard let end = rest.firstIndex(of: "'") else { return "" }
            return String(rest[..<end])
        default:
            let endIdx = rest.firstIndex(where: { $0.isWhitespace || $0 == ">" }) ?? rest.endIndex
            return String(rest[..<endIdx])
        }
    }
}
