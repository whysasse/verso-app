import Foundation
import SwiftSoup

// MARK: - Minimal HTML → Markdown converter (shared use)

enum HTMLToMarkdownConverter {
    /// Structural noise to drop before any text extraction -- chrome that sits inside the
    /// content container itself (so it isn't caught by Readability's own boilerplate removal,
    /// nor by `SwiftSoupParser`'s content-container selection), not just decorative wrappers.
    /// Single source of truth for both import paths (FAB-300): `SwiftSoupParser`'s own DOM walk
    /// and this file's `convert()` both select on this, so a gap found in one is fixed in both.
    ///
    /// `[data-print-layout="hide"]` (FAB-300): Guardian marks its "Explore more on these topics" /
    /// Share / "Reuse this content" block this way -- a genuine semantic attribute ("hide in the
    /// print stylesheet"), unlike Guardian's `dcr-*` classes, which are hashed CSS-in-JS output
    /// and not safe to select on.
    static let noiseSelector = "script, style, nav, header, footer, aside, "
        + "[role=navigation], [role=banner], [role=complementary], "
        + "button, form, noscript, svg, iframe, figure figcaption > button, "
        + "[role=button], [aria-hidden=true], "
        + "[data-testid*=audio], [data-testid*=headerClap], [data-testid*=headerSocial], "
        + "[data-print-layout=hide]"

    /// Removes `noiseSelector` matches via a real DOM parse, returning the cleaned body's inner
    /// HTML. Falls back to the original `html` unchanged if parsing fails, so a malformed
    /// fragment degrades to today's (pre-FAB-300) behavior rather than losing all content.
    private static func removeStructuralNoise(from html: String, baseURL: URL?) -> String {
        guard let doc = try? SwiftSoup.parse(html, baseURL?.absoluteString ?? "") else { return html }
        guard (try? doc.select(noiseSelector).remove()) != nil else { return html }
        return (try? doc.body()?.html()) ?? html
    }

