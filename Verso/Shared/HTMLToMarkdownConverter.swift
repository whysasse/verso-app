import Foundation

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
        "press enter or click to view image in full size",
        "member-only story",
        "listen",
        "share",
        "follow",
        "sign up",
        "sign in",
        "featured",
    ]

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
    /// only separator punctuation, or a "N min read" label.
    private static func isNoiseLine(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return true }
        if fullscreenLineFingerprints.contains(lineFingerprint(trimmed)) { return true }
        let range = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
        if let re = digitsOnlyPattern, re.firstMatch(in: trimmed, options: [], range: range) != nil { return true }
        if let re = punctuationOnlyPattern, re.firstMatch(in: trimmed, options: [], range: range) != nil { return true }
        if let re = minReadPattern, re.firstMatch(in: trimmed, options: [], range: range) != nil { return true }
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
