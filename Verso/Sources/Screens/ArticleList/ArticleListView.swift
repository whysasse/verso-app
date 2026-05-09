import SwiftUI
import CoreData

struct ArticleListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.dateAdded, order: .reverse)],
        animation: .default
    )
    private var articles: FetchedResults<Article>

    @State private var searchText = ""
    @State private var activeFilter: ArticleStatus?
    @State private var showFolderPicker = false
    @State private var showAddArticle = false

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
        ScrollView {
            VStack(spacing: 0) {
                if folderBookmarkService.folderURL == nil {
                    FolderPickerPrompt {
                        showFolderPicker = true
                    }
                    .padding(.horizontal, VersoSpacing.md)
                    .padding(.top, VersoSpacing.md)
                }

                SearchBar(text: $searchText)
                    .padding(.horizontal, VersoSpacing.md)
                    .padding(.top, VersoSpacing.md)

                FilterChipBar(activeFilter: $activeFilter, counts: statusCounts)
                    .padding(.top, VersoSpacing.lg)

                if filteredArticles.isEmpty {
                    EmptyState(variant: searchText.isEmpty ? .empty : .searchMiss)
                        .padding(.top, VersoSpacing.xl)
                } else {
                    LazyVStack(spacing: 9) {
                        ForEach(filteredArticles) { article in
                            NavigationLink(destination: ArticleReaderView(article: article)) {
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
        .background(themeManager.colors.background)
        .versoNavigationBar(title: "Verso", trailingIcon: "folder") {
            showFolderPicker = true
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddArticle = true // FAB-21: add article action
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(themeManager.colors.accent)
                }
                .buttonStyle(.plain)
                .tint(.clear)
            }
        }
        .sheet(isPresented: $showFolderPicker) {
            DocumentPicker(onDocumentsPicked: { urls in
                guard let url = urls.first else { return }
                folderBookmarkService.save(url: url)
                showFolderPicker = false
            })
        }
        .sheet(isPresented: $showAddArticle) {
            AddArticleView()
                .environmentObject(themeManager)
                .environmentObject(folderBookmarkService)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
