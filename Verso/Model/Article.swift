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
}
