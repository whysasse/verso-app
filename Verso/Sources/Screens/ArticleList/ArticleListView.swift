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
            // Search bar
            HStack(spacing: VersoSpacing.xs) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(colors.textSecondary)
                TextField("Search titles...", text: $searchText)
                    .font(VersoTypography.UI.input)
                    .foregroundColor(colors.textPrimary)
                    .tint(colors.accent)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(colors.placeholder)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, VersoSpacing.sm)
            .frame(height: 44)
            .background(colors.surface)
            .cornerRadius(VersoRadius.sm)
            .padding(.horizontal, VersoSpacing.md)
            .padding(.top, VersoSpacing.md)

            // Filter chips
            FilterChipBar(activeFilter: $activeFilter, counts: statusCounts)
                .padding(.top, VersoSpacing.lg)

            // Article list or empty state
            if filteredArticles.isEmpty {
                EmptyStateView(hasSearch: !searchText.isEmpty, colors: colors)
            } else {
                ScrollView {
                    LazyVStack(spacing: 9) {
                        ForEach(filteredArticles) { article in
                            NavigationLink(destination: Text("Reading view coming soon")) {
                                ArticleCardView(article: article)
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
        .background(colors.background.ignoresSafeArea())
        .navigationTitle("Verso")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // FAB-21: add article action
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20))
                        .foregroundColor(colors.accent)
                }
                .buttonStyle(.plain)
            }
        }
        .toolbarBackground(colors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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

            Text(hasSearch ? "Try a different search term" : "Save your first article to get started")
                .font(.system(size: 15))
                .foregroundColor(colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, VersoSpacing.xl)

            Spacer()
        }
    }
}
