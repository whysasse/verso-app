import Foundation
import CoreData

final class RelatedArticlesService {
    private static let threshold: Double = 0.04
    private static let maxResults = 3
    private static let minWordLength = 4

    private static let stopWords: Set<String> = [
        "that", "this", "with", "from", "have", "been", "will", "they",
        "their", "them", "were", "when", "what", "which", "also", "more",
        "some", "than", "then", "into", "over", "just", "your", "about",
        "most", "other", "very", "only", "such", "even", "both", "each",
        "after", "before", "while", "where", "being", "would", "could",
        "should", "there", "these", "those", "here", "make", "made",
        "many", "much", "well", "like", "time", "work", "used", "still"
    ]

    func related(to article: Article, in context: NSManagedObjectContext) async -> [Article] {
        let currentPath = article.filePath
        let currentContent = article.title + " " + (loadContent(for: article) ?? "")
        let currentWords = keywords(from: currentContent)
        guard !currentWords.isEmpty else { return [] }

        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        let candidates = (try? context.fetch(fetchRequest)) ?? []

        let scored: [(Article, Double)] = candidates.compactMap { candidate in
            guard candidate.filePath != currentPath else { return nil }
            let text = candidate.title + " " + (loadContent(for: candidate) ?? "")
            let words = keywords(from: text)
            let score = jaccard(currentWords, words)
            guard score >= Self.threshold else { return nil }
            return (candidate, score)
        }

        return scored
            .sorted { $0.1 > $1.1 }
            .prefix(Self.maxResults)
            .map { $0.0 }
    }

    private func loadContent(for article: Article) -> String? {
        guard !article.filePath.isEmpty else { return nil }
        let url = URL(fileURLWithPath: article.filePath)
        return try? MarkdownReader.read(fileURL: url).contentMarkdown
    }

    private func keywords(from text: String) -> Set<String> {
        let lowercased = text.lowercased()
        let stripped = lowercased.unicodeScalars.map { char -> Character in
            if CharacterSet.letters.contains(char) || CharacterSet.whitespaces.contains(char) {
                return Character(char)
            }
            return " "
        }
        let cleaned = String(stripped)
        let words = cleaned.components(separatedBy: .whitespaces).filter { word in
            word.count >= Self.minWordLength && !Self.stopWords.contains(word)
        }
        return Set(words)
    }

    private func jaccard(_ a: Set<String>, _ b: Set<String>) -> Double {
        guard !a.isEmpty, !b.isEmpty else { return 0 }
        let intersection = Double(a.intersection(b).count)
        let union = Double(a.union(b).count)
        return intersection / union
    }
}
