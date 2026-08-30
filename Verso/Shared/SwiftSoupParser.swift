import Foundation
import SwiftSoup
import OSLog

private let logger = Logger(subsystem: "com.fabiosasseron.verso", category: "parsing")

struct SwiftSoupParser {

    /// Parses raw HTML into a `PendingArticle`.
    /// - Parameters:
    ///   - html: The full HTML string of the page.
    ///   - url: The source URL (used for the article record and error reporting).
    /// - Throws: `ArticleParsingError.swiftSoupFailed` if content extraction fails.
    static func parse(html: String, url: URL) throws -> PendingArticle {
        do {
            let doc = try SwiftSoup.parse(html, url.absoluteString)

            let title = try extractTitle(from: doc, url: url)
            let contentMarkdown = try extractContentMarkdown(from: doc, articleTitle: title, baseURL: url)
            let author = extractAuthor(from: doc)
            let siteName = extractSiteLabel(from: doc)

            return PendingArticle(
                id: UUID(),
                url: url,
                title: title,
                contentMarkdown: contentMarkdown,
                dateAdded: Date(),
                author: author,
                siteName: siteName
            )
        } catch let error as ArticleParsingError {
            throw error
        } catch {
            logger.warning("SwiftSoup failed for \(url.absoluteString, privacy: .public): \(error.localizedDescription, privacy: .public)")
            throw ArticleParsingError.swiftSoupFailed(url)
        }
    }

    // MARK: - Private

    private static func extractTitle(from doc: Document, url: URL) throws -> String {
        if let ogTitle = try? doc.select("meta[property=og:title]").first()?.attr("content"),
           !ogTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return ogTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let h1 = try? doc.select("h1").first()?.text(),
           !h1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return h1.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let title = try? doc.title(),
           !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return title.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return url.host ?? url.absoluteString
    }

    /// Best-effort author / attribution from `<meta>` tags.
    private static func extractAuthor(from doc: Document) -> String? {
        let selectors = [
            "meta[property=article:author]",
            "meta[property=article:author:name]",
            "meta[name=author]",
            "meta[name=byl]",
            "meta[property=dc:creator]",
        ]
        return firstNonEmptyMetaContent(doc: doc, selectors: selectors)
    }

