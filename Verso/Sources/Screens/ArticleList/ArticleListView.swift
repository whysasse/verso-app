import SwiftUI
import CoreData

// MARK: - List filters (FAB-50)

private enum ArticleListDatePreset: String, CaseIterable, Identifiable {
    case any = "Any time"
    case week = "Past week"
    case month = "Past month"
    case year = "Past year"

    var id: String { rawValue }

    /// User-facing text. `rawValue` stays a stable, English, non-localized identifier --
    /// it doubles as this enum's Identifiable id and feeds `listFetchIdentity`'s cache-key
    /// signature, so localizing it directly would tie cache invalidation to locale.
    var displayLabel: String {
        switch self {
        case .any: return L10n.Home.dateFilterAny
        case .week: return L10n.Home.dateFilterWeek
        case .month: return L10n.Home.dateFilterMonth
        case .year: return L10n.Home.dateFilterYear
        }
    }

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
    /// Owned by `VersoMainSplitView`; binding it into this List's `selection:` is what lets
    /// NavigationSplitView auto-collapse to the detail column on iPhone when a row is tapped.
    @Binding var selectedArticle: Article?

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
    @State private var selectedTags = Set<String>()
    @State private var showTagPanel = false
    @State private var isSelecting = false
    @State private var selectedArticleIds = Set<UUID>()
    @State private var confirmBulkDelete = false

