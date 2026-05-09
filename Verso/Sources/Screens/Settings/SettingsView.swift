import SwiftUI
import CoreData

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
    @EnvironmentObject var articleLibraryService: ArticleLibraryService
    @EnvironmentObject var readingPreferences: ReadingPreferencesService
    @Environment(\.managedObjectContext) var viewContext

    @State private var showFolderPicker = false
    @State private var showMoveDialog = false
    @State private var pendingNewURL: URL? = nil

    private var colors: ThemeColors { themeManager.colors }

    private let availableFonts: [(name: String, displayName: String)] = [
        ("Georgia", "Georgia"),
        ("NewYork", "New York"),
        (".AppleSystemUIFont", "System"),
    ]

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                readingSection
                Divider().background(colors.border).padding(.horizontal, VersoSpacing.md)
                storageSection
                Divider().background(colors.border).padding(.horizontal, VersoSpacing.md)
                aboutSection
            }
        }
        .background(colors.background.ignoresSafeArea())
        .versoNavigationBar(title: "Settings")
        .sheet(isPresented: $showFolderPicker) {
            DocumentPicker { urls in
                guard let newURL = urls.first else { return }
                handleFolderSelection(newURL)
            }
        }
        .confirmationDialog(
            "Move your existing articles to the new folder?",
            isPresented: $showMoveDialog,
            titleVisibility: .visible
        ) {
            Button("Move Articles") {
                guard let url = pendingNewURL else { return }
                Task { await switchFolder(to: url, move: true) }
            }
            Button("Keep in Old Folder") {
                guard let url = pendingNewURL else { return }
                Task { await switchFolder(to: url, move: false) }
            }
            Button("Cancel", role: .cancel) { pendingNewURL = nil }
        } message: {
            Text("Your old folder won't be touched if you choose No.")
        }
    }

    // MARK: - Sections

    private var readingSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Reading")

            // Font picker
            sectionLabel("Font")
            VStack(spacing: 0) {
                ForEach(availableFonts, id: \.name) { font in
                    let isSelected = readingPreferences.fontFamily == font.name
                    Button {
                        readingPreferences.fontFamily = font.name
                    } label: {
                        SettingsRow(type: .font(
                            name: font.name,
                            preview: "The quick brown fox jumps over the lazy dog",
                            isSelected: isSelected
                        ))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, VersoSpacing.md)
                    if font.name != availableFonts.last?.name {
                        Divider().background(colors.border).padding(.horizontal, VersoSpacing.md)
                    }
                }
            }

            Divider().background(colors.border).padding(.horizontal, VersoSpacing.md).padding(.top, VersoSpacing.sm)

            // Font size
            HStack {
                Text("Size")
                    .font(VersoTypography.UI.input)
                    .foregroundColor(colors.textPrimary)
                Spacer()
                HStack(spacing: VersoSpacing.sm) {
                    Button {
                        if readingPreferences.fontSize > 14 {
                            readingPreferences.fontSize -= 2
                        }
                    } label: {
                        Image(systemName: "minus")
                            .frame(width: 32, height: 32)
                            .foregroundColor(readingPreferences.fontSize > 14 ? colors.accent : colors.textSecondary)
                    }
                    .buttonStyle(.plain)

                    Text("\(Int(readingPreferences.fontSize))pt")
                        .font(VersoTypography.UI.caption)
                        .foregroundColor(colors.textSecondary)
                        .frame(minWidth: 36, alignment: .center)

                    Button {
                        if readingPreferences.fontSize < 26 {
                            readingPreferences.fontSize += 2
                        }
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 32, height: 32)
                            .foregroundColor(readingPreferences.fontSize < 26 ? colors.accent : colors.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(minHeight: 44)
            .padding(.horizontal, VersoSpacing.md)

            Divider().background(colors.border).padding(.horizontal, VersoSpacing.md)

            // Theme
            sectionLabel("Theme")
            SettingsRow(type: .theme)
                .padding(.horizontal, VersoSpacing.md)
                .padding(.bottom, VersoSpacing.sm)
        }
    }

    private var storageSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Storage")

            let folderPath = folderBookmarkService.folderURL?.lastPathComponent ?? "Not set"
            SettingsRow(
                type: .folder(label: "Articles folder", path: folderPath),
                action: { showFolderPicker = true }
            )
            .padding(.horizontal, VersoSpacing.md)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("About")

            SettingsRow(type: .default(label: "Version \(appVersion)"))
                .padding(.horizontal, VersoSpacing.md)
            Divider().background(colors.border).padding(.horizontal, VersoSpacing.md)

            SettingsRow(type: .default(label: "Privacy Policy"), action: {
                if let url = URL(string: "https://fabiosasseron.com/verso/privacy") {
                    UIApplication.shared.open(url)
                }
            })
            .padding(.horizontal, VersoSpacing.md)
            Divider().background(colors.border).padding(.horizontal, VersoSpacing.md)

            SettingsRow(type: .default(label: "Open Source"), action: {
                if let url = URL(string: "https://github.com/whysasse/verso-app") {
                    UIApplication.shared.open(url)
                }
            })
            .padding(.horizontal, VersoSpacing.md)
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
}