    private static func extractSiteLabel(from doc: Document) -> String? {
        let selectors = ["meta[property=og:site_name]", "meta[property=twitter:site]"]
        guard let raw = firstNonEmptyMetaContent(doc: doc, selectors: selectors) else { return nil }
        var s = raw
        if s.hasPrefix("@") { s = String(s.dropFirst()) }
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func firstNonEmptyMetaContent(doc: Document, selectors: [String]) -> String? {
        for sel in selectors {
            guard let raw = try? doc.select(sel).first()?.attr("content") else { continue }
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { return trimmed }
        }
        return nil
    }

    private static func extractContentMarkdown(from doc: Document, articleTitle: String?, baseURL: URL?) throws -> String {
        // Remove noise elements before extracting text. Beyond the obvious page-chrome
        // tags, this also drops interactive/toolbar elements (buttons, forms, embedded
        // SVG icons) and known audio/clap/social-share widget containers that Medium
        // and similar sites nest directly inside <article> (FAB-294).
        let noiseSelector = "script, style, nav, header, footer, aside, "
            + "[role=navigation], [role=banner], [role=complementary], "
            + "button, form, noscript, svg, iframe, figure figcaption > button, "
            + "[role=button], [aria-hidden=true], "
            + "[data-testid*=audio], [data-testid*=headerClap], [data-testid*=headerSocial]"
        try doc.select(noiseSelector).remove()

        // Prefer semantic content containers
        let contentElement: Element?
        if let article = try doc.select("article").first() {
            contentElement = article
        } else if let main = try doc.select("main, [role=main]").first() {
            contentElement = main
        } else {
            contentElement = try doc.select("body").first()
        }

        guard let element = contentElement else {
            return ""
        }

        let rawMarkdown = htmlToMarkdown(element, baseURL: baseURL)
        // Run the same cleanup pass the in-app Readability path already gets
        // (title-echo removal, duplicate-block collapse, UI-label line filtering)
        // so the Share Extension's thinner SwiftSoup path isn't a second, worse-cleaned
        // code path (FAB-294).
        return HTMLToMarkdownConverter.sanitizeMarkdownBody(rawMarkdown, articleTitle: articleTitle)
    }

    private static func htmlToMarkdown(_ element: Element, baseURL: URL?) -> String {
        var lines: [String] = []
        collectLines(from: element, into: &lines, baseURL: baseURL)
        // Collapse more than two consecutive blank lines
        var result: [String] = []
        var blankRun = 0
        for line in lines {
            if line.isEmpty {
                blankRun += 1
                if blankRun <= 1 { result.append("") }
            } else {
                blankRun = 0
                result.append(line)
            }
        }
        return result.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func collectLines(from node: Node, into lines: inout [String], baseURL: URL?) {
        for child in node.getChildNodes() {
            // Bare text nodes are intentionally not emitted here (FAB-294). Recursing
            // into an unhandled wrapper tag (button, span, figcaption, …) used to
            // surface every text node it walked past as its own line, which is how
            // page chrome (toolbar labels, tag lists) leaked into the saved body.
            // p/li/h1–h6/blockquote/pre/code/td/th below are the only text-emitting
            // cases; anything else only contributes structure via recursion.
            if let element = child as? Element {
                let tag = element.tagName().lowercased()
                switch tag {
                case "h1":
                    if let text = try? element.text(), !text.isEmpty {
                        lines.append("# \(text)")
                        lines.append("")
                    }
                case "h2":
                    if let text = try? element.text(), !text.isEmpty {
                        lines.append("## \(text)")
                        lines.append("")
                    }
                case "h3":
                    if let text = try? element.text(), !text.isEmpty {
                        lines.append("### \(text)")
                        lines.append("")
                    }
                case "h4", "h5", "h6":
                    if let text = try? element.text(), !text.isEmpty {
                        lines.append("#### \(text)")
                        lines.append("")
                    }
                case "p":
                    if let text = try? element.text(), !text.isEmpty {
                        lines.append(text)
                        lines.append("")
                    }
                case "br":
                    lines.append("")
                case "li":
                    if let text = try? element.text(), !text.isEmpty {
                        lines.append("- \(text)")
                    }
                case "blockquote":
                    if let text = try? element.text(), !text.isEmpty {
                        lines.append("> \(text)")
                        lines.append("")
                    }
                case "pre", "code":
                    if let text = try? element.text(), !text.isEmpty {
                        lines.append("```")
                        lines.append(text)
                        lines.append("```")
                        lines.append("")
                    }
                case "hr":
                    lines.append("---")
                    lines.append("")
                case "td", "th":
                    // No GFM table rendering yet (FAB-293) — keep cell text as a loose
                    // line rather than losing it outright now that bare text nodes
                    // are no longer emitted.
                    if let text = try? element.text(), !text.isEmpty {
                        lines.append(text)
                    }
                case "img":
                    // FAB-295: bare <img>, e.g. a hero image sitting directly under
                    // <article>/<div> rather than wrapped in <figure>.
                    if let resolved = resolvedImageAltAndURL(fromImgElement: element, baseURL: baseURL) {
                        lines.append("")
                        lines.append("![\(resolved.alt)](\(resolved.url))")
                        lines.append("")
                    }
                case "picture":
                    // FAB-295: Guardian-style <picture><source srcset>…<img></picture>, not
                    // wrapped in <figure>.
                    if let resolved = resolvedImageAltAndURL(fromPictureElement: element, baseURL: baseURL) {
                        lines.append("")
                        lines.append("![\(resolved.alt)](\(resolved.url))")
                        lines.append("")
                    }
                case "figure":
                    // FAB-295: prefer a nested <picture>, else a nested <img>; the figcaption (if
                    // any) becomes the caption/alt. A figure that isn't wrapping an image at all
                    // (e.g. a code sample) falls back to normal recursion so its content isn't
                    // silently dropped.
                    if let markdownLine = imageMarkdownLine(fromFigureElement: element, baseURL: baseURL) {
                        lines.append("")
                        lines.append(markdownLine)
                        lines.append("")
                    } else {
                        collectLines(from: element, into: &lines, baseURL: baseURL)
                        lines.append("")
                    }
                case "ul", "ol", "div", "section":
                    collectLines(from: element, into: &lines, baseURL: baseURL)
                    lines.append("")
                default:
                    collectLines(from: element, into: &lines, baseURL: baseURL)
                }
            }
        }
    }

    // MARK: - Images (FAB-295)

    /// Skips 1px tracking beacons and avatar-sized icons, but only when the element declares
    /// explicit `width`/`height` attributes that say so — an image with no declared dimensions
    /// is never skipped by this check.
    private static func isLikelyTrackingOrAvatarImage(_ element: Element) -> Bool {
        guard let w = try? element.attr("width"), let h = try? element.attr("height"),
              let wi = Int(w.trimmingCharacters(in: .whitespaces)),
              let hi = Int(h.trimmingCharacters(in: .whitespaces)) else {
            return false
        }
        return wi < 100 && hi < 100
    }

    /// Resolves a bare `<img>` element's best URL by reusing
    /// `HTMLToMarkdownConverter.resolvedHTTPImageURL`'s exact src/srcset/lazy-load priority order
    /// (via `outerHtml()`, so SwiftSoup's own serializer produces the tag string — no manual
    /// attribute-escaping to get wrong) rather than re-deriving that logic here.
    private static func resolvedImageAltAndURL(fromImgElement element: Element, baseURL: URL?) -> (alt: String, url: String)? {
        guard !isLikelyTrackingOrAvatarImage(element) else { return nil }
        let tag = (try? element.outerHtml()) ?? ""
        guard let resolved = HTMLToMarkdownConverter.resolvedHTTPImageURL(forImgTag: tag, baseURL: baseURL) else {
            return nil
        }
        let altRaw = (try? element.attr("alt"))?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return (HTMLToMarkdownConverter.markdownSafeAltText(altRaw), resolved)
    }

    /// Resolves a `<picture>` element by reusing
    /// `HTMLToMarkdownConverter.bestImageURLAndAlt`'s "best of `<source srcset>` / `<img>`" logic
    /// against the element's own inner HTML.
    private static func resolvedImageAltAndURL(fromPictureElement element: Element, baseURL: URL?) -> (alt: String, url: String)? {
        guard let inner = try? element.html(),
              let pair = HTMLToMarkdownConverter.bestImageURLAndAlt(inHTMLFragment: inner, baseURL: baseURL) else {
            return nil
        }
        return (HTMLToMarkdownConverter.markdownSafeAltText(pair.alt), pair.url)
    }

    /// Builds one `![alt](url)` line for a `<figure>`: prefers a nested `<picture>`, else a
    /// nested `<img>`; a non-empty `<figcaption>` overrides whatever alt text the image itself
    /// carried, matching editorial intent (publishers often leave `img alt` empty and put the
    /// real caption in `<figcaption>`). Returns `nil` when the figure has no resolvable image at
    /// all, so the caller can fall back to normal recursion instead of dropping the figure's
    /// content.
    private static func imageMarkdownLine(fromFigureElement element: Element, baseURL: URL?) -> String? {
        var resolved: (alt: String, url: String)?
        if let picture = try? element.select("picture").first() {
            resolved = resolvedImageAltAndURL(fromPictureElement: picture, baseURL: baseURL)
        } else if let img = try? element.select("img").first() {
            resolved = resolvedImageAltAndURL(fromImgElement: img, baseURL: baseURL)
        }
        guard let resolved else { return nil }

        let captionRaw = (try? element.select("figcaption").first()?.text())?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        // A figcaption that's actually lightbox/UI chrome (e.g. "Press enter or click to view
        // image in full size") must not be promoted to a visible caption just because it sat in
        // a <figcaption> tag — screen it with the same noise check FAB-294 uses for body text.
        let useCaption = !captionRaw.isEmpty && !HTMLToMarkdownConverter.isNoiseLine(captionRaw)
        let alt = useCaption ? HTMLToMarkdownConverter.markdownSafeAltText(captionRaw) : resolved.alt
        return "![\(alt)](\(resolved.url))"
    }
}
