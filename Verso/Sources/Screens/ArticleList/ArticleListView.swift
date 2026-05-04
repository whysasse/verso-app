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

    private var filteredArticles: [Article] {
        articles.filter { article in
            let matchesFilter: Bool = {
                guard let filter = activeFilter else { return true }
                return article.statusEnum.rawValue == filter.rawValue.lowercased()
            }()
            let matchesSearch: Bool = searchText.isEmpty
                || article.title.localizedCaseInsensitiveContains(searchText)
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
        VStack(spacing: 0) {
            SearchBar(text: $searchText)
                .padding(.horizontal, VersoSpacing.md)
                .padding(.top, VersoSpacing.md)

            // Filter chips
            FilterChipBar(activeFilter: $activeFilter, counts: statusCounts)
                .padding(.top, VersoSpacing.lg)

            // Article list or empty state
            if filteredArticles.isEmpty {
                EmptyState(variant: searchText.isEmpty ? .empty : .searchMiss)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredArticles) { article in
                            NavigationLink(destination: Text("Reading view coming soon")) {
                                ArticleCard(article: article)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, VersoSpacing.md)
                    .padding(.top, VersoSpacing.lg)
                    .padding(.bottom, VersoSpacing.md)
                }
            }
        }
        .background(themeManager.colors.background.ignoresSafeArea())
        .navigationTitle("Verso")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // FAB-21: add article action
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.colors.accent)
                }
                .buttonStyle(.plain)
            }
        }
        .toolbarBackground(themeManager.colors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .preferredColorScheme(themeManager.currentTheme.isDark ? .dark : .light)
    }
}