    /// Very lightweight conversion: strips tags and preserves block structure.
    /// For a richer conversion SwiftSoupParser handles the full traversal.
    static func convert(_ html: String, articleTitle: String? = nil, baseURL: URL? = nil) -> String {
        var text = removeStructuralNoise(from: html, baseURL: baseURL)
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
    /// Internal (not `private`) so `SwiftSoupParser` can reuse it for the same sanitization
    /// on the Share Extension's own emitted image lines (FAB-295).
    static func markdownSafeAltText(_ raw: String) -> String {
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
        let work = NSMutableString(string: html)
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

    /// Internal (not `private`) so `SwiftSoupParser` can reuse the same "best of `<source
    /// srcset>` / `<img>`" resolution for `<picture>` elements it encounters directly in the DOM
    /// (FAB-295), rather than re-deriving this priority order a second time.
    static func bestImageURLAndAlt(inHTMLFragment inner: String, baseURL: URL?) -> (url: String, alt: String)? {
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

    /// Internal (not `private`) so `SwiftSoupParser` can reuse this exact src/srcset/lazy-load
    /// priority order for `<img>` elements it encounters directly in the DOM (FAB-295) — pass
    /// `element.outerHtml()` as `tag` rather than re-deriving the same resolution logic.
    static func resolvedHTTPImageURL(forImgTag tag: String, baseURL: URL?) -> String? {
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
        "press enter or click to view image in full size",
        "member-only story",
        "listen",
        "share",
        "follow",
        "sign up",
        "sign in",
        "featured",
        // FAB-332: the "Link Copied!" affordance text left behind by a share button, when it
        // survives as its own standalone line rather than folded into a share-bar run below.
        "link copied!",
    ]

    /// FAB-332: individual tokens that make up a publisher share bar -- platform names, share
    /// actions, and the "copied" confirmation state. Several of these (`link`, `copy`, `email`)
    /// are ordinary words on their own, so a line only counts as a share bar via `isShareBarLine`
    /// below when *most* of its words are drawn from this set *and* at least one is an
    /// unambiguous platform name from `shareBarPlatformTokens`.
    private static let shareBarTokens: Set<String> = [
        "facebook", "twitter", "tweet", "x", "email", "mail", "link", "threads",
        "whatsapp", "reddit", "pinterest", "linkedin", "messenger", "flipboard",
        "print", "share", "copy", "copied", "sms", "instagram", "tumblr", "telegram",
    ]

    /// Platform names within `shareBarTokens` that can't plausibly appear in ordinary prose --
    /// the anchor that keeps `isShareBarLine` from flagging a real sentence that merely
    /// contains a generic word like "link" or "share".
    private static let shareBarPlatformTokens: Set<String> = [
        "facebook", "twitter", "tweet", "x", "threads", "whatsapp", "reddit",
        "pinterest", "linkedin", "messenger", "flipboard", "instagram", "tumblr", "telegram",
    ]

    /// True for a short line that reads as a flattened social-share bar -- e.g. "Facebook Tweet
    /// Email Link Threads Link Copied!" (FAB-332, seen on a CNN article). Publisher share
    /// buttons often have no separator between them once tags are stripped, so this becomes one
    /// run-on line rather than one noise line per button. Matched by ratio (most words are known
    /// share tokens) rather than an exact fingerprint, since the set of buttons varies by
    /// publisher and page -- gated on at least one unambiguous platform-name token so an
    /// ordinary short sentence containing "link" isn't swept up (see
    /// `testOrdinarySentenceContainingLinkIsNotTreatedAsShareBar`).
    private static func isShareBarLine(_ line: String) -> Bool {
        let words = line.split(whereSeparator: { $0.isWhitespace })
        guard words.count >= 2, words.count <= 12 else { return false }
        let normalized = words.map {
            $0.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "!.,:;"))
        }
        let matchCount = normalized.filter { shareBarTokens.contains($0) }.count
        guard Double(matchCount) / Double(normalized.count) >= 0.7 else { return false }
        return normalized.contains { shareBarPlatformTokens.contains($0) }
    }

    /// Case-insensitive regex for standalone "N min read" labels (with or without a trailing " · ").
    private static let minReadPattern: NSRegularExpression? = try? NSRegularExpression(
        pattern: #"^\d+\s*min read\s*·?$"#,
        options: [.caseInsensitive]
    )

    /// Separator-only lines left behind between stripped UI elements, e.g. "–", "·", "—".
    private static let punctuationOnlyPattern: NSRegularExpression? = try? NSRegularExpression(
        pattern: #"^[\s\-–—·•]+$"#,
        options: []
    )

    private static let digitsOnlyPattern: NSRegularExpression? = try? NSRegularExpression(
        pattern: #"^\d+$"#,
        options: []
    )

    /// True for a line that is pure noise on its own: a known UI-label fingerprint, only digits,
    /// only separator punctuation, or a "N min read" label. Internal (not `private`) so
    /// `SwiftSoupParser` can screen a `<figcaption>` before promoting it to an image's alt text
    /// (FAB-295) — a lightbox label like "Press enter or click to view image in full size" must
    /// not become a visible caption just because it happened to sit in a `<figcaption>`.
    static func isNoiseLine(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return true }
        if fullscreenLineFingerprints.contains(lineFingerprint(trimmed)) { return true }
        let range = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
        if let re = digitsOnlyPattern, re.firstMatch(in: trimmed, options: [], range: range) != nil { return true }
        if let re = punctuationOnlyPattern, re.firstMatch(in: trimmed, options: [], range: range) != nil { return true }
        if let re = minReadPattern, re.firstMatch(in: trimmed, options: [], range: range) != nil { return true }
        if isShareBarLine(trimmed) { return true }
        return false
    }

