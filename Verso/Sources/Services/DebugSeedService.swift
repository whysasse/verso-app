#if DEBUG
import CoreData
import Foundation

enum DebugSeedService {

    private static let expectedCount = 13

    static func seedIfNeeded(context: NSManagedObjectContext) {
        let request = NSFetchRequest<Article>(entityName: "Article")
        guard (try? context.count(for: request)) ?? 0 < expectedCount else { return }

        // Wipe whatever partial seed exists so we start clean
        if let existing = try? context.fetch(request) {
            existing.forEach { context.delete($0) }
        }

        let sampleDir = sampleArticlesDirectory()
        let articles: [(file: String, title: String, source: String, url: String, status: Article.Status, daysAgo: Int)] = [
            ("the-case-for-slow-reading.md", "The Case for Slow Reading", "The Atlantic", "https://www.theatlantic.com/ideas/archive/2023/11/slow-reading-attention-focus/675867/", .unread, 8),
            ("why-your-phone-is-changing-your-brain.md", "Why Your Phone Is Changing Your Brain (And What to Do About It)", "The New Yorker", "https://www.newyorker.com/science/annals-of-technology/what-smartphones-are-doing-to-our-minds", .reading, 11),
            ("the-lost-art-of-doing-nothing.md", "The Lost Art of Doing Nothing", "The Guardian", "https://www.theguardian.com/lifeandstyle/2023/aug/12/lost-art-doing-nothing-niksen", .unread, 2),
            ("the-intelligence-of-trees.md", "The Secret Intelligence of Trees", "The New Yorker", "https://www.newyorker.com/tech/annals-of-technology/the-secret-life-of-trees", .read, 24),
            ("on-loneliness-and-solitude.md", "On Loneliness and the Deeper Kind of Solitude", "The Atlantic", "https://www.theatlantic.com/family/archive/2023/10/loneliness-solitude-distinction/675412/", .unread, 4),
            ("how-cities-shape-the-mind.md", "How Cities Shape the Mind", "Wired", "https://www.wired.com/story/how-cities-shape-the-mind-neuroscience/", .reading, 9),
            ("the-return-of-the-physical-book.md", "The Quiet Comeback of the Physical Book", "The Economist", "https://www.economist.com/culture/2024/03/physical-book-sales-digital", .unread, 6),
            ("the-science-of-sleep.md", "The Science of Sleep: What We Now Know", "Scientific American", "https://www.scientificamerican.com/article/the-science-of-sleep-what-we-now-know/", .unread, 14),
            ("the-philosophy-of-walking.md", "The Philosophy of Walking", "The Paris Review", "https://www.theparisreview.org/blog/2014/07/09/walking-and-thinking/", .read, 29),
            ("the-hidden-life-of-the-ocean.md", "The Hidden Life of the Deep Ocean", "National Geographic", "https://www.nationalgeographic.com/science/article/deep-ocean-creatures-discoveries", .unread, 3),
            ("rethinking-success.md", "Rethinking What Success Actually Means", "Harvard Business Review", "https://hbr.org/2023/05/rethinking-what-success-actually-means", .unread, 17),
            ("the-history-of-silence.md", "A Short History of Silence", "London Review of Books", "https://www.lrb.co.uk/the-paper/v45/n12/silence-history", .reading, 21),
            ("learning-to-draw-at-50.md", "What I Learned From Learning to Draw at 50", "The New Yorker", "https://www.newyorker.com/culture/personal-history/learning-to-draw-at-fifty", .read, 34),
        ]

        for item in articles {
            let fileURL = sampleDir.appendingPathComponent(item.file)
            let article = Article(context: context)
            article.id = UUID()
            article.title = item.title
            article.source = item.source
            article.url = URL(string: item.url)
            article.filePath = fileURL.path
            article.status = item.status.rawValue
            article.dateAdded = Calendar.current.date(byAdding: .day, value: -item.daysAgo, to: Date()) ?? Date()
        }

        try? context.save()
    }

    private static func sampleArticlesDirectory() -> URL {
        // Resolve SampleArticles/ relative to the app bundle, falling back to the
        // project root sibling so it works both on device and in the simulator.
        if let bundlePath = Bundle.main.resourceURL?
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("SampleArticles") {
            if FileManager.default.fileExists(atPath: bundlePath.path) {
                return bundlePath
            }
        }
        // Fallback: resolve from source file location at compile time
        let sourceFile = URL(fileURLWithPath: #filePath)
        return sourceFile
            .deletingLastPathComponent() // Services/
            .deletingLastPathComponent() // Sources/
            .deletingLastPathComponent() // Verso/
            .appendingPathComponent("SampleArticles")
    }
}
#endif
