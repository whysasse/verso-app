import SwiftUI
import CoreData

struct ArticleListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
    @EnvironmentObject var articleLibraryService: ArticleLibraryService
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
        List {
            // Header rows (search + filter chips)
            if folderBookmarkService.folderURL == nil {
                FolderPickerPrompt {
                    showFolderPicker = true
                }
                .padding(.horizontal, VersoSpacing.md)
                .padding(.top, VersoSpacing.md)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            SearchBar(text: $searchText)
                .padding(.horizontal, VersoSpacing.md)
                .padding(.top, VersoSpacing.md)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            FilterChipBar(activeFilter: $activeFilter, counts: statusCounts)
                .padding(.top, VersoSpacing.lg)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            // Article rows or empty state
            if filteredArticles.isEmpty {
                EmptyState(variant: searchText.isEmpty ? .empty : .searchMiss)
                    .padding(.top, VersoSpacing.xl)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(filteredArticles) { article in
                    NavigationLink(destination: ArticleReaderView(article: article)) {
                        ArticleCard(article: article)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(
                        top: 4.5, leading: VersoSpacing.md,
                        bottom: 4.5, trailing: VersoSpacing.md
                    ))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    // FAB-22: swipe-left to archive
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            archiveArticle(article)
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
                        .tint(Color(hex: "766655"))
                    }
                    // FAB-23: swipe-right to toggle read/unread
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        let isRead = article.statusEnum == .read
                        Button {
                            toggleReadStatus(article)
                        } label: {
                            Label(
                                isRead ? "Mark Unread" : "Mark Read",
                                systemImage: isRead ? "circle" : "checkmark.circle"
                            )
                        }
                        .tint(isRead ? Color(hex: "4A90D9") : Color(hex: "5AAF7A"))
                    }
                }
            }
        }
        .listStyle(.plain)
        .background(themeManager.colors.background)
        .scrollContentBackground(.hidden)
        // FAB-25: pull-to-refresh
        .refreshable {
            guard let url = folderBookmarkService.folderURL else { return }
            await articleLibraryService.rebuildCache(from: url, context: viewContext)
        }
        .versoNavigationBar(title: "Verso", trailingIcon: "folder") {
            showFolderPicker = true
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddArticle = true
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

    // MARK: - Actions

    private func archiveArticle(_ article: Article) {
        guard let folderURL = folderBookmarkService.folderURL else { return }
        let path = article.filePath
        viewContext.delete(article)
        try? viewContext.save()
        try? MarkdownWriter.archive(filePath: path, in: folderURL)
    }

    private func toggleReadStatus(_ article: Article) {
        let newStatus: Article.Status = article.statusEnum == .read ? .unread : .read
        article.statusEnum = newStatus
        try? viewContext.save()
        try? MarkdownWriter.updateStatus(newStatus, for: article.filePath)
    }
}
