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
            let contentMarkdown = try extractContentMarkdown(from: doc, articleTitle: title)
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

    private static func extractContentMarkdown(from doc: Document, articleTitle: String?) throws -> String {
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

        let rawMarkdown = htmlToMarkdown(element)
        // Run the same cleanup pass the in-app Readability path already gets
        // (title-echo removal, duplicate-block collapse, UI-label line filtering)
        // so the Share Extension's thinner SwiftSoup path isn't a second, worse-cleaned
        // code path (FAB-294).
        return HTMLToMarkdownConverter.sanitizeMarkdownBody(rawMarkdown, articleTitle: articleTitle)
    }

    private static func htmlToMarkdown(_ element: Element) -> String {
        var lines: [String] = []
        collectLines(from: element, into: &lines)
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

    private static func collectLines(from node: Node, into lines: inout [String]) {
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
                case "ul", "ol", "div", "section":
                    collectLines(from: element, into: &lines)
                    lines.append("")
                default:
                    collectLines(from: element, into: &lines)
                }
            }
        }
    }
}