    /// Fetched independently of the list predicate so the tag panel always sees every available tag,
    /// even when the active filter or search narrows the visible articles to zero.
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "status != %@", Article.Status.archived.rawValue),
        animation: .default
    ) private var allArticles: FetchedResults<Article>

    private var allTagsSorted: [String] {
        let unique = Set(allArticles.flatMap { $0.tagList })
        return unique.sorted()
    }

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
                HStack(spacing: VersoSpacing.sm) {
                    SearchBar(text: $searchText, placeholder: L10n.Home.searchPlaceholder)
                        .environmentObject(themeManager)

                    Button {
                        withAnimation(VersoAnimation.normal) { showTagPanel = true }
                    } label: {
                        Image(systemName: selectedTags.isEmpty ? "tag" : "tag.fill")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(themeManager.colors.accent)
                            .frame(width: 44, height: 44)
                            .background(themeManager.colors.surface)
                            .cornerRadius(VersoRadius.sm)
                            .overlay(alignment: .topTrailing) {
                                if !selectedTags.isEmpty {
                                    Text("\(selectedTags.count)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 5)
                                        .frame(minWidth: 16, minHeight: 16)
                                        .background(Capsule().fill(themeManager.colors.accent))
                                        .offset(x: 4, y: -4)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(L10n.Home.tagFilterButtonAccessibilityLabel)
                }
                .padding(.horizontal, VersoSpacing.md)
                .padding(.top, VersoSpacing.md)

                ArticleListFetchedBody(
                    listGeometry: listGeometry,
                    listPredicate: listPredicate,
                    selectedArticle: $selectedArticle,
                    searchText: $searchText,
                    activeFilter: $activeFilter,
                    datePreset: $datePreset,
                    selectedTags: $selectedTags,
                    isSelecting: $isSelecting,
                    selectedArticleIds: $selectedArticleIds,
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
            .overlay {
                if showTagPanel {
                    ZStack(alignment: .trailing) {
                        Color.black.opacity(0.35)
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(VersoAnimation.normal) { showTagPanel = false }
                            }
                            .transition(.opacity)

                        TagFilterPanel(
                            tags: allTagsSorted,
                            selectedTags: $selectedTags,
                            onClose: {
                                withAnimation(VersoAnimation.normal) { showTagPanel = false }
                            }
                        )
                        .environmentObject(themeManager)
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.width > 60 {
                                        withAnimation(VersoAnimation.normal) { showTagPanel = false }
                                    }
                                }
                        )
                        .transition(.move(edge: .trailing))
                    }
                    .animation(VersoAnimation.normal, value: showTagPanel)
                }
            }
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

    @Binding var selectedArticle: Article?
    @Binding var searchText: String
    @Binding var activeFilter: ArticleStatus?
    @Binding var datePreset: ArticleListDatePreset
    @Binding var selectedTags: Set<String>
    @Binding var isSelecting: Bool
    @Binding var selectedArticleIds: Set<UUID>
    @Binding var confirmBulkDelete: Bool

    let statusCounts: [ArticleStatus: Int]

    @Binding var showFolderPicker: Bool
    @Binding var showAddArticle: Bool
    @Binding var showSettings: Bool

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
    @EnvironmentObject var articleLibraryService: ArticleLibraryService
    @EnvironmentObject var adoptionNoticeService: AdoptionNoticeService
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest private var articles: FetchedResults<Article>

    init(
        listGeometry: GeometryProxy,
        listPredicate: NSPredicate,
        selectedArticle: Binding<Article?>,
        searchText: Binding<String>,
        activeFilter: Binding<ArticleStatus?>,
        datePreset: Binding<ArticleListDatePreset>,
        selectedTags: Binding<Set<String>>,
        isSelecting: Binding<Bool>,
        selectedArticleIds: Binding<Set<UUID>>,
        confirmBulkDelete: Binding<Bool>,
        statusCounts: [ArticleStatus: Int],
        showFolderPicker: Binding<Bool>,
        showAddArticle: Binding<Bool>,
        showSettings: Binding<Bool>
    ) {
        self.listGeometry = listGeometry
        self.listPredicate = listPredicate
        _selectedArticle = selectedArticle
        _searchText = searchText
        _activeFilter = activeFilter
        _datePreset = datePreset
        _selectedTags = selectedTags
        _isSelecting = isSelecting
        _selectedArticleIds = selectedArticleIds
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

    private var filteredArticles: [Article] {
        guard !selectedTags.isEmpty else { return Array(articles) }
        return articles.filter { article in
            !selectedTags.isDisjoint(with: Set(article.tagList))
        }
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
        if !selectedTags.isEmpty { return true }
        return false
    }

    @ViewBuilder
    private func rowLabel(for article: Article) -> some View {
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

    var body: some View {
        // `selection:` (not a plain List) is what makes NavigationSplitView auto-collapse to the
        // detail column on iPhone when a row is tapped — see the comment on `selectedArticle` in
        // VersoMainSplitView for why a NavigationLink/navigationDestination pair across columns
        // doesn't work here. While bulk-select mode is active, taps should toggle checkboxes
        // instead of opening an article, so the binding writes nowhere (`.constant(nil)`) and the
        // checkbox Button below handles the tap itself.
        List(selection: isSelecting ? .constant(nil) : $selectedArticle) {
            dateFilterRow
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            FilterChipBar(activeFilter: $activeFilter, counts: statusCounts)
                .padding(.top, VersoSpacing.sm)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

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
                    Group {
                        if isSelecting {
                            // Bulk-select mode: tap toggles a checkbox, no navigation involved.
                            // The List's selection binding is `.constant(nil)` while this is active,
                            // so this Button's own tap handling is what fires here, not row selection.
                            Button {
                                if selectedArticleIds.contains(article.id) {
                                    selectedArticleIds.remove(article.id)
                                } else {
                                    selectedArticleIds.insert(article.id)
                                }
                            } label: {
                                rowLabel(for: article)
                            }
                            .buttonStyle(.plain)
                        } else {
                            // No Button/NavigationLink wrapper needed: this row's tap is handled by
                            // the List's `selection:` binding above (`.tag` is what associates the
                            // tap with this article).
                            rowLabel(for: article)
                        }
                    }
                    .tag(article)
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
                                Label(L10n.Swipe.archive, systemImage: "archivebox")
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
                                isRead ? L10n.Swipe.markUnread : L10n.Swipe.markRead,
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
        .versoNavigationBar(title: L10n.Home.navTitle, trailingIcon: "gear") {
            showSettings = true
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(isSelecting ? L10n.Home.bulkSelectCancel : L10n.Home.bulkSelectSelect) {
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
                        Text(L10n.Home.bulkSelectMarkRead)
                            .font(VersoTypography.UI.button)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(themeManager.colors.accent)

                    Spacer()

                    Button(role: .destructive) {
                        confirmBulkDelete = true
                    } label: {
                        Text(L10n.Home.bulkSelectDelete)
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
            L10n.Dialog.bulkDeleteTitle(count: selectedArticleIds.count),
            isPresented: $confirmBulkDelete,
            titleVisibility: .visible
        ) {
            Button(L10n.Dialog.deleteArticleConfirm, role: .destructive) {
                deleteSelectedArticles()
            }
            Button(L10n.Dialog.deleteArticleCancel, role: .cancel) {}
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
    }

    private var dateFilterRow: some View {
        HStack {
            Text(L10n.Home.dateFilterLabel)
                .font(VersoTypography.UI.caption)
                .foregroundColor(themeManager.colors.textSecondary)
            Spacer()
            Menu {
                ForEach(ArticleListDatePreset.allCases) { preset in
                    Button(preset.displayLabel) {
                        datePreset = preset
                    }
                }
            } label: {
                HStack(spacing: VersoSpacing.xs) {
                    Text(datePreset.displayLabel)
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

    /// Runs the FAB-290 one-time adoption for `article`'s file if it still needs one (manually
    /// added, no frontmatter or no `title`), updates the in-memory `filePath` to the renamed file,
    /// and surfaces the one-time notice. Call before any frontmatter write-back below so an adopted
    /// file's rename lands before the write it's piggybacking on.
    private func adoptIfNeeded(_ article: Article, folderURL: URL) {
        guard let newURL = try? MarkdownWriter.adoptIfNeeded(fileURL: URL(fileURLWithPath: article.filePath), in: folderURL) else { return }
        article.filePath = newURL.path
        adoptionNoticeService.notify()
    }

    private func archiveArticle(_ article: Article) {
        guard let folderURL = folderBookmarkService.folderURL else { return }
        do {
            adoptIfNeeded(article, folderURL: folderURL)
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
        if let folderURL = folderBookmarkService.folderURL {
            adoptIfNeeded(article, folderURL: folderURL)
        }
        let newStatus: Article.Status = article.statusEnum == .read ? .unread : .read
        article.statusEnum = newStatus
        try? viewContext.save()
        try? MarkdownWriter.updateStatus(newStatus, for: article.filePath)
    }

    private func markSelectedArticlesRead() {
        guard let folderURL = folderBookmarkService.folderURL else { return }
        let accessed = folderURL.startAccessingSecurityScopedResource()
        defer { if accessed { folderURL.stopAccessingSecurityScopedResource() } }
        for article in articles where selectedArticleIds.contains(article.id) {
            adoptIfNeeded(article, folderURL: folderURL)
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

// MARK: - Tag filter panel

private struct TagFilterPanel: View {
    let tags: [String]
    @Binding var selectedTags: Set<String>
    let onClose: () -> Void

    @EnvironmentObject var themeManager: ThemeManager
    @State private var tagQuery: String = ""

    private var filteredTags: [String] {
        let q = tagQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return tags }
        return tags.filter { $0.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            SearchBar(text: $tagQuery, placeholder: L10n.Home.tagFilterSearchPlaceholder)
                .padding(.horizontal, VersoSpacing.md)
                .padding(.top, VersoSpacing.sm)
                .padding(.bottom, VersoSpacing.sm)
                .environmentObject(themeManager)

            Divider().background(themeManager.colors.border)

            ScrollView {
                LazyVStack(spacing: 0) {
                    tagRow(
                        title: L10n.Home.tagFilterAllTags,
                        isSelected: selectedTags.isEmpty
                    ) {
                        selectedTags.removeAll()
                    }

                    Divider()
                        .background(themeManager.colors.border)
                        .padding(.leading, VersoSpacing.md)

                    if filteredTags.isEmpty && !tagQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(L10n.Home.tagFilterNoMatches)
                            .font(VersoTypography.UI.listSubtitle)
                            .foregroundColor(themeManager.colors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, VersoSpacing.md)
                            .padding(.vertical, VersoSpacing.md)
                    } else {
                        ForEach(filteredTags, id: \.self) { tag in
                            tagRow(
                                title: tag,
                                isSelected: selectedTags.contains(tag)
                            ) {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 320)
        .frame(maxHeight: .infinity)
        .background(themeManager.colors.surface.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Text(L10n.Home.tagFilterTitle)
                .font(VersoTypography.UI.screenTitle)
                .foregroundColor(themeManager.colors.textPrimary)
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(themeManager.colors.textSecondary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.Home.tagFilterCloseAccessibilityLabel)
        }
        .padding(.leading, VersoSpacing.md)
        .padding(.trailing, VersoSpacing.xs)
        .padding(.top, VersoSpacing.md)
    }

    private func tagRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: VersoSpacing.sm) {
                Text(title)
                    .font(VersoTypography.UI.listTitle)
                    .foregroundColor(themeManager.colors.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: VersoSpacing.sm)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(themeManager.colors.accent)
                }
            }
            .padding(.horizontal, VersoSpacing.md)
            .frame(minHeight: 44)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
