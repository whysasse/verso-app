import SwiftUI
import CoreData

@main
struct VersoApp: App {
    @StateObject private var themeManager = ThemeManager()
    private let context = CoreDataStack.shared.context

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, context)
                .environmentObject(themeManager)
        }
    }
}