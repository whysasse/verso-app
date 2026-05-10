import Foundation
import CoreData

@objc(Article)
public class Article: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var filePath: String
    @NSManaged public var title: String
    @NSManaged public var url: URL?
    @NSManaged public var status: String
    @NSManaged public var dateAdded: Date
    @NSManaged public var source: String?
    /// Display byline when available (FAB-144); empty means fall back to `siteName` / host.
    @NSManaged public var author: String?
    /// Publication / site label (e.g. from Readability siteName).
    @NSManaged public var siteName: String?
}

extension Article {
    enum Status: String, CaseIterable {
        case unread
        case reading
        case read
        case archived
    }

    var statusEnum: Status {
        get { Status(rawValue: status) ?? .unread }
        set { status = newValue.rawValue }
    }

    static func create(
        in context: NSManagedObjectContext,
        id: UUID = UUID(),
        filePath: String,
        title: String,
        url: URL? = nil,
        status: Status = .unread,
        dateAdded: Date = Date(),
        source: String? = nil,
        author: String? = nil,
        siteName: String? = nil
    ) -> Article {
        let article = Article(context: context)
        article.id = id
        article.filePath = filePath
        article.title = title
        article.url = url
        article.status = status.rawValue
        article.dateAdded = dateAdded
        article.source = source
        article.author = author
        article.siteName = siteName
        return article
    }

    /// Text below the title when the raw URL must not appear (FAB-144).
    var readerPublicationFallback: String {
        if let s = siteName?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty { return s }
        guard let host = url?.host else { return source?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    /// FAB-144: Value after `By …` — plain names pass through; `http(s)://…` profile links become a derived name when possible; otherwise nil (use `readerPublicationFallback`).
    var readerDisplayAuthor: String? {
        guard let raw = author?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        guard let authorURL = Self.normalizedHTTPURL(from: raw) else { return raw }
        return Self.extractByline(from: authorURL)
    }

    /// Best-effort `URL` when `author` stores an absolute web link (`https://site/...` or legacy `www.…`).
    private static func normalizedHTTPURL(from raw: String) -> URL? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = t.lowercased()
        if lower.hasPrefix("http://") || lower.hasPrefix("https://") {
            return URL(string: t)
        }
        if lower.hasPrefix("www.") {
            return URL(string: "https://" + t)
        }
        return nil
    }

    private static func extractByline(from url: URL) -> String? {
        guard ["http", "https"].contains(url.scheme?.lowercased() ?? "") else { return nil }
        let path = URLComponents(url: url, resolvingAgainstBaseURL: false)?.path ?? url.path
        let segments = PathComponents.skipSlugTerms(for: path)
        for seg in segments.reversed() {
            if let name = slugToPossibleDisplayName(seg) {
                return name
            }
        }
        return nil
    }

    private enum PathComponents {
        static func skipSlugTerms(for path: String) -> [String] {
            let comps = path.split(separator: "/").map(String.init).filter { !$0.isEmpty }
            let skips: Set<String> = ["profile", "profiles", "author", "authors", "contributors", "writer", "writers", "people", "journalist", "journalists", "staff", "bio", "user", "users", "topics", "section", "tag", "tags", "interactive", "wiki"]
            var out: [String] = []
            let dotTrim = CharacterSet(charactersIn: ".")
            for c in comps {
                let key = c.lowercased().trimmingCharacters(in: dotTrim)
                if skips.contains(key) { continue }
                out.append(c)
            }
            return out
        }
    }

    private static let slugLetters = CharacterSet.letters

    private static func slugToPossibleDisplayName(_ rawSlug: String) -> String? {
        var slug = rawSlug.lowercased()
        if slug.hasSuffix(".htm") || slug.hasSuffix(".html") {
            slug = String(slug.dropLast(slug.hasSuffix(".html") ? 5 : 4))
        }
        slug = slug.replacingOccurrences(of: "_", with: "-")
        slug = slug.trimmingCharacters(in: CharacterSet(charactersIn: ".- "))
        guard !slug.isEmpty, slug.rangeOfCharacter(from: slugLetters) != nil else { return nil }
        if slug.allSatisfy({ $0.isWholeNumber || $0 == "-" }) {
            return nil
        }
        let parts = slug.split(separator: "-").map(String.init).filter { !$0.isEmpty }
        guard !parts.isEmpty else { return nil }
        guard parts.allSatisfy({ $0.rangeOfCharacter(from: slugLetters) != nil }) else { return nil }
        return parts.map { part in
            part.prefix(1).uppercased() + part.dropFirst().lowercased()
        }.joined(separator: " ")
    }
}
