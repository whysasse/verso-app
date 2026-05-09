import SwiftUI
import CoreData

@main
struct VersoApp: App {
    @StateObject private var themeManager = ThemeManager()
    private let context = CoreDataStack.shared.persistentContainer.viewContext

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, context)
                .environmentObject(themeManager)
                .onAppear { applyWindowBackground() }
                .onChange(of: themeManager.currentTheme) { _ in applyWindowBackground() }
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