    /// Removes standalone UI lines (often left after HTML strip) and blocks that are only that label.
    private static func stripFullscreenNoiseFromMarkdown(_ markdown: String) -> String {
        let blocks = markdown.components(separatedBy: "\n\n")
        var out: [String] = []
        for block in blocks {
            let trimmed = block.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }

            let nonEmptyLines = trimmed.split(separator: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            if nonEmptyLines.count == 1, isNoiseLine(String(nonEmptyLines[0])) {
                continue
            }

            let lines = trimmed.components(separatedBy: "\n")
            let kept: [String] = lines.compactMap { raw in
                let L = raw.trimmingCharacters(in: .whitespaces)
                if L.isEmpty { return nil }
                if isNoiseLine(L) { return nil }
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

    /// Credit-line prefixes publishers commonly append to an echoed caption paragraph -- e.g.
    /// "…in the 1960s. Photograph: João Laet/The Guardian" (FAB-315). Matched against the
    /// fingerprinted (lowercased) remainder, so case doesn't matter.
    private static let imageCaptionCreditPrefixes = ["photograph:", "photo:", "credit:", "illustration:"]

    /// Leading punctuation left behind between the alt text and an appended credit once the alt
    /// text's own prefix is dropped -- e.g. the "." in "...1960s. Photograph: X" -- plus
    /// whitespace, so `imageCaptionCreditPrefixes` sees a clean "photograph:" start.
    private static let captionEchoRemainderTrimSet = CharacterSet.whitespaces.union(CharacterSet(charactersIn: ".,;:–—-"))

    /// True when `paragraph` is just the image's alt text/caption echoed back as body text --
    /// either an exact repeat, or the same text with a short publisher credit appended
    /// ("<alt> Photograph: X"). FAB-315: the original exact-match check missed the Guardian
    /// case because the echoed paragraph isn't identical to the alt text, it's the alt text
    /// plus a credit. Only a short remainder (e.g. trailing punctuation) or one starting with a
    /// recognized credit prefix counts -- a paragraph that merely *starts* with the same words
    /// before continuing into unrelated content must not be collapsed.
    static func isImageCaptionEcho(alt: String, followingParagraph paragraph: String) -> Bool {
        let altFP = fingerprint(block: alt)
        guard !altFP.isEmpty else { return false }
        let paragraphFP = fingerprint(block: paragraph)
        if altFP == paragraphFP { return true }
        guard paragraphFP.hasPrefix(altFP) else { return false }
        let remainder = String(paragraphFP.dropFirst(altFP.count)).trimmingCharacters(in: captionEchoRemainderTrimSet)
        if remainder.isEmpty || remainder.count <= 3 { return true }
        return imageCaptionCreditPrefixes.contains { remainder.hasPrefix($0) }
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
                    if !alt.isEmpty, isImageCaptionEcho(alt: alt, followingParagraph: next) {
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

    /// Separators publishers use to append their own name to a page `<title>` for SEO -- not
    /// something that belongs in the reader's H1/top bar/article card (FAB-332).
    private static let publisherTitleSeparators = [" | ", " — ", " – ", " - "]

    /// Strips a trailing ` | <site>` / ` - <site>` / ` — <site>` from `title` when `<site>`
    /// matches the article's `siteName` or its URL `host` -- e.g. "God save the drag kings of
    /// England | CNN" → "God save the drag kings of England". Deliberately conservative: a
    /// title is only trimmed when the tail after the separator can be tied back to *this*
    /// publisher, so a title that legitimately contains a pipe or dash (e.g. a subtitle) is left
    /// alone. Called once at parse time (`SwiftSoupParser`, `ReadabilityParser`) so the card, the
    /// top bar, and the H1 -- which all render the same stored `title` -- benefit from one fix.
    static func stripPublisherTitleSuffix(_ title: String, siteName: String?, host: String?) -> String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return trimmedTitle }
        for separator in publisherTitleSeparators {
            guard let range = trimmedTitle.range(of: separator, options: .backwards) else { continue }
            let head = String(trimmedTitle[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            let tail = String(trimmedTitle[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            guard !head.isEmpty, !tail.isEmpty else { continue }
            if titleSuffixMatchesPublisher(tail, siteName: siteName, host: host) {
                return head
            }
        }
        return trimmedTitle
    }

    private static func titleSuffixMatchesPublisher(_ tail: String, siteName: String?, host: String?) -> Bool {
        let normalizedTail = fingerprint(block: tail)
        guard normalizedTail.count >= 2 else { return false }
        if let siteName {
            let normalizedSite = fingerprint(block: siteName)
            if !normalizedSite.isEmpty, normalizedSite == normalizedTail { return true }
        }
        if let host {
            var bareHost = host.lowercased()
            if bareHost.hasPrefix("www.") { bareHost = String(bareHost.dropFirst(4)) }
            // Letters-only containment (not "does the first label match") so a subdomain like
            // "edition.cnn.com" or a co.uk-style host still matches "CNN" without trying to
            // isolate a single "root" label -- publication hosts vary too much for that to be
            // reliable in general.
            let hostLetters = bareHost.filter(\.isLetter)
            let tailLetters = normalizedTail.filter(\.isLetter)
            if !tailLetters.isEmpty, hostLetters.contains(tailLetters) { return true }
        }
        return false
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
