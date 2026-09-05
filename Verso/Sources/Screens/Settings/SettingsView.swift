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

    private var colors: ThemeColors { themeManager.colors }

    private let availableFonts: [(name: String, displayName: String)] = [
        ("Georgia", "Georgia"),
        ("NewYork", "New York"),
        ("OpenDyslexic-Regular", "OpenDyslexic"),
        ("", "System"),
    ]

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                generalSection
                Rectangle().frame(height: 1).foregroundColor(colors.border).padding(.horizontal, VersoSpacing.md)
                readingSection
                Rectangle().frame(height: 1).foregroundColor(colors.border).padding(.horizontal, VersoSpacing.md)
                storageSection
                Rectangle().frame(height: 1).foregroundColor(colors.border).padding(.horizontal, VersoSpacing.md)
                aboutSection
                Rectangle().frame(height: 1).foregroundColor(colors.border).padding(.horizontal, VersoSpacing.md)
                privacySection
                #if DEBUG
                Rectangle().frame(height: 1).foregroundColor(colors.border).padding(.horizontal, VersoSpacing.md)
                debugSection
                #endif
            }
            .frame(maxWidth: 680, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(colors.background.ignoresSafeArea())
        .versoNavigationBar(title: L10n.Settings.title)
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
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(L10n.Settings.sectionGeneral)

            sectionLabel(L10n.Settings.languageSectionLabel)
            VStack(spacing: 0) {
                ForEach(AppLocale.allCases) { locale in
                    let isSelected = localeManager.selectedLocale == locale
                    SettingsRow(
                        type: .language(name: locale.displayName, isSelected: isSelected),
                        action: {
                            guard !isSelected else { return }
                            localeManager.selectedLocale = locale
                            showLanguageRestartAlert = true
                        }
                    )
                    .padding(.horizontal, VersoSpacing.md)
                    if locale != AppLocale.allCases.last {
                        Rectangle().frame(height: 1).foregroundColor(colors.border).padding(.horizontal, VersoSpacing.md)
                    }
                }
            }
            .padding(.bottom, VersoSpacing.sm)
        }
    }

    private var readingSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(L10n.Settings.sectionReading)

            // Font picker
            sectionLabel(L10n.Settings.fontSectionLabel)
            VStack(spacing: 0) {
                ForEach(availableFonts, id: \.name) { font in
                    let isSelected = readingPreferences.fontFamily == font.name
                    SettingsRow(
                        type: .font(
                            name: font.displayName,
                            preview: L10n.Settings.fontPreview,
                            isSelected: isSelected
                        ),
                        action: { readingPreferences.fontFamily = font.name }
                    )
                    .padding(.horizontal, VersoSpacing.md)
                    if font.name != availableFonts.last?.name {
                        Rectangle().frame(height: 1).foregroundColor(colors.border).padding(.horizontal, VersoSpacing.md)
                    }
                }
            }

            Rectangle().frame(height: 1).foregroundColor(colors.border).padding(.horizontal, VersoSpacing.md).padding(.top, VersoSpacing.sm)

            // Font size
            HStack {
                Text(L10n.Settings.fontSizeSectionLabel)
                    .font(VersoTypography.UI.input)
                    .foregroundColor(colors.textPrimary)
                Spacer()
                HStack(spacing: VersoSpacing.sm) {
                    let currentBodySize = VersoTypography.Reading.BodySize.nearest(to: readingPreferences.fontSize)

                    Button {
                        readingPreferences.fontSize = currentBodySize.stepped(by: -1).rawValue
                    } label: {
                        Image(systemName: "minus")
                            .frame(width: 32, height: 32)
                            .foregroundColor(currentBodySize != .xs ? colors.accent : colors.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(currentBodySize == .xs)

                    Text(L10n.Settings.fontSizeValueLabel(size: Int(readingPreferences.fontSize)))
                        .font(VersoTypography.UI.caption)
                        .foregroundColor(colors.textSecondary)
                        .frame(minWidth: 36, alignment: .center)

                    Button {
                        readingPreferences.fontSize = currentBodySize.stepped(by: 1).rawValue
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 32, height: 32)
                            .foregroundColor(currentBodySize != .xxl ? colors.accent : colors.textSecondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(currentBodySize == .xxl)
                }
            }
            .frame(minHeight: 44)
            .padding(.horizontal, VersoSpacing.md)

            Rectangle().frame(height: 1).foregroundColor(colors.border).padding(.horizontal, VersoSpacing.md)

            // Theme
            sectionLabel(L10n.ReaderSettings.themeSectionLabel)
            SettingsRow(type: .theme)
                .padding(.horizontal, VersoSpacing.md)
                .padding(.bottom, VersoSpacing.sm)
        }
    }

    private var storageSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(L10n.Settings.sectionStorage)

            let folderPath = folderBookmarkService.folderURL?.lastPathComponent ?? L10n.Settings.folderEmptyValue
            SettingsRow(
                type: .folder(label: L10n.Settings.folderRowLabel, path: folderPath),
                action: { showFolderPicker = true }
            )
            .padding(.horizontal, VersoSpacing.md)

            Rectangle().frame(height: 1).foregroundColor(colors.border).padding(.horizontal, VersoSpacing.md)

            SettingsRow(
                type: .default(label: L10n.Settings.importRowLabel),
                action: { showImport = true }
            )
            .padding(.horizontal, VersoSpacing.md)
        }
    }

    #if DEBUG
    /// FAB-298 calibration tool -- see `RelatedArticlesDebugView`. Not present in a Release build.
    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Debug")

            NavigationLink(destination: RelatedArticlesDebugView()) {
                SettingsRow(type: .default(label: "Related Articles Debug"), usesButtonChrome: false)
                    .padding(.horizontal, VersoSpacing.md)
            }
            .buttonStyle(.plain)
        }
    }
    #endif

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(L10n.Settings.sectionAbout)

            NavigationLink(destination: AboutView()) {
                SettingsRow(type: .default(label: L10n.Settings.aboutVersionRowLabel(version: appVersion)), usesButtonChrome: false)
                    .padding(.horizontal, VersoSpacing.md)
            }
            .buttonStyle(.plain)

            Rectangle().frame(height: 1).foregroundColor(colors.border).padding(.horizontal, VersoSpacing.md)

            NavigationLink(destination: PrivacyPolicyView()) {
                SettingsRow(type: .default(label: L10n.Settings.privacyPolicyRowLabel), usesButtonChrome: false)
                    .padding(.horizontal, VersoSpacing.md)
            }
            .buttonStyle(.plain)
        }
    }

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(L10n.Settings.sectionPrivacy)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.Settings.analyticsRowLabel)
                        .font(VersoTypography.UI.input)
                        .foregroundColor(colors.textPrimary)
                    Text(L10n.Settings.analyticsSubtitle)
                        .font(VersoTypography.UI.caption)
                        .foregroundColor(colors.textSecondary)
                }
                Spacer()
                Toggle("", isOn: $analyticsOptIn)
                    .labelsHidden()
                    .tint(colors.accent)
                    .onChange(of: analyticsOptIn) { newValue in
                        if newValue {
                            AnalyticsService.shared.optIn()
                        } else {
                            AnalyticsService.shared.isOptedIn = false
                        }
                    }
            }
            .frame(minHeight: 44)
            .padding(.horizontal, VersoSpacing.md)
            .padding(.vertical, VersoSpacing.sm)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(VersoTypography.UI.caption)
            .foregroundColor(colors.textSecondary)
            .padding(.horizontal, VersoSpacing.md)
            .padding(.top, VersoSpacing.lg)
            .padding(.bottom, VersoSpacing.xs)
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(VersoTypography.UI.caption)
            .foregroundColor(colors.textSecondary)
            .padding(.horizontal, VersoSpacing.md)
            .padding(.top, VersoSpacing.sm)
            .padding(.bottom, VersoSpacing.xxs)
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
