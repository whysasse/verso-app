import SwiftUI

enum VersoTheme: String, CaseIterable, Identifiable {
    case paper = "Paper"
    case sepia = "Sepia"
    case night = "Night"
    case ink = "Ink"

    var id: String { rawValue }

    /// Localized, user-facing label. `rawValue` stays a stable, English, non-localized
    /// identifier -- used for `UserDefaults` persistence and analytics -- so this is the
    /// only thing views should put in `Text(...)`.
    var displayName: String {
        switch self {
        case .paper: return L10n.Theme.paper
        case .sepia: return L10n.Theme.sepia
        case .night: return L10n.Theme.night
        case .ink:   return L10n.Theme.ink
        }
    }

    var isDark: Bool {
        switch self {
        case .paper, .sepia: return false
        case .night, .ink: return true
        }
    }
}

struct ThemeColors {
    let background: Color
    let surface: Color
    let textPrimary: Color
    let textSecondary: Color
    let accent: Color
    let accentPressed: Color
    let accentSurface: Color
    let border: Color
    let placeholder: Color

    static let paper = ThemeColors(
        background: Color(hex: "F5F0E8"),
        surface: Color(hex: "EDE8DF"),
        textPrimary: Color(hex: "2C2924"),
        textSecondary: Color(hex: "6E675F"),
        accent: Color(hex: "766655"),
        accentPressed: Color(hex: "584D40"),
        accentSurface: Color(hex: "766655").opacity(0.15),
        border: Color(hex: "DDD8CE"),
        placeholder: Color(hex: "CEC8BC")
    )

    static let sepia = ThemeColors(
        background: Color(hex: "F2E8D5"),
        surface: Color(hex: "E8DEC7"),
        textPrimary: Color(hex: "2E2013"),
        textSecondary: Color(hex: "755E40"),
        accent: Color(hex: "825A37"),
        accentPressed: Color(hex: "614429"),
        accentSurface: Color(hex: "825A37").opacity(0.15),
        border: Color(hex: "D9CAAC"),
        placeholder: Color(hex: "C8BCA0")
    )

    static let night = ThemeColors(
        background: Color(hex: "1C1A16"),
        surface: Color(hex: "252320"),
        textPrimary: Color(hex: "E8E0D0"),
        textSecondary: Color(hex: "8F897F"),
        accent: Color(hex: "C4A97D"),
        accentPressed: Color(hex: "937F5E"),
        accentSurface: Color(hex: "C4A97D").opacity(0.15),
        border: Color(hex: "2E2B26"),
        placeholder: Color(hex: "302E2A")
    )

    static let ink = ThemeColors(
        background: Color(hex: "111418"),
        surface: Color(hex: "181C22"),
        textPrimary: Color(hex: "E4E6EB"),
        textSecondary: Color(hex: "7E8492"),
        accent: Color(hex: "7B9FD4"),
        accentPressed: Color(hex: "5C779F"),
        accentSurface: Color(hex: "7B9FD4").opacity(0.15),
        border: Color(hex: "1E2228"),
        placeholder: Color(hex: "202630")
    )

    static func colors(for theme: VersoTheme) -> ThemeColors {
        switch theme {
        case .paper: return .paper
        case .sepia: return .sepia
        case .night: return .night
        case .ink: return .ink
        }
    }
}

struct SemanticColors {
    let error: Color
    let warning: Color
    let success: Color

    static let paper = SemanticColors(
        error: Color(hex: "C0392B"),
        warning: Color(hex: "B45309"),
        success: Color(hex: "166534")
    )

    static let sepia = SemanticColors(
        error: Color(hex: "C0392B"),
        warning: Color(hex: "B45309"),
        success: Color(hex: "166534")
    )

    static let night = SemanticColors(
        error: Color(hex: "F87171"),
        warning: Color(hex: "FCD34D"),
        success: Color(hex: "4ADE80")
    )

    static let ink = SemanticColors(
        error: Color(hex: "FC8181"),
        warning: Color(hex: "F6E05E"),
        success: Color(hex: "68D391")
    )

    static func semanticColors(for theme: VersoTheme) -> SemanticColors {
        switch theme {
        case .paper: return .paper
        case .sepia: return .sepia
        case .night: return .night
        case .ink:   return .ink
        }
    }
}

enum ArticleStatus: String, CaseIterable {
    case unread = "Unread"
    case reading = "Reading"
    case read = "Read"
    case archived = "Archived"

    /// Localized label, e.g. `StatusBadge`'s `.archived` fallback below, and (as of FAB-292) the
    /// article list's Unread/Read/Archived section headers, which call `L10n.Filter.*` directly
    /// rather than through this property. `rawValue` stays a stable, English, non-localized
    /// identifier -- this is the only thing views should put in `Text(...)`.
    var filterLabel: String {
        switch self {
        case .unread:   return L10n.Filter.unread
        case .reading:  return L10n.Filter.reading
        case .read:     return L10n.Filter.read
        case .archived: return L10n.Filter.archived
        }
    }

