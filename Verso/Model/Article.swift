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
        source: String? = nil
    ) -> Article {
        let article = Article(context: context)
        article.id = id
        article.filePath = filePath
        article.title = title
        article.url = url
        article.status = status.rawValue
        article.dateAdded = dateAdded
        article.source = source
        return article
    }
}
