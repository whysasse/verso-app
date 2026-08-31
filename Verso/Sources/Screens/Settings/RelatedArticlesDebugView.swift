#if DEBUG
import SwiftUI
import CoreData

/// FAB-298 calibration tool, DEBUG-only: runs the same `RelatedArticlesScoring` engine the app
/// uses at runtime over every non-archived pair in the *current* library and lists every score,
/// sorted descending. Exists because the threshold (`RelatedArticlesScoring.threshold`) needs to
/// be picked from real data, not guessed -- and this session has no access to Fabio's actual
/// on-device library, so this is the mechanism for him to do that calibration himself and report
/// back a number. Not reachable in a Release build (see the `#if DEBUG` NavigationLink in
/// `SettingsView`).
struct RelatedArticlesDebugView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.managedObjectContext) private var viewContext

    private var colors: ThemeColors { themeManager.colors }

    private struct Pair: Identifiable {
        let id = UUID()
        let titleA: String
        let titleB: String
        let score: Double
    }

    @State private var pairs: [Pair] = []
    @State private var isComputing = false

    var body: some View {
        List {
            Section {
                Text("Threshold: \(RelatedArticlesScoring.threshold, specifier: "%.2f")")
                    .font(VersoTypography.UI.listSubtitle)
                    .foregroundColor(colors.textSecondary)
            }
            Section {
                if isComputing {
                    ProgressView()
                } else if pairs.isEmpty {
                    Text("No pairs scored yet. Need at least 2 non-archived articles.")
                        .font(VersoTypography.UI.listSubtitle)
                        .foregroundColor(colors.textSecondary)
                } else {
                    ForEach(pairs) { pair in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(pair.titleA)  ↔  \(pair.titleB)")
                                .font(VersoTypography.UI.listTitle)
                                .foregroundColor(colors.textPrimary)
                            Text(String(format: "%.3f", pair.score))
                                .font(VersoTypography.UI.caption)
                                .foregroundColor(pair.score >= RelatedArticlesScoring.threshold ? colors.accent : colors.textSecondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle("Related Articles Debug")
        .task { await computeMatrix() }
    }

    /// Every unordered pair's full score (not just what clears `threshold`) -- unlike
    /// `RelatedArticlesService.related`, this deliberately does not filter by threshold, so Fabio
    /// can see where a cutoff would land relative to the whole distribution.
    private func computeMatrix() async {
        isComputing = true
        defer { isComputing = false }

        let fetchRequest = NSFetchRequest<Article>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "archived == NO")
        let articles = (try? viewContext.fetch(fetchRequest)) ?? []
        guard articles.count >= 2 else { return }

        let documents = articles.map { article in
            RelatedArticlesDocument(
                key: article.filePath,
                title: article.title,
                body: article.searchableBody ?? (try? MarkdownReader.read(fileURL: URL(fileURLWithPath: article.filePath)).contentMarkdown) ?? "",
                tags: article.tagList
            )
        }
        let titlesByKey = Dictionary(uniqueKeysWithValues: articles.map { ($0.filePath, $0.title) })

        let computed: [Pair] = await Task.detached(priority: .userInitiated) {
            var results: [Pair] = []
            for i in 0..<documents.count {
                for j in (i + 1)..<documents.count {
                    // rawScores (not score) -- unfiltered by threshold, so pairs below the cutoff
                    // still show up and Fabio can see where the line would actually fall.
                    let scored = RelatedArticlesScoring.rawScores(current: documents[i], candidates: [documents[j]])
                    guard let match = scored.first else { continue }
                    let titleA = titlesByKey[documents[i].key] ?? documents[i].key
                    let titleB = titlesByKey[documents[j].key] ?? documents[j].key
                    results.append(Pair(titleA: titleA, titleB: titleB, score: match.score))
                }
            }
            return results.sorted { $0.score > $1.score }
        }.value

        pairs = computed
    }
}
#endif
