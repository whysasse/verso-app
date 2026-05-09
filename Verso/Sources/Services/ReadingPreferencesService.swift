import SwiftUI

final class ReadingPreferencesService: ObservableObject {
    @Published var fontFamily: String {
        didSet { UserDefaults.standard.set(fontFamily, forKey: Keys.fontFamily) }
    }
    @Published var fontSize: CGFloat {
        didSet { UserDefaults.standard.set(Double(fontSize), forKey: Keys.fontSize) }
    }
    @Published var lineSpacing: Int {
        didSet { UserDefaults.standard.set(lineSpacing, forKey: Keys.lineSpacing) }
    }

    init() {
        let savedFamily = UserDefaults.standard.string(forKey: Keys.fontFamily)
        fontFamily = savedFamily ?? "Georgia"

        let savedSize = UserDefaults.standard.double(forKey: Keys.fontSize)
        fontSize = savedSize > 0 ? CGFloat(savedSize) : 18

        lineSpacing = UserDefaults.standard.object(forKey: Keys.lineSpacing) != nil
            ? UserDefaults.standard.integer(forKey: Keys.lineSpacing)
            : 1
    }

    private enum Keys {
        static let fontFamily = "readingFontFamily"
        static let fontSize = "readingFontSize"
        static let lineSpacing = "readingLineSpacing"
    }
}