    /// Localized status-badge label, e.g. for `StatusBadge`'s VoiceOver text. Singular
    /// agreement (describes one article) -- distinct from `filterLabel`'s plural chip text.
    /// `StatusBadge` only ever receives `.unread`/`.reading`/`.read` (callers map `.archived`
    /// to `.read` for display), so there's no `.archived` case in the doc's Status Badges
    /// section -- falls back to `filterLabel` if that ever changes.
    var statusLabel: String {
        switch self {
        case .unread:   return L10n.Status.unread
        case .reading:  return L10n.Status.reading
        case .read:     return L10n.Status.read
        case .archived: return filterLabel
        }
    }

    // SF Symbol name for the status icon (white, 16pt, inside 28×28 circular badge)
    var icon: String {
        switch self {
        case .unread:   return "circle"
        case .reading:  return "book.pages"
        case .read:     return "checkmark"
        case .archived: return "archivebox"
        }
    }
}

/// FAB-325: badge colors, resolved **theme-aware** (decision recorded in `docs/BACKLOG.md`'s
/// FAB-325 entry, 2026-09-05) -- unlike `VersoHighlightColor` below, which is a content-level
/// mark deliberately independent of theme. Badges are chrome sitting on a themed surface
/// (`ArticleCard` on `colors.surface`), the same category as `SemanticColors` above, which
/// already varies by theme for the same underlying reason: a fixed hue that clears contrast on
/// a light background can fail it on a near-black one.
///
/// Each hue keeps its family across all four themes (still reads as "blue/amber/green/gray" at
/// a glance) -- only lightness moves, and only as far as the contrast floor below requires.
/// Two values get an actual hue nudge, both addressing a clash confirmed on-screen 2026-09-03:
/// `reading` in Ink (amber read as foreign against Ink's cool cast) and `read` in Night (green
/// read as foreign against Night's warm cast). Computed (WCAG relative luminance), not
/// eyeballed, same as `docs/DESIGN_TOKENS.md`'s other ratios:
///
/// - `unread`, `read`, `archived` target **4.5:1** against white -- they're reused as the
///   Archive/Mark Read/Mark Unread **swipe-action tints** (`ArticleListView`), which sit behind
///   a system-rendered white *text* label, not just an icon. `reading` has no such reuse, so it
///   only needs the **3:1** non-text floor its badge icon actually requires.
/// - Archive/Unarchive's swipe tint deliberately does **not** reuse `colors.accent`, even though
///   the pre-fix hardcoded value (`#766655`, Paper's accent) suggests that was the original
///   intent: `accent` is bright in Night/Ink specifically so a *different* foreground color can
///   sit on it (FAB-305's white-on-accent fix) -- reusing it here would silently reintroduce
///   that exact contrast failure behind a label FAB-305 doesn't reach.
struct ArticleStatusColors {
    let unread: Color
    let reading: Color
    let read: Color
    let archived: Color

    func color(for status: ArticleStatus) -> Color {
        switch status {
        case .unread:   return unread
        case .reading:  return reading
        case .read:     return read
        case .archived: return archived
        }
    }

    static let paper = ArticleStatusColors(
        unread: Color(hex: "2A78CA"),
        reading: Color(hex: "C28A30"),
        read: Color(hex: "40845A"),
        archived: Color(hex: "76767C")
    )

    static let sepia = paper

    static let night = ArticleStatusColors(
        unread: Color(hex: "2A78CA"),
        reading: Color(hex: "C28A30"),
        read: Color(hex: "408361"),
        archived: Color(hex: "76767C")
    )

    static let ink = ArticleStatusColors(
        unread: Color(hex: "2A78CA"),
        reading: Color(hex: "A49629"),
        read: Color(hex: "40845A"),
        archived: Color(hex: "77767B")
    )

    static func colors(for theme: VersoTheme) -> ArticleStatusColors {
        switch theme {
        case .paper: return .paper
        case .sepia: return .sepia
        case .night: return .night
        case .ink:   return .ink
        }
    }
}

/// FAB-54: the reading-view text-highlight background wash. Deliberately **not** one of
/// `ThemeColors`' 9 per-theme roles and **not** theme-tinted like `accentSurface` -- a highlight
/// should read as a single consistent "highlighter" color the way it does in every reading app,
/// distinct from `accent` (already means links/interactive controls) and from the TTS
/// "currently narrating" indicator (`accent.opacity(0.15)`, `ArticleReaderView`'s
/// `highlightedParagraphIndex`).
///
/// `#F5C842` @ 30% opacity, computed (not eyeballed) against each theme's `textPrimary`-on-
/// `background` per `docs/DESIGN_TOKENS.md`'s WCAG rule: Paper 11.49:1, Sepia 11.88:1,
/// Night 6.20:1, Ink 7.03:1 -- all comfortably clear of the 4.5:1 minimum.
enum VersoHighlightColor {
    static let wash = Color(hex: "F5C842").opacity(0.30)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
