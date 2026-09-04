import SwiftUI
import CoreData

// MARK: - List filters (FAB-50, header/sections redesigned FAB-292)

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

struct ArticleListView: View {
    /// Owned by `VersoMainSplitView`; binding it into this List's `selection:` is what lets
    /// NavigationSplitView auto-collapse to the detail column on iPhone when a row is tapped.
    @Binding var selectedArticle: Article?

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
    @EnvironmentObject var articleLibraryService: ArticleLibraryService
    @Environment(\.managedObjectContext) private var viewContext

    @State private var searchText = ""
    @State private var isSearching = false
    @State private var datePreset: ArticleListDatePreset = .any
    @State private var showFolderPicker = false
    @State private var showAddArticle = false
    @State private var showSettings = false
    @State private var selectedTags = Set<String>()
    @State private var showFilterPanel = false
    @State private var isSelecting = false
    @State private var selectedArticleIds = Set<UUID>()
    @State private var confirmBulkDelete = false

    /// Fetched independently of the list predicate so the filter panel always sees every available
    /// tag, even when search/date/tag narrowing has reduced the visible articles to zero. Still
    /// excludes archived, same as before -- archived-only tags aren't useful filter targets.
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "archived == NO"),
        animation: .default
    ) private var allArticles: FetchedResults<Article>

    private var allTagsSorted: [String] {
        let unique = Set(allArticles.flatMap { $0.tagList })
        return unique.sorted()
    }

    /// Count of non-default filter facets currently applied (tags + date range), shown as a
    /// badge on the filter icon -- same affordance the old tag-only button had, extended to cover
    /// both facets now that one icon opens both.
    private var activeFilterCount: Int {
        selectedTags.count + (datePreset == .any ? 0 : 1)
    }

    private var listPredicate: NSPredicate {
        Self.makeListPredicate(searchText: searchText, datePreset: datePreset)
    }

    /// Forces `@FetchRequest` to rebuild when inputs affecting Core Data matching change.
    private var listFetchIdentity: String {
        Self.listPredicateSignature(searchText: searchText, datePreset: datePreset)
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

                // Outside `.id(listFetchIdentity)` so typing doesn't recreate this view and drop keyboard focus.
                headerRow
                    .padding(.horizontal, VersoSpacing.md)
                    .padding(.top, VersoSpacing.md)
                    .padding(.bottom, VersoSpacing.sm)

                ArticleListFetchedBody(
                    listGeometry: listGeometry,
                    listPredicate: listPredicate,
                    hasNarrowingFilter: !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || datePreset != .any,
                    selectedArticle: $selectedArticle,
                    selectedTags: $selectedTags,
                    isSelecting: $isSelecting,
                    selectedArticleIds: $selectedArticleIds,
                    confirmBulkDelete: $confirmBulkDelete,
                    showFolderPicker: $showFolderPicker,
                    showAddArticle: $showAddArticle
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
                if showFilterPanel {
                    ZStack(alignment: .trailing) {
                        Color.black.opacity(0.35)
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(VersoAnimation.normal) { showFilterPanel = false }
                            }
                            .transition(.opacity)

                        FilterPanel(
                            tags: allTagsSorted,
                            selectedTags: $selectedTags,
                            datePreset: $datePreset,
                            onClose: {
                                withAnimation(VersoAnimation.normal) { showFilterPanel = false }
                            }
                        )
                        .environmentObject(themeManager)
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.width > 60 {
                                        withAnimation(VersoAnimation.normal) { showFilterPanel = false }
                                    }
                                }
                        )
                        .transition(.move(edge: .trailing))
                    }
                    .animation(VersoAnimation.normal, value: showFilterPanel)
                }
            }
        }
        // FAB-302: the title/controls live in `headerRow` now (FAB-292), not the nav
        // bar, so hide the sidebar column's bar entirely — otherwise NavigationSplitView
        // reserves an empty ~44pt band above `headerRow`. Mirrors ArticleReaderView's
        // own bar-hiding for its column.
        .toolbar(.hidden, for: .navigationBar)
        // FAB-304: lives here, not inside ArticleListFetchedBody, deliberately. That struct
        // is `.id(listFetchIdentity)`-keyed and gets torn down and rebuilt whenever
        // search/date change the fetch predicate -- and, more disruptively, whenever
        // ContentView's `.preferredColorScheme` flips across the light/dark boundary,
        // which forces a hosting-hierarchy rebuild. A `navigationDestination` registered
        // inside that subtree gets torn down with it while `showSettings` (owned here,
        // one level up) survives as true -- a pushed slot with no destination left to
        // resolve it, i.e. a blank screen. Attaching it to this stable ancestor instead
        // means nothing re-keys it out from under the push.
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
    }

    // MARK: - Header row (FAB-292)

    /// "Verso" and its controls share one row: while selecting, it becomes a Cancel button; while
    /// searching, it becomes the expanded search field. Otherwise it's the title plus four icons
    /// (search, filter, add, overflow).
    @ViewBuilder
    private var headerRow: some View {
        if isSelecting {
            selectionHeaderRow
        } else if isSearching {
            searchActiveRow
        } else {
            defaultHeaderRow
        }
    }

    private var selectionHeaderRow: some View {
        HStack {
            Text(L10n.Home.navTitle)
                .font(VersoTypography.UI.screenTitle)
                .foregroundColor(themeManager.colors.textPrimary)

            Spacer()

            Button(L10n.Home.bulkSelectCancel) {
                isSelecting = false
                selectedArticleIds.removeAll()
            }
            .font(VersoTypography.UI.button)
            .foregroundColor(themeManager.colors.accent)
        }
        .frame(height: 44)
    }

    private var searchActiveRow: some View {
        HStack(spacing: VersoSpacing.sm) {
            SearchBar(text: $searchText, placeholder: L10n.Home.searchPlaceholder)
                .environmentObject(themeManager)

            Button(L10n.Home.searchCancel) {
                withAnimation(VersoAnimation.fast) {
                    isSearching = false
                    searchText = ""
                }
            }
            .buttonStyle(.plain)
            .font(VersoTypography.UI.button)
            .foregroundColor(themeManager.colors.accent)
        }
    }

    private var defaultHeaderRow: some View {
        HStack(spacing: 2) {
            Text(L10n.Home.navTitle)
                .font(VersoTypography.UI.screenTitle)
                .foregroundColor(themeManager.colors.textPrimary)
                .lineLimit(1)

            Spacer(minLength: VersoSpacing.xs)

            Button {
                withAnimation(VersoAnimation.fast) { isSearching = true }
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(themeManager.colors.accent)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.Home.searchIconAccessibilityLabel)

            Button {
                withAnimation(VersoAnimation.normal) { showFilterPanel = true }
            } label: {
                Image(systemName: activeFilterCount > 0 ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(themeManager.colors.accent)
                    .frame(width: 44, height: 44)
                    .overlay(alignment: .topTrailing) {
                        if activeFilterCount > 0 {
                            Text("\(activeFilterCount)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(themeManager.colors.background)
                                .padding(.horizontal, 5)
                                .frame(minWidth: 16, minHeight: 16)
                                .background(Capsule().fill(themeManager.colors.accent))
                                .offset(x: 2, y: 4)
                        }
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.Home.tagFilterButtonAccessibilityLabel)

            Button {
                showAddArticle = true
            } label: {
                ZStack {
                    Circle()
                        .fill(themeManager.colors.accent)
                        .frame(width: 32, height: 32)
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(themeManager.colors.background)
                }
                .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.Home.addArticleAccessibilityLabel)

            Menu {
                Button(L10n.Home.bulkSelectSelect) {
                    isSelecting = true
                }
                Button(L10n.Home.settingsAccessibilityLabel) {
                    showSettings = true
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(themeManager.colors.accent)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(L10n.Home.overflowAccessibilityLabel)
        }
    }

    // MARK: - Predicate helpers

    private static func listPredicateSignature(
        searchText: String,
        datePreset: ArticleListDatePreset
    ) -> String {
        "\(searchText)|\(datePreset.rawValue)"
    }

    /// No status clause: `ArticleListFetchedBody` fetches every status and groups the results into
    /// sections client-side (Continue Reading / Unread / Read / Archived), replacing the old
    /// `activeFilter`-gated single predicate.
    private static func makeListPredicate(
        searchText: String,
        datePreset: ArticleListDatePreset
    ) -> NSPredicate {
        var parts: [NSPredicate] = []

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

        guard !parts.isEmpty else { return NSPredicate(value: true) }
        return NSCompoundPredicate(andPredicateWithSubpredicates: parts)
    }
}

// MARK: - Fetched list body

private struct ArticleListFetchedBody: View {
    let listGeometry: GeometryProxy
    let listPredicate: NSPredicate
    /// True when search text or a non-default date preset is applied -- used only to pick between
    /// the "no matches" and "no articles at all" empty-state variant (tag narrowing is read
    /// directly from `selectedTags` below).
    let hasNarrowingFilter: Bool

    @Binding var selectedArticle: Article?
    @Binding var selectedTags: Set<String>
    @Binding var isSelecting: Bool
    @Binding var selectedArticleIds: Set<UUID>
    @Binding var confirmBulkDelete: Bool

    @Binding var showFolderPicker: Bool
    @Binding var showAddArticle: Bool

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
    @EnvironmentObject var articleLibraryService: ArticleLibraryService
    @EnvironmentObject var adoptionNoticeService: AdoptionNoticeService
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest private var articles: FetchedResults<Article>

    @State private var isReadExpanded = false
    @State private var isArchivedExpanded = false
    @State private var tagsEditorArticle: Article?

    init(
        listGeometry: GeometryProxy,
        listPredicate: NSPredicate,
        hasNarrowingFilter: Bool,
        selectedArticle: Binding<Article?>,
        selectedTags: Binding<Set<String>>,
        isSelecting: Binding<Bool>,
        selectedArticleIds: Binding<Set<UUID>>,
        confirmBulkDelete: Binding<Bool>,
        showFolderPicker: Binding<Bool>,
        showAddArticle: Binding<Bool>
    ) {
        self.listGeometry = listGeometry
        self.listPredicate = listPredicate
        self.hasNarrowingFilter = hasNarrowingFilter
        _selectedArticle = selectedArticle
        _selectedTags = selectedTags
        _isSelecting = isSelecting
        _selectedArticleIds = selectedArticleIds
        _confirmBulkDelete = confirmBulkDelete
        _showFolderPicker = showFolderPicker
        _showAddArticle = showAddArticle

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

    private var continueReadingArticles: [Article] { filteredArticles.filter { !$0.archived && $0.displayStatusEnum == .reading } }
    private var unreadArticles: [Article] { filteredArticles.filter { !$0.archived && $0.displayStatusEnum == .unread } }
    private var readArticles: [Article] { filteredArticles.filter { !$0.archived && $0.displayStatusEnum == .read } }
    private var archivedArticles: [Article] { filteredArticles.filter { $0.archived } }

    /// Empty state when search/date/tags narrow the list but nothing matches any section.
    private var narrowedListShowsMiss: Bool {
        hasNarrowingFilter || !selectedTags.isEmpty
    }

    @ViewBuilder
    private func rowLabel(for article: Article, showsProgress: Bool = false) -> some View {
        HStack(alignment: .top, spacing: VersoSpacing.sm) {
            if isSelecting {
                Image(systemName: selectedArticleIds.contains(article.id) ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(themeManager.colors.accent)
                    .padding(.top, 4)
            }
            ArticleCard(article: article, showsProgress: showsProgress)
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
            if filteredArticles.isEmpty {
                EmptyState(variant: narrowedListShowsMiss ? .searchMiss : .empty)
                    .environmentObject(themeManager)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: max(260, listGeometry.size.height * 0.52))
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                if !continueReadingArticles.isEmpty {
                    sectionHeader(
                        title: L10n.Home.sectionContinueReading,
                        accessibilityLabel: L10n.Home.sectionContinueReadingAccessibilityLabel(count: continueReadingArticles.count)
                    )
                    articleRows(continueReadingArticles, showsProgress: true)
                }

                if !unreadArticles.isEmpty {
                    sectionHeader(
                        title: L10n.Filter.unread,
                        accessibilityLabel: L10n.Filter.unreadAccessibilityLabel(count: unreadArticles.count)
                    )
                    articleRows(unreadArticles)
                }

                if !readArticles.isEmpty {
                    collapsibleSectionHeader(
                        title: L10n.Filter.read,
                        accessibilityLabel: L10n.Filter.readAccessibilityLabel(count: readArticles.count),
                        isExpanded: $isReadExpanded
                    )
                    if isReadExpanded {
                        articleRows(readArticles)
                    } else {
                        collapsedCaptionRow
                    }
                }

                if !archivedArticles.isEmpty {
                    collapsibleSectionHeader(
                        title: L10n.Filter.archived,
                        accessibilityLabel: L10n.Filter.archivedAccessibilityLabel(count: archivedArticles.count),
                        isExpanded: $isArchivedExpanded
                    )
                    if isArchivedExpanded {
                        articleRows(archivedArticles)
                    } else {
                        collapsedCaptionRow
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
                // Match ReadingBottomBar: opaque fill through home indicator so controls aren't clipped.
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
        .sheet(item: $tagsEditorArticle) { article in
            ArticleTagsEditorSheet(article: article)
                .environmentObject(themeManager)
                .environmentObject(folderBookmarkService)
                .environmentObject(adoptionNoticeService)
                .environment(\.managedObjectContext, viewContext)
        }
    }

    // MARK: - Sections

    private func sectionHeader(title: String, accessibilityLabel: String) -> some View {
        Text(title)
            .font(VersoTypography.UI.listTitle)
            .foregroundColor(themeManager.colors.textPrimary)
            .padding(.horizontal, VersoSpacing.md)
            .padding(.top, VersoSpacing.md)
            .padding(.bottom, VersoSpacing.xs)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel(accessibilityLabel)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }

    private func collapsibleSectionHeader(title: String, accessibilityLabel: String, isExpanded: Binding<Bool>) -> some View {
        Button {
            withAnimation(VersoAnimation.fast) { isExpanded.wrappedValue.toggle() }
        } label: {
            HStack {
                Text(title)
                    .font(VersoTypography.UI.listTitle)
                    .foregroundColor(themeManager.colors.textPrimary)
                Spacer()
                Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.colors.textSecondary)
            }
            .padding(.horizontal, VersoSpacing.md)
            .padding(.top, VersoSpacing.md)
            .padding(.bottom, VersoSpacing.xs)
            .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(L10n.Home.sectionToggleHint)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private var collapsedCaptionRow: some View {
        Text(L10n.Home.sectionCollapsedCaption)
            .font(VersoTypography.UI.caption)
            .foregroundColor(themeManager.colors.textSecondary)
            .padding(.horizontal, VersoSpacing.md)
            .padding(.bottom, VersoSpacing.xs)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }

    @ViewBuilder
    private func articleRows(_ items: [Article], showsProgress: Bool = false) -> some View {
        ForEach(items) { article in
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
                        rowLabel(for: article, showsProgress: showsProgress)
                    }
                    .buttonStyle(.plain)
                } else {
                    // No Button/NavigationLink wrapper needed: this row's tap is handled by
                    // the List's `selection:` binding above (`.tag` is what associates the
                    // tap with this article).
                    rowLabel(for: article, showsProgress: showsProgress)
                }
            }
            .tag(article)
            .listRowInsets(EdgeInsets(
                top: 4.5, leading: VersoSpacing.md,
                bottom: 4.5, trailing: VersoSpacing.md
            ))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .contextMenu {
                Button {
                    isSelecting = true
                } label: {
                    Label(L10n.Home.bulkSelectSelect, systemImage: "checkmark.circle")
                }
                Button {
                    toggleReadStatus(article)
                } label: {
                    let isRead = article.statusEnum == .read
                    Label(
                        isRead ? L10n.ContextMenu.markAsUnread : L10n.ContextMenu.markAsRead,
                        systemImage: isRead ? "circle" : "checkmark.circle"
                    )
                }
                Button {
                    tagsEditorArticle = article
                } label: {
                    Label(L10n.ContextMenu.addTags, systemImage: "tag")
                }
                if article.archived {
                    Button {
                        unarchiveArticle(article)
                    } label: {
                        Label(L10n.ContextMenu.unarchive, systemImage: "tray.and.arrow.up")
                    }
                } else {
                    Button {
                        archiveArticle(article)
                    } label: {
                        Label(L10n.ContextMenu.archive, systemImage: "archivebox")
                    }
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                if article.archived {
                    Button {
                        unarchiveArticle(article)
                    } label: {
                        Label(L10n.Swipe.unarchive, systemImage: "tray.and.arrow.up")
                    }
                    .tint(Color(hex: "766655"))
                    .accessibilityLabel(L10n.A11y.unarchiveAction)
                } else {
                    Button {
                        archiveArticle(article)
                    } label: {
                        Label(L10n.Swipe.archive, systemImage: "archivebox")
                    }
                    .tint(Color(hex: "766655"))
                    .accessibilityLabel(L10n.A11y.archiveAction)
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

    /// Runs the FAB-290 one-time adoption for `article`'s file if it still needs one (manually
    /// added, no frontmatter or no `title`), updates the in-memory `filePath` to the renamed file,
    /// and surfaces the one-time notice. Call before any frontmatter write-back below so an adopted
    /// file's rename lands before the write it's piggybacking on.
    private func adoptIfNeeded(_ article: Article, folderURL: URL) {
        guard let newURL = try? MarkdownWriter.adoptIfNeeded(fileURL: URL(fileURLWithPath: article.filePath), in: folderURL) else { return }
        article.filePath = newURL.path
        adoptionNoticeService.notify()
    }

    /// FAB-297: archiving no longer touches `status` -- read state and archived state are
    /// orthogonal, so the article keeps whatever unread/reading/read it had before archiving.
    private func archiveArticle(_ article: Article) {
        guard let folderURL = folderBookmarkService.folderURL else { return }
        do {
            adoptIfNeeded(article, folderURL: folderURL)
            let destination = try MarkdownWriter.archive(filePath: article.filePath, in: folderURL)
            let archivedAt = Date()
            try MarkdownWriter.updateArchived(true, archivedAt: archivedAt, for: destination.path)
            article.filePath = destination.path
            article.archived = true
            article.archivedAt = archivedAt
            try viewContext.save()
        } catch {
            // silently ignore — matches existing behaviour
        }
    }

    /// Mirror of `archiveArticle`: moves the file back out of `Archive/` and clears the
    /// `archived`/`archived_at` frontmatter. `status` is untouched, same reasoning as above.
    private func unarchiveArticle(_ article: Article) {
        guard let folderURL = folderBookmarkService.folderURL else { return }
        do {
            adoptIfNeeded(article, folderURL: folderURL)
            let destination = try MarkdownWriter.unarchive(filePath: article.filePath, in: folderURL)
            try MarkdownWriter.updateArchived(false, archivedAt: nil, for: destination.path)
            article.filePath = destination.path
            article.archived = false
            article.archivedAt = nil
            try viewContext.save()
        } catch {
            // silently ignore — matches archiveArticle's existing behaviour
        }
    }

    /// Toggles read/unread only -- never touches `archived` (FAB-297: the two are orthogonal, and
    /// this must not have the side effect the old flat-enum model did of silently un-archiving).
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

// MARK: - Filter panel (tags + date range)

/// Combines tag selection with the date-range presets that previously lived in their own inline
/// row above the (now-removed) status filter-chip bar -- one filter icon in the header opens both.
private struct FilterPanel: View {
    let tags: [String]
    @Binding var selectedTags: Set<String>
    @Binding var datePreset: ArticleListDatePreset
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

            Text(L10n.Home.dateFilterLabel)
                .font(VersoTypography.UI.caption)
                .foregroundColor(themeManager.colors.textSecondary)
                .padding(.horizontal, VersoSpacing.md)
                .padding(.top, VersoSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(ArticleListDatePreset.allCases) { preset in
                tagRow(title: preset.displayLabel, isSelected: datePreset == preset) {
                    datePreset = preset
                }
            }

            Divider().background(themeManager.colors.border)

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
            Text(L10n.Home.filterPanelTitle)
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
