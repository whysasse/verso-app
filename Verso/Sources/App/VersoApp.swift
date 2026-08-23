import SwiftUI
import CoreData
import TelemetryDeck

@main
struct VersoApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var folderBookmarkService = FolderBookmarkService()
    @StateObject private var articleLibraryService = ArticleLibraryService()
    @StateObject private var readingPreferences = ReadingPreferencesService()
    @StateObject private var fileWatcher = ICloudFileWatcher()
    @Environment(\.scenePhase) private var scenePhase
    private let context = CoreDataStack.shared.persistentContainer.viewContext

    init() {
        AnalyticsService.shared.initializeIfOptedIn()
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme")
        let theme = VersoTheme(rawValue: savedTheme ?? "Paper") ?? .paper
        UIWindow.appearance().backgroundColor = UIColor(ThemeColors.colors(for: theme).background)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, context)
                .environmentObject(themeManager)
                .environmentObject(folderBookmarkService)
                .environmentObject(articleLibraryService)
                .environmentObject(readingPreferences)
                .onAppear {
                    folderBookmarkService.restore()
                    applyWindowBackground()
                    Task { await PendingArticleIngester().ingest(folderURL: folderBookmarkService.folderURL, context: context) }
                    if let url = folderBookmarkService.folderURL {
                        startWatcher(url: url)
                    }
                    #if DEBUG
                    DebugSeedService.seedIfNeeded(context: context)
                    #endif
                }
                .onChange(of: themeManager.currentTheme) { _ in applyWindowBackground() }
                .onChange(of: scenePhase) { phase in
                    if phase == .background {
                        fileWatcher.stop()
                        folderBookmarkService.stopAccess()
                    } else if phase == .active {
                        Task { await PendingArticleIngester().ingest(folderURL: folderBookmarkService.folderURL, context: context) }
                        if let url = folderBookmarkService.folderURL {
                            startWatcher(url: url)
                            Task { await articleLibraryService.rebuildCache(from: url, context: context) }
                        }
                    }
                }
                .onChange(of: folderBookmarkService.folderURL) { url in
                    guard let url else { return }
                    Task { await articleLibraryService.rebuildCache(from: url, context: context) }
                    startWatcher(url: url)
                    if scenePhase == .background { folderBookmarkService.stopAccess() }
                    if scenePhase == .active {
                        Task { await PendingArticleIngester().ingest(folderURL: folderBookmarkService.folderURL, context: context) }
                    }
                }
        }
    }

    private func startWatcher(url: URL) {
        fileWatcher.onChange = { [self] in
            Task { await articleLibraryService.rebuildCache(from: url, context: context) }
        }
        fileWatcher.start(folderURL: url)
    }

    private func applyWindowBackground() {
        let color = UIColor(themeManager.colors.background)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.backgroundColor = color }
    }
}
