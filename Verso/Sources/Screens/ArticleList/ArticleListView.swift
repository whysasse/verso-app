import SwiftUI
import CoreData

// MARK: - List filters (FAB-50, header/sections redesigned FAB-292)

private enum ArticleListDatePreset: String, CaseIterable, Identifiable {
    case any = "Any time"
    case week = "Past week"
    case month = "Past month"
    case year = "Past year"

    var id: String { rawValue }

    /// User-facing text. `rawValue` stays a stable, English, non-localized identifier -- it's
    /// this enum's Identifiable id, and (pre-phase-5) fed the now-removed `listFetchIdentity`
    /// cache key. Kept non-localized on general principle: a raw identifier used in Swift
    /// code shouldn't be tied to whatever locale the device happens to be in.
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

    /// FAB-334 phase 6, R1 option (b): "N Selected" while selecting (FAB-320's second half).
    private var navigationTitleText: String {
        isSelecting ? L10n.Home.bulkSelectTitle(count: selectedArticleIds.count) : L10n.Home.navTitle
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

                // FAB-334 phase 5, absorbs FAB-319's remainder: a dismissible summary row
                // ("2 tags · Past month ✕") when a tag/date filter is active, restoring the
                // old chip bar's visibility without its width problems -- search text isn't
                // included, it's live and already visible in the search field itself.
                if activeFilterCount > 0 {
                    activeFilterSummaryRow
                        .padding(.horizontal, VersoSpacing.md)
                        .padding(.bottom, VersoSpacing.sm)
                }

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
                    showAddArticle: $showAddArticle,
                    onClearFilters: {
                        searchText = ""
                        datePreset = .any
                        selectedTags.removeAll()
                    }
                )
                .environmentObject(themeManager)
                .environmentObject(folderBookmarkService)
                .environmentObject(articleLibraryService)
                .environment(\.managedObjectContext, viewContext)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(themeManager.colors.background)
        }
        // FAB-334 phase 5: replaces the fixed-`width: 320` custom overlay (85% of an iPhone SE,
        // per the epic's own audit) with a real system sheet -- a grabber, fractional detents,
        // and Form-native sections/checkmarks instead of hand-rolled rows. Absorbs FAB-311's
        // ✕-collision pattern too: no competing close button, the grabber + swipe-to-dismiss
        // (plus the explicit Done below, since a Form full of actionable rows benefits from an
        // unambiguous confirm the way a plain scroll sheet doesn't) are enough.
        .sheet(isPresented: $showFilterPanel) {
            FilterSheet(
                tags: allTagsSorted,
                selectedTags: $selectedTags,
                datePreset: $datePreset
            )
            .environmentObject(themeManager)
            .presentationDetents([.medium, .large])
        }
        // FAB-334 phase 4: real navigation bar replaces `defaultHeaderRow`'s title + four
        // icons (absorbs the rest of FAB-310 -- real toolbar items instead of a hand-built
        // HStack of `.buttonStyle(.plain)` Images). FAB-334 phase 6: no longer hidden while
        // selecting either -- select mode now gets its own real title/toolbar below (R1
        // option (b), FAB-320's second half) instead of the old hand-built `selectionHeaderRow`.
        .navigationTitle(navigationTitleText)
        .tint(themeManager.colors.accent)
        // FAB-334 phase 5: replaces the hand-built `searchActiveRow`/`SearchBar` entirely --
        // no more manual search icon in the toolbar either, since `.searchable` supplies its
        // own entry point (and, on iOS 26, the bottom-anchored field automatically). `isSearching`
        // stays a binding rather than reading `\.isSearching` from the environment so the rest
        // of the toolbar (filter/add/overflow) stays visible and usable while searching --
        // narrowing by tag or date while also searching by text is a reasonable thing to want,
        // not something the old row's all-or-nothing swap allowed. Search and select mode stay
        // mutually exclusive though (phase 6, below) -- a search field next to "N Selected"
        // doesn't make sense the way search-plus-filter does.
        .searchable(text: $searchText, isPresented: $isSearching, prompt: L10n.Home.searchPlaceholder)
        .onChange(of: isSelecting) { _, newValue in
            if newValue { isSearching = false }
        }
        .onChange(of: isSearching) { _, newValue in
            if newValue { exitSelectMode() }
        }
        .toolbar {
            if isSelecting {
                // FAB-334 phase 6, R1 option (b): real toolbar Cancel/Done replace the old
                // hand-built `selectionHeaderRow`'s title + Cancel button (FAB-320's second
                // half) -- the selection model underneath (`selectedArticleIds`) is unchanged,
                // only this chrome is new. Both exit select mode the same way; there's no
                // "staged" action here to distinguish Cancel-as-undo from Done-as-commit,
                // since mark-read/delete already apply immediately.
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Home.bulkSelectCancel) { exitSelectMode() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Import.doneDoneButton) { exitSelectMode() }
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(VersoAnimation.normal) { showFilterPanel = true }
                    } label: {
                        Image(systemName: activeFilterCount > 0 ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .overlay(alignment: .topTrailing) {
                                if activeFilterCount > 0 {
                                    Text("\(activeFilterCount)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(themeManager.colors.background)
                                        .padding(.horizontal, 5)
                                        .frame(minWidth: 16, minHeight: 16)
                                        .background(Capsule().fill(themeManager.colors.accent))
                                        .offset(x: 8, y: -8)
                                }
                            }
                    }
                    .accessibilityLabel(L10n.Home.tagFilterButtonAccessibilityLabel)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddArticle = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(L10n.Home.addArticleAccessibilityLabel)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(L10n.Home.bulkSelectSelect) {
                            withAnimation(VersoAnimation.fast) { isSelecting = true }
                        }
                        Button(L10n.Home.settingsAccessibilityLabel) {
                            showSettings = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .accessibilityLabel(L10n.Home.overflowAccessibilityLabel)
                }
            }
        }
        // FAB-304: lives here, not inside ArticleListFetchedBody, deliberately. Originally
        // that struct was `.id(listFetchIdentity)`-keyed and got torn down and rebuilt on
        // every search/date change -- phase 5's R2 fix removed that `.id()` entirely (see
        // ArticleListFetchedBody's own `.onChange(of: listPredicate)`), so that specific
        // teardown path is gone. The other one isn't: ContentView's `.preferredColorScheme`
        // flipping across the light/dark boundary still forces a hosting-hierarchy rebuild
        // (confirmed again, the hard way, by the theme-picker regression phase 3 shipped --
        // see the plan doc's R3 section). A `navigationDestination` registered on a subtree
        // that rebuild tears down would disappear while `showSettings` (owned here, one level
        // up) survives as true -- a pushed slot with no destination left to resolve it, i.e.
        // a blank screen. Attaching it to this stable ancestor instead means nothing re-keys
        // it out from under the push. Unchanged by phases 4-5 -- only how `showSettings` gets
        // set (a real toolbar Menu item, phase 4) moved, not this attachment point.
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
    }

    /// FAB-334 phase 6, R1 option (b): the single exit path for select mode, called from both
    /// Cancel and Done (see the toolbar above) and from the two bulk actions once they finish.
    /// Replaces `headerRow`/`selectionHeaderRow` (FAB-292's hand-built title + Cancel row,
    /// deleted here -- its job is now the real nav bar/toolbar above).
    private func exitSelectMode() {
        withAnimation(VersoAnimation.fast) {
            isSelecting = false
            selectedArticleIds.removeAll()
        }
    }

    /// FAB-334 phase 5, absorbs FAB-319's remainder. Tag count shown as a bare digit next to a
    /// tag glyph rather than a pluralized "N tags" string -- same precedent as the section
    /// headers' counts (DONE.md, FAB-322): "a bare digit needs no localization". The date segment
    /// reuses `datePreset.displayLabel`, already localized. Reuses `L10n.Home.emptyNoResultsCta`
    /// ("Clear filters") for the clear button rather than adding new copy for one more phrasing
    /// of the same action.
    private var activeFilterSummaryRow: some View {
        HStack(spacing: VersoSpacing.xs) {
            if !selectedTags.isEmpty {
                Image(systemName: "tag")
                Text("\(selectedTags.count)")
            }
            if !selectedTags.isEmpty && datePreset != .any {
                Text("·")
            }
            if datePreset != .any {
                Text(datePreset.displayLabel)
            }
            Spacer()
            Button {
                withAnimation(VersoAnimation.fast) { clearActiveFilters() }
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .accessibilityLabel(L10n.Home.emptyNoResultsCta)
        }
        .font(VersoTypography.UI.caption)
        .foregroundColor(themeManager.colors.textSecondary)
    }

    private func clearActiveFilters() {
        selectedTags.removeAll()
        datePreset = .any
    }

    // MARK: - Predicate helpers

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
    /// FAB-319: clears search text, date preset, and tags -- the three facets
    /// `narrowedListShowsMiss` checks. Lives here as a closure rather than two more
    /// bindings since `searchText`/`datePreset` are otherwise private to the parent.
    let onClearFilters: () -> Void

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
        showAddArticle: Binding<Bool>,
        onClearFilters: @escaping () -> Void
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
        self.onClearFilters = onClearFilters

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

    /// FAB-322's select-mode layout shift: entering/exiting select mode still changes
    /// `ArticleCard`'s available width, since R1 option (b) (phase 6) means there's no
    /// system-owned row inset to draw the checkbox in instead -- real `List(selection:
    /// Set<ID>>)` was rejected specifically to keep scroll position and section state
    /// across that transition (see the plan doc's R1). Reserving the checkbox's width
    /// permanently, selecting or not, would trade a temporary shift for a permanent one
    /// (narrower cards always). Chose the smaller fix instead: the toggle itself now
    /// animates (`withAnimation` in `exitSelectMode()` and the toolbar's "Select" action),
    /// so the shift is a smooth transition rather than a pop -- not eliminated, softened.
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
                EmptyState(
                    variant: narrowedListShowsMiss ? .searchMiss : .empty,
                    onAction: narrowedListShowsMiss ? onClearFilters : { showAddArticle = true }
                )
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
                        count: continueReadingArticles.count,
                        accessibilityLabel: L10n.Home.sectionContinueReadingAccessibilityLabel(count: continueReadingArticles.count)
                    )
                    articleRows(continueReadingArticles, showsProgress: true)
                }

                if !unreadArticles.isEmpty {
                    sectionHeader(
                        title: L10n.Filter.unread,
                        count: unreadArticles.count,
                        accessibilityLabel: L10n.Filter.unreadAccessibilityLabel(count: unreadArticles.count)
                    )
                    articleRows(unreadArticles)
                }

                if !readArticles.isEmpty {
                    collapsibleSectionHeader(
                        title: L10n.Filter.read,
                        count: readArticles.count,
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
                        count: archivedArticles.count,
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
        // FAB-334 phase 5, R2 fix: this view used to be `.id(listFetchIdentity)`-keyed by the
        // parent so a changed predicate would force a fresh `@FetchRequest` init -- but that
        // tore down and rebuilt this entire view (including `isReadExpanded`/`isArchivedExpanded`
        // and, per the FAB-304 comment on `ArticleListView`, put a `navigationDestination` at
        // risk if it were ever attached here) on every single keystroke, well before `.searchable`
        // made that jank visible. `$articles` (the `@FetchRequest` projected value) exposes a
        // mutable `nsPredicate` for exactly this: push the new predicate into the existing fetch
        // in place, no view identity change, nothing torn down.
        .onChange(of: listPredicate) { _, newPredicate in
            $articles.nsPredicate.wrappedValue = newPredicate
        }
        .refreshable {
            guard let url = folderBookmarkService.folderURL else { return }
            await articleLibraryService.rebuildCache(from: url, context: viewContext)
        }
        // FAB-334 phase 6, R1 option (b): replaces the hand-built `safeAreaInset` bottom bar
        // with real bottom toolbar items -- `.buttonStyle(.plain)` is gone, so
        // `Button(role: .destructive)` renders red for free (FAB-320's first half, "delete
        // isn't red"). The selection model underneath is unchanged; only this chrome moved.
        .toolbar {
            if isSelecting, !selectedArticleIds.isEmpty {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(L10n.Home.bulkSelectMarkRead) {
                        markSelectedArticlesRead()
                    }
                    Spacer()
                    Button(L10n.Home.bulkSelectDelete, role: .destructive) {
                        confirmBulkDelete = true
                    }
                }
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

    // FAB-322: the count was already reaching VoiceOver via `accessibilityLabel`
    // ("Unread, 12 articles") but never rendered on screen -- a sighted user just saw
    // "Unread". The old chip bar showed it; this restores that without new chrome, a
    // bare digit needs no localization. Also raised top padding (was `.md`, 16pt) to
    // `.lg` (24pt) so sections read as separated groups, not barely-wider card gaps.
    private func sectionHeader(title: String, count: Int, accessibilityLabel: String) -> some View {
        HStack(spacing: VersoSpacing.xs) {
            Text(title)
                .font(VersoTypography.UI.listTitle)
                .foregroundColor(themeManager.colors.textPrimary)
            Text("\(count)")
                .font(VersoTypography.UI.listTitle)
                .foregroundColor(themeManager.colors.textSecondary)
        }
        .padding(.horizontal, VersoSpacing.md)
        .padding(.top, VersoSpacing.lg)
        .padding(.bottom, VersoSpacing.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func collapsibleSectionHeader(title: String, count: Int, accessibilityLabel: String, isExpanded: Binding<Bool>) -> some View {
        Button {
            withAnimation(VersoAnimation.fast) { isExpanded.wrappedValue.toggle() }
        } label: {
            HStack(spacing: VersoSpacing.xs) {
                Text(title)
                    .font(VersoTypography.UI.listTitle)
                    .foregroundColor(themeManager.colors.textPrimary)
                Text("\(count)")
                    .font(VersoTypography.UI.listTitle)
                    .foregroundColor(themeManager.colors.textSecondary)
                Spacer()
                Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.colors.textSecondary)
            }
            .padding(.horizontal, VersoSpacing.md)
            .padding(.top, VersoSpacing.lg)
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
                    // FAB-334 phase 6: `.buttonStyle(.plain)` dropped -- inside a `List` row
                    // the default style gives real tap feedback (the standard row-highlight
                    // flash), rather than this Button being an inert wrapper. The checkbox
                    // icon itself stays hand-drawn either way (see `rowLabel`'s own comment).
                    Button {
                        if selectedArticleIds.contains(article.id) {
                            selectedArticleIds.remove(article.id)
                        } else {
                            selectedArticleIds.insert(article.id)
                        }
                    } label: {
                        rowLabel(for: article, showsProgress: showsProgress)
                    }
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
                    withAnimation(VersoAnimation.fast) { isSelecting = true }
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
                    // FAB-325: theme-aware, reusing the `archived` status color rather than
                    // `colors.accent` -- accent is deliberately bright in Night/Ink for a
                    // *different* foreground pairing (FAB-305), which this swipe label's
                    // system-fixed white text can't use.
                    .tint(ArticleStatusColors.colors(for: themeManager.currentTheme).archived)
                    .accessibilityLabel(L10n.A11y.unarchiveAction)
                } else {
                    Button {
                        archiveArticle(article)
                    } label: {
                        Label(L10n.Swipe.archive, systemImage: "archivebox")
                    }
                    .tint(ArticleStatusColors.colors(for: themeManager.currentTheme).archived)
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
                .tint(
                    isRead
                        ? ArticleStatusColors.colors(for: themeManager.currentTheme).unread
                        : ArticleStatusColors.colors(for: themeManager.currentTheme).read
                )
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
        withAnimation(VersoAnimation.fast) {
            selectedArticleIds.removeAll()
            isSelecting = false
        }
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
        withAnimation(VersoAnimation.fast) {
            selectedArticleIds.removeAll()
            isSelecting = false
        }
    }
}

// MARK: - Filter sheet (tags + date range)

/// FAB-334 phase 5: replaces the fixed-`width: 320` custom overlay `FilterPanel` (~85% of an
/// iPhone SE screen, per the epic's own audit) with a real system sheet -- inset-grouped `Form`
/// sections instead of hand-rolled rows, a real `Picker` for the single-select date range, and
/// the tag search field hidden entirely when the library has no tags (FAB-319's remainder).
private struct FilterSheet: View {
    let tags: [String]
    @Binding var selectedTags: Set<String>
    @Binding var datePreset: ArticleListDatePreset

    @Environment(\.dismiss) private var dismiss
    @State private var tagQuery: String = ""

    private var filteredTags: [String] {
        let q = tagQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return tags }
        return tags.filter { $0.localizedCaseInsensitiveContains(q) }
    }

    private var activeFilterCount: Int {
        selectedTags.count + (datePreset == .any ? 0 : 1)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.Home.dateFilterLabel) {
                    Picker(L10n.Home.dateFilterLabel, selection: $datePreset) {
                        ForEach(ArticleListDatePreset.allCases) { preset in
                            Text(preset.displayLabel).tag(preset)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                // FAB-319: hidden entirely when there are no tags to filter by, rather than
                // showing a search field above a lone "All tags" row that searches nothing.
                if !tags.isEmpty {
                    Section(L10n.Home.tagFilterTitle) {
                        tagRow(title: L10n.Home.tagFilterAllTags, isSelected: selectedTags.isEmpty) {
                            selectedTags.removeAll()
                        }

                        if filteredTags.isEmpty && !tagQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(L10n.Home.tagFilterNoMatches)
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(filteredTags, id: \.self) { tag in
                                tagRow(title: tag, isSelected: selectedTags.contains(tag)) {
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
            .navigationTitle(L10n.Home.filterPanelTitle)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $tagQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: L10n.Home.tagFilterSearchPlaceholder
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Home.emptyNoResultsCta) {
                        selectedTags.removeAll()
                        datePreset = .any
                    }
                    .disabled(activeFilterCount == 0)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Import.doneDoneButton) { dismiss() }
                }
            }
        }
    }

    /// FAB-322: date presets and tags previously shared one hand-rolled row differing only in
    /// checkmark style -- dates are now a real `Picker` above, which draws its own radio-style
    /// selection for free. This row stays for tags, which are multi-select and so still need an
    /// explicit checkmark rather than a `Picker`'s single-selection model.
    private func tagRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}
