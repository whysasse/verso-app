import SwiftUI
import CoreData

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
    @EnvironmentObject var articleLibraryService: ArticleLibraryService
    @EnvironmentObject var readingPreferences: ReadingPreferencesService
    @EnvironmentObject var localeManager: LocaleManager
    @Environment(\.managedObjectContext) var viewContext

    @State private var showFolderPicker = false
    @State private var showMoveDialog = false
    @State private var pendingNewURL: URL? = nil
    @State private var showImport = false
    @State private var showLanguageRestartAlert = false
    @State private var analyticsOptIn = AnalyticsService.shared.isOptedIn

    private let availableFonts: [(name: String, displayName: String)] = [
        ("Georgia", "Georgia"),
        ("NewYork", "New York"),
        ("OpenDyslexic-Regular", "OpenDyslexic"),
        ("", "System"),
    ]

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var currentFontDisplayName: String {
        availableFonts.first { $0.name == readingPreferences.fontFamily }?.displayName ?? availableFonts.last!.displayName
    }

    // FAB-334 phase 3: SettingsView is now a real `Form` — inset-grouped sections,
    // system checkmarks/section headers/value+chevron rows for free, instead of the
    // hand-built `ScrollView` of `VStack`s this replaces. Absorbs most of FAB-329,
    // FAB-325's divider half (`Form`/`List` draw their own separators), FAB-310's
    // Settings font stepper (32x32 -> real 44x44 below), FAB-309's deferred
    // Settings-row layout audit, and FAB-313 (a real `Toggle(label, isOn:)`
    // announces its own name to VoiceOver for free).
    var body: some View {
        Form {
            generalSection
            readingSection
            storageSection
            aboutSection
            privacySection
            #if DEBUG
            debugSection
            #endif
        }
        .tint(themeManager.colors.accent)
        .navigationTitle(L10n.Settings.title)
        .sheet(isPresented: $showImport) {
            ImportView()
                .environmentObject(themeManager)
                .environmentObject(folderBookmarkService)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showFolderPicker) {
            DocumentPicker { urls in
                guard let newURL = urls.first else { return }
                handleFolderSelection(newURL)
            }
        }
        .confirmationDialog(
            L10n.Dialog.changeFolderTitle,
            isPresented: $showMoveDialog,
            titleVisibility: .visible
        ) {
            Button(L10n.Dialog.changeFolderYes) {
                guard let url = pendingNewURL else { return }
                Task { await switchFolder(to: url, move: true) }
            }
            Button(L10n.Dialog.changeFolderNo) {
                guard let url = pendingNewURL else { return }
                Task { await switchFolder(to: url, move: false) }
            }
            Button(L10n.Dialog.changeFolderCancel, role: .cancel) { pendingNewURL = nil }
        } message: {
            Text(L10n.Dialog.changeFolderMessage)
        }
        .alert(L10n.Settings.languageRestartTitle, isPresented: $showLanguageRestartAlert) {
            Button(L10n.Settings.languageRestartButton) { }
        } message: {
            Text(L10n.Settings.languageRestartMessage)
        }
    }

    // MARK: - Sections

    private var generalSection: some View {
        Section(L10n.Settings.sectionGeneral) {
            NavigationLink {
                LanguagePickerView(onSelect: { _ in showLanguageRestartAlert = true })
            } label: {
                LabeledContent(L10n.Settings.languageSectionLabel, value: localeManager.selectedLocale.displayName)
            }
        }
    }

    private var readingSection: some View {
        Section(L10n.Settings.sectionReading) {
            NavigationLink {
                FontPickerView()
            } label: {
                LabeledContent(L10n.Settings.fontSectionLabel, value: currentFontDisplayName)
            }

            // Font size: kept as an inline stepper (not a picker push -- this is a
            // frequent, low-friction adjustment) but the +/- buttons grow from the
            // old 32x32 to a real 44x44 minimum tappable target, closing FAB-310's
            // last Settings offender.
            HStack {
                Text(L10n.Settings.fontSizeSectionLabel)
                Spacer()
                HStack(spacing: VersoSpacing.sm) {
                    let currentBodySize = VersoTypography.Reading.BodySize.nearest(to: readingPreferences.fontSize)

                    Button {
                        readingPreferences.fontSize = currentBodySize.stepped(by: -1).rawValue
                    } label: {
                        Image(systemName: "minus")
                    }
                    .frame(width: 44, height: 44)
                    .disabled(currentBodySize == .xs)

                    Text(L10n.Settings.fontSizeValueLabel(size: Int(readingPreferences.fontSize)))
                        .font(VersoTypography.UI.caption)
                        .foregroundColor(.secondary)
                        .frame(minWidth: 36, alignment: .center)

                    Button {
                        readingPreferences.fontSize = currentBodySize.stepped(by: 1).rawValue
                    } label: {
                        Image(systemName: "plus")
                    }
                    .frame(width: 44, height: 44)
                    .disabled(currentBodySize == .xxl)
                }
                .buttonStyle(.borderless)
            }

            // FAB-334 phase 3 fix (2026-09-12): this was originally a `NavigationLink`
            // push to a separate `ThemePickerView` -- but changing the theme from two
            // levels deep (List -> Settings -> ThemePickerView) crosses the light/dark
            // boundary and blanks the screen, the exact FAB-304 failure mode. That fix
            // only ever protected Settings' own presentation (`showSettings`, kept on a
            // stable ancestor) -- a second, deeper push was never part of what was
            // tested or fixed. Reverted to an inline row, exactly `ThemeSelector`'s old
            // layout (now deleted), which *was* part of FAB-304's on-device-confirmed
            // safe set: no extra push depth, so no extra exposure to the rebuild.
            VStack(alignment: .leading, spacing: VersoSpacing.xs) {
                Text(L10n.ReaderSettings.themeSectionLabel)
                HStack(spacing: VersoSpacing.lg) {
                    ForEach(VersoTheme.allCases) { theme in
                        let isSelected = themeManager.currentTheme == theme
                        Button {
                            themeManager.currentTheme = theme
                        } label: {
                            ThemeSwatch(theme: theme, isSelected: isSelected, activeColors: themeManager.colors, height: 32)
                                .frame(width: 80, height: 100)
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                    }
                }
            }
        }
    }

    private var storageSection: some View {
        Section(L10n.Settings.sectionStorage) {
            Button {
                showFolderPicker = true
            } label: {
                LabeledContent(L10n.Settings.folderRowLabel) {
                    Text(folderBookmarkService.folderURL?.lastPathComponent ?? L10n.Settings.folderEmptyValue)
                }
            }
            .buttonStyle(.plain)

            Button(L10n.Settings.importRowLabel) {
                showImport = true
            }
        }
    }

    #if DEBUG
    /// FAB-298 calibration tool -- see `RelatedArticlesDebugView`. Not present in a Release build.
    private var debugSection: some View {
        Section("Debug") {
            NavigationLink("Related Articles Debug", destination: RelatedArticlesDebugView())
        }
    }
    #endif

    private var aboutSection: some View {
        Section(L10n.Settings.sectionAbout) {
            NavigationLink(L10n.Settings.aboutVersionRowLabel(version: appVersion), destination: AboutView())
            NavigationLink(L10n.Settings.privacyPolicyRowLabel, destination: PrivacyPolicyView())
        }
    }

    private var privacySection: some View {
        Section(L10n.Settings.sectionPrivacy) {
            Toggle(isOn: $analyticsOptIn) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.Settings.analyticsRowLabel)
                    Text(L10n.Settings.analyticsSubtitle)
                        .font(VersoTypography.UI.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onChange(of: analyticsOptIn) { newValue in
                if newValue {
                    AnalyticsService.shared.optIn()
                } else {
                    AnalyticsService.shared.isOptedIn = false
                }
            }
        }
    }

    // MARK: - Folder Change Logic (FAB-48)

    private func handleFolderSelection(_ newURL: URL) {
        guard newURL != folderBookmarkService.folderURL else { return }

        if let oldURL = folderBookmarkService.folderURL,
           hasMarkdownFiles(in: oldURL) {
            pendingNewURL = newURL
            showMoveDialog = true
        } else {
            Task { await switchFolder(to: newURL, move: false) }
        }
    }

    private func hasMarkdownFiles(in url: URL) -> Bool {
        let files = (try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )) ?? []
        return files.contains { $0.pathExtension == "md" }
    }

    @MainActor
    private func switchFolder(to newURL: URL, move: Bool) async {
        if move, let oldURL = folderBookmarkService.folderURL {
            _ = oldURL.startAccessingSecurityScopedResource()
            _ = newURL.startAccessingSecurityScopedResource()
            let files = (try? FileManager.default.contentsOfDirectory(
                at: oldURL,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            ))?.filter { $0.pathExtension == "md" } ?? []

            for file in files {
                let dest = newURL.appendingPathComponent(file.lastPathComponent)
                try? FileManager.default.copyItem(at: file, to: dest)
                try? FileManager.default.removeItem(at: file)
            }
            oldURL.stopAccessingSecurityScopedResource()
        }

        folderBookmarkService.save(url: newURL)
        await articleLibraryService.rebuildCache(from: newURL, context: viewContext)
        pendingNewURL = nil
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(ThemeManager())
    .environmentObject(FolderBookmarkService())
    .environmentObject(ArticleLibraryService())
    .environmentObject(ReadingPreferencesService())
    .environmentObject(LocaleManager())
}
