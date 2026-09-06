import SwiftUI

final class ReadingPreferencesService: ObservableObject {
    @Published var fontFamily: String {
        didSet {
            UserDefaults.standard.set(fontFamily, forKey: Keys.fontFamily)
            AnalyticsService.shared.track("settings.fontChanged", parameters: ["font": fontFamily.isEmpty ? "System" : fontFamily])
        }
    }
    @Published var fontSize: CGFloat {
        didSet { UserDefaults.standard.set(Double(fontSize), forKey: Keys.fontSize) }
    }
    @Published var lineSpacing: Int {
        didSet { UserDefaults.standard.set(lineSpacing, forKey: Keys.lineSpacing) }
    }
    /// FAB-333: horizontal reading margins, 0-3 (Wide/Normal/Narrow/Narrowest -- see
    /// `ArticleReaderView.readingHorizontalPadding`). Defaults to 0 (Wide), matching the
    /// 40pt this app always used before this control existed, so nobody who's never touched
    /// it sees any change.
    @Published var marginLevel: Int {
        didSet { UserDefaults.standard.set(marginLevel, forKey: Keys.marginLevel) }
    }

    /// FAB-333: the point size to actually render reading-view body text at, after
    /// OpenDyslexic's per-family adjustment (see `VersoTypography.Reading.renderedBodySize`).
    /// `fontSize` itself stays the raw stored/stepped value shared by both the reader's and
    /// Settings' steppers (FAB-311) -- this is a rendering-time derivation, not a second
    /// persisted value, so switching fonts never desyncs the steppers' displayed number.
    var effectiveFontSize: CGFloat {
        let step = VersoTypography.Reading.BodySize.nearest(to: fontSize)
        return VersoTypography.Reading(fontFamily: fontFamily).renderedBodySize(step).rawValue
    }

    init() {
        let savedFamily = UserDefaults.standard.string(forKey: Keys.fontFamily)
        fontFamily = savedFamily ?? "Georgia"

        let savedSize = UserDefaults.standard.double(forKey: Keys.fontSize)
        fontSize = savedSize > 0 ? CGFloat(savedSize) : 18

        lineSpacing = UserDefaults.standard.object(forKey: Keys.lineSpacing) != nil
            ? UserDefaults.standard.integer(forKey: Keys.lineSpacing)
            : 1

        marginLevel = UserDefaults.standard.object(forKey: Keys.marginLevel) != nil
            ? UserDefaults.standard.integer(forKey: Keys.marginLevel)
            : 0
    }

    private enum Keys {
        static let fontFamily = "readingFontFamily"
        static let fontSize = "readingFontSize"
        static let lineSpacing = "readingLineSpacing"
        static let marginLevel = "readingMarginLevel"
    }
}
