import SwiftUI
import CoreData

@main
struct VersoApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var folderBookmarkService = FolderBookmarkService()
    @Environment(\.scenePhase) private var scenePhase
    private let context = CoreDataStack.shared.persistentContainer.viewContext

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, context)
                .environmentObject(themeManager)
                .environmentObject(folderBookmarkService)
                .onAppear {
                    folderBookmarkService.restore()
                    applyWindowBackground()
                    #if DEBUG
                    DebugSeedService.seedIfNeeded(context: context)
                    #endif
                }
                .onChange(of: themeManager.currentTheme) { _ in applyWindowBackground() }
                .onChange(of: scenePhase) { phase in
                    if phase == .background { folderBookmarkService.stopAccess() }
                }
        }
    }

    private func applyWindowBackground() {
        let color = UIColor(themeManager.colors.background)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.backgroundColor = color }
    }
}