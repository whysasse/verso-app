import SwiftUI
import CoreData

// MARK: - List filters (FAB-50)

private enum ArticleListDatePreset: String, CaseIterable, Identifiable {
    case any = "Any time"
    case week = "Past week"
    case month = "Past month"
    case year = "Past year"

    var id: String { rawValue }

    /// Lower bound for `dateAdded` (inclusive). `nil` means no restriction.
    var intervalStart: Date? {
        switch self {
        case .any: return nil
        case .week: return Calendar.current.date(byAdding: .day, value: -7, to: Date())
        case .month: return Calendar.current.date(byAdding: .month, value: -1, to: Date())
        case .year: return Calendar.current.date(byAdding: .year, value: -1, to: Date())
        }
    }
}

private extension ArticleStatus {
    /// Storage string on `Article.status` (Core Data).
    var storageStatusValue: String {
        switch self {
        case .unread: return Article.Status.unread.rawValue
        case .reading: return Article.Status.reading.rawValue
        case .read: return Article.Status.read.rawValue
        case .archived: return Article.Status.archived.rawValue
        }
    }
}

struct ArticleListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
    @EnvironmentObject var articleLibraryService: ArticleLibraryService
    @Environment(\.managedObjectContext) private var viewContext

    @State private var searchText = ""
    @State private var activeFilter: ArticleStatus?
    @State private var datePreset: ArticleListDatePreset = .any
    @State private var showFolderPicker = false
    @State private var showAddArticle = false
    @State private var showSettings = false
    @State private var navigationArticle: Article?
    @State private var selectedTag: String?
    @State private var isSelecting = false
    @State private var selectedArticleIds = Set<UUID>()
    @State private var confirmBulkDelete = false

    private var listPredicate: NSPredicate {
        Self.makeListPredicate(
            activeFilter: activeFilter,
            searchText: searchText,
            datePreset: datePreset
        )
    }

    /// Forces `@FetchRequest` to rebuild when inputs affecting Core Data matching change.
    private var listFetchIdentity: String {
        Self.listPredicateSignature(
            activeFilter: activeFilter,
            searchText: searchText,
            datePreset: datePreset
        )
    }

    private var statusCounts: [ArticleStatus: Int] {
        ArticleStatus.allCases.reduce(into: [:]) { result, chip in
            let req = NSFetchRequest<Article>(entityName: "Article")
            req.predicate = NSPredicate(format: "status == %@", chip.storageStatusValue)
            result[chip] = (try? viewContext.count(for: req)) ?? 0
        }
    }

    var body: some View {
        GeometryReader { listGeometry in
            VStack(spacing: 0) {
                if folderBookmarkService.folderURL == nil {
                    FolderPickerPrompt {
                        showFolderPicker = true
                    }
                    .padding(.horizontal, VersoSpacing.md)
                    .padding(.top, VersoSpacing.md)
                }

                // Outside `.id(listFetchIdentity)` so typing doesn’t recreate this view and drop keyboard focus.
                SearchBar(text: $searchText, placeholder: "Search titles, text, or site…")
                    .padding(.horizontal, VersoSpacing.md)
                    .padding(.top, VersoSpacing.md)
                    .environmentObject(themeManager)

                ArticleListFetchedBody(
                    listGeometry: listGeometry,
                    listPredicate: listPredicate,
                    searchText: $searchText,
                    activeFilter: $activeFilter,
                    datePreset: $datePreset,
                    selectedTag: $selectedTag,
                    isSelecting: $isSelecting,
                    selectedArticleIds: $selectedArticleIds,
                    navigationArticle: $navigationArticle,
                    confirmBulkDelete: $confirmBulkDelete,
                    statusCounts: statusCounts,
                    showFolderPicker: $showFolderPicker,
                    showAddArticle: $showAddArticle,
                    showSettings: $showSettings
                )
                .environmentObject(themeManager)
                .environmentObject(folderBookmarkService)
                .environmentObject(articleLibraryService)
                .environment(\.managedObjectContext, viewContext)
                .id(listFetchIdentity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(themeManager.colors.background)
        }
    }

    // MARK: - Predicate helpers

    private static func listPredicateSignature(
        activeFilter: ArticleStatus?,
        searchText: String,
        datePreset: ArticleListDatePreset
    ) -> String {
        "\(activeFilter?.storageStatusValue ?? "all")|\(searchText)|\(datePreset.rawValue)"
    }

    private static func makeListPredicate(
        activeFilter: ArticleStatus?,
        searchText: String,
        datePreset: ArticleListDatePreset
    ) -> NSPredicate {
        var parts: [NSPredicate] = []

        if let filter = activeFilter {
            parts.append(NSPredicate(format: "status == %@", filter.storageStatusValue))
        } else {
            parts.append(NSPredicate(format: "status != %@", Article.Status.archived.rawValue))
        }

        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !term.isEmpty {
            parts.append(NSPredicate(
                format: "(title CONTAINS[cd] %@) OR (searchableBody CONTAINS[cd] %@) OR (siteName CONTAINS[cd] %@) OR (url.absoluteString CONTAINS[cd] %@) OR (source CONTAINS[cd] %@)",
                term, term, term, term, term
            ))
        }

        if let start = datePreset.intervalStart {
            parts.append(NSPredicate(format: "dateAdded >= %@", start as NSDate))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: parts)
    }
}

// MARK: - Fetched list body

private struct ArticleListFetchedBody: View {
    let listGeometry: GeometryProxy
    let listPredicate: NSPredicate

    @Binding var searchText: String
    @Binding var activeFilter: ArticleStatus?
    @Binding var datePreset: ArticleListDatePreset
    @Binding var selectedTag: String?
    @Binding var isSelecting: Bool
    @Binding var selectedArticleIds: Set<UUID>
    @Binding var navigationArticle: Article?
    @Binding var confirmBulkDelete: Bool

    let statusCounts: [ArticleStatus: Int]

    @Binding var showFolderPicker: Bool
    @Binding var showAddArticle: Bool
    @Binding var showSettings: Bool

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
    @EnvironmentObject var articleLibraryService: ArticleLibraryService
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest private var articles: FetchedResults<Article>

    init(
        listGeometry: GeometryProxy,
        listPredicate: NSPredicate,
        searchText: Binding<String>,
        activeFilter: Binding<ArticleStatus?>,
        datePreset: Binding<ArticleListDatePreset>,
        selectedTag: Binding<String?>,
        isSelecting: Binding<Bool>,
        selectedArticleIds: Binding<Set<UUID>>,
        navigationArticle: Binding<Article?>,
        confirmBulkDelete: Binding<Bool>,
        statusCounts: [ArticleStatus: Int],
        showFolderPicker: Binding<Bool>,
        showAddArticle: Binding<Bool>,
        showSettings: Binding<Bool>
    ) {
        self.listGeometry = listGeometry
        self.listPredicate = listPredicate
        _searchText = searchText
        _activeFilter = activeFilter
        _datePreset = datePreset
        _selectedTag = selectedTag
        _isSelecting = isSelecting
        _selectedArticleIds = selectedArticleIds
        _navigationArticle = navigationArticle
        _confirmBulkDelete = confirmBulkDelete
        self.statusCounts = statusCounts
        _showFolderPicker = showFolderPicker
        _showAddArticle = showAddArticle
        _showSettings = showSettings

        _articles = FetchRequest(
            sortDescriptors: [SortDescriptor(\Article.dateAdded, order: .reverse)],
            predicate: listPredicate,
            animation: .default
        )
    }

    private var allTagsSorted: [String] {
        let unique = Set(articles.flatMap { $0.tagList })
        return unique.sorted()
    }

    private var filteredArticles: [Article] {
        guard let tag = selectedTag else { return Array(articles) }
        return articles.filter { $0.tagList.contains(tag) }
    }

    private var emptyUsesArchivedVariant: Bool {
        activeFilter == .archived && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && datePreset == .any
    }

    /// Empty state when filters/search narrow the list but nothing matches.
    private var narrowedListShowsMiss: Bool {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty { return true }
        if datePreset != .any { return true }
        if selectedTag != nil { return true }
        return false
    }

    var body: some View {
        List {
            dateFilterRow
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            FilterChipBar(activeFilter: $activeFilter, counts: statusCounts)
                .padding(.top, VersoSpacing.sm)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            if !allTagsSorted.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: VersoSpacing.sm) {
                        tagFilterPill("All tags", active: selectedTag == nil) { selectedTag = nil }
                        ForEach(allTagsSorted, id: \.self) { tag in
                            tagFilterPill(tag, active: selectedTag == tag) { selectedTag = tag }
                        }
                    }
                    .padding(.horizontal, VersoSpacing.md)
                }
                .padding(.top, VersoSpacing.sm)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            if filteredArticles.isEmpty {
                EmptyState(variant: emptyUsesArchivedVariant ? .noArchived : (narrowedListShowsMiss ? .searchMiss : .empty))
                    .environmentObject(themeManager)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: max(260, listGeometry.size.height * 0.52))
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(filteredArticles) { article in
                    Button {
                        if isSelecting {
                            if selectedArticleIds.contains(article.id) {
                                selectedArticleIds.remove(article.id)
                            } else {
                                selectedArticleIds.insert(article.id)
                            }
                        } else {
                            navigationArticle = article
                        }
                    } label: {
                        HStack(alignment: .top, spacing: VersoSpacing.sm) {
                            if isSelecting {
                                Image(systemName: selectedArticleIds.contains(article.id) ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(themeManager.colors.accent)
                                    .padding(.top, 4)
                            }
                            ArticleCard(article: article)
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(
                        top: 4.5, leading: VersoSpacing.md,
                        bottom: 4.5, trailing: VersoSpacing.md
                    ))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if article.statusEnum != .archived {
                            Button {
                                archiveArticle(article)
                            } label: {
                                Label("Archive", systemImage: "archivebox")
                            }
                            .tint(Color(hex: "766655"))
                        }
                    }
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.colors.background)
        .scrollContentBackground(.hidden)
        .refreshable {
            guard let url = folderBookmarkService.folderURL else { return }
            await articleLibraryService.rebuildCache(from: url, context: viewContext)
        }
        .versoNavigationBar(title: "Verso", trailingIcon: "gear") {
            showSettings = true
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(isSelecting ? "Cancel" : "Select") {
                    if isSelecting {
                        isSelecting = false
                        selectedArticleIds.removeAll()
                    } else {
                        isSelecting = true
                    }
                }
                .font(VersoTypography.UI.button)
                .foregroundColor(themeManager.colors.accent)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                VersoToolbarIconButton(
                    systemName: "plus.circle",
                    accent: themeManager.colors.accent
                ) {
                    showAddArticle = true
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if isSelecting, !selectedArticleIds.isEmpty {
                HStack(spacing: VersoSpacing.lg) {
                    Button {
                        markSelectedArticlesRead()
                    } label: {
                        Text("Mark read")
                            .font(VersoTypography.UI.button)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(themeManager.colors.accent)

                    Spacer()

                    Button(role: .destructive) {
                        confirmBulkDelete = true
                    } label: {
                        Text("Delete")
                            .font(VersoTypography.UI.button)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, VersoSpacing.lg)
                .padding(.top, VersoSpacing.md)
                .padding(.bottom, VersoSpacing.xs)
                .frame(maxWidth: .infinity)
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(themeManager.colors.border),
                    alignment: .top
                )
                // Match ReadingBottomBar: opaque fill through home indicator so controls aren’t clipped.
                .background(themeManager.colors.background.ignoresSafeArea(edges: .bottom))
            }
        }
        .confirmationDialog(
            "Delete \(selectedArticleIds.count) article\(selectedArticleIds.count == 1 ? "" : "s")?",
            isPresented: $confirmBulkDelete,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteSelectedArticles()
            }
            Button("Cancel", role: .cancel) {}
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
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
        .navigationDestination(isPresented: Binding(
            get: { navigationArticle != nil },
            set: { if !$0 { navigationArticle = nil } }
        )) {
            if let navigationArticle {
                ArticleReaderView(article: navigationArticle)
                    .id(navigationArticle.id)
            }
        }
    }

    private var dateFilterRow: some View {
        HStack {
            Text("Added")
                .font(VersoTypography.UI.caption)
                .foregroundColor(themeManager.colors.textSecondary)
            Spacer()
            Menu {
                ForEach(ArticleListDatePreset.allCases) { preset in
                    Button(preset.rawValue) {
                        datePreset = preset
                    }
                }
            } label: {
                HStack(spacing: VersoSpacing.xs) {
                    Text(datePreset.rawValue)
                        .font(VersoTypography.UI.listSubtitle)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.colors.textSecondary)
                }
                .foregroundColor(themeManager.colors.textPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, VersoSpacing.md)
        .padding(.top, VersoSpacing.sm)
    }

    private func archiveArticle(_ article: Article) {
        guard let folderURL = folderBookmarkService.folderURL else { return }
        do {
            let destination = try MarkdownWriter.archive(filePath: article.filePath, in: folderURL)
            try MarkdownWriter.updateStatus(.archived, for: destination.path)
            article.filePath = destination.path
            article.statusEnum = .archived
            try viewContext.save()
        } catch {
            // silently ignore — matches existing behaviour
        }
    }

    private func toggleReadStatus(_ article: Article) {
        let newStatus: Article.Status = article.statusEnum == .read ? .unread : .read
        article.statusEnum = newStatus
        try? viewContext.save()
        try? MarkdownWriter.updateStatus(newStatus, for: article.filePath)
    }

    private func tagFilterPill(_ title: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(active ? themeManager.colors.accent : themeManager.colors.textSecondary)
                .lineLimit(1)
                .padding(.horizontal, VersoSpacing.sm)
                .frame(height: 32)
                .background(
                    Capsule().fill(active ? themeManager.colors.accentSurface : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }

    private func markSelectedArticlesRead() {
        guard let folderURL = folderBookmarkService.folderURL else { return }
        let accessed = folderURL.startAccessingSecurityScopedResource()
        defer { if accessed { folderURL.stopAccessingSecurityScopedResource() } }
        for article in articles where selectedArticleIds.contains(article.id) {
            article.statusEnum = .read
            try? MarkdownWriter.updateStatus(.read, for: article.filePath)
        }
        try? viewContext.save()
        selectedArticleIds.removeAll()
        isSelecting = false
    }

    private func deleteSelectedArticles() {
        guard let folderURL = folderBookmarkService.folderURL else { return }
        let accessed = folderURL.startAccessingSecurityScopedResource()
        defer { if accessed { folderURL.stopAccessingSecurityScopedResource() } }
        for article in articles where selectedArticleIds.contains(article.id) {
            try? MarkdownWriter.delete(at: article.filePath)
            viewContext.delete(article)
        }
        try? viewContext.save()
        selectedArticleIds.removeAll()
        isSelecting = false
    }
}
