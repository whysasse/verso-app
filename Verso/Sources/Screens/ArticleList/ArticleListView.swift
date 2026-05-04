import SwiftUI
import CoreData

struct ArticleListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.dateAdded, order: .reverse)],
        animation: .default
    )
    private var articles: FetchedResults<Article>

    @State private var searchText = ""
    @State private var activeFilter: ArticleStatus?

    private var colors: ThemeColors { themeManager.colors }

    private var filteredArticles: [Article] {
        articles.filter { article in
            let matchesFilter: Bool = {
                guard let filter = activeFilter else { return true }
                return article.statusEnum.rawValue == filter.rawValue.lowercased()
            }()

            let matchesSearch: Bool = {
                guard !searchText.isEmpty else { return true }
                return article.title.localizedCaseInsensitiveContains(searchText)
            }()

            return matchesFilter && matchesSearch
        }
    }

    private var statusCounts: [ArticleStatus: Int] {
        Dictionary(uniqueKeysWithValues: ArticleStatus.allCases.map { status in
            let count = articles.filter { $0.statusEnum.rawValue == status.rawValue.lowercased() }.count
            return (status, count)
        })
    }

    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                FilterChipBar(activeFilter: $activeFilter, counts: statusCounts)
                    .padding(.vertical, VersoSpacing.xs)

                if filteredArticles.isEmpty {
                    EmptyStateView(hasSearch: !searchText.isEmpty, colors: colors)
                } else {
                    ScrollView {
                        LazyVStack(spacing: VersoSpacing.sm) {
                            ForEach(filteredArticles) { article in
                                NavigationLink(destination: Text("Reading view coming soon")) {
                                    ArticleCardView(article: article)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, VersoSpacing.md)
                        .padding(.vertical, VersoSpacing.sm)
                    }
                }
            }
        }
        .navigationTitle("Verso")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: Text("Settings coming soon")) {
                    Image(systemName: "gearshape")
                        .foregroundColor(colors.accent)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search articles")
        .preferredColorScheme(themeManager.currentTheme.isDark ? .dark : .light)
    }
}

private struct EmptyStateView: View {
    let hasSearch: Bool
    let colors: ThemeColors

    var body: some View {
        VStack(spacing: VersoSpacing.md) {
            Spacer()

            Image(systemName: hasSearch ? "magnifyingglass" : "tray")
                .font(.system(size: 48))
                .foregroundColor(colors.textSecondary)

            Text(hasSearch ? "No articles match your search" : "No articles yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(colors.textPrimary)

            Text(hasSearch ? "Try a different search term" : "Save articles from the share sheet to get started")
                .font(.system(size: 15))
                .foregroundColor(colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, VersoSpacing.xl)

            Spacer()
        }
    }
}
