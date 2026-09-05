import SwiftUI

enum VersoTypography {
    /// UI text styles (list screens, settings, navigation). These are Dynamic Type
    /// text styles, not fixed point sizes -- FAB-309: a bare `.system(size:)` never
    /// responds to the user's system text size, while `.system(<TextStyle>)` does.
    /// Mapping follows `docs/accessibility-specs.md` §4.3.
    enum UI {
        static let screenTitle:  Font = .system(.largeTitle).weight(.bold)
        static let listTitle:    Font = .system(.headline)
        static let listSubtitle: Font = .system(.subheadline)
        static let button:       Font = .system(.headline)
        static let caption:      Font = .system(.caption)
        static let input:        Font = .system(.body)
    }

    struct Reading {
        let fontFamily: String

        var h1: Font { makeFont(size: 28, weight: .bold) }
        var h2: Font { makeFont(size: 24, weight: .semibold) }
        var h3: Font { makeFont(size: 20, weight: .semibold) }
        var h4: Font { makeFont(size: 18, weight: .semibold) }

        enum BodySize: CGFloat, CaseIterable {
            case xs = 14, sm = 16, md = 18, lg = 20, xl = 22, xxl = 26

            var lineHeightMultiplier: CGFloat {
                switch self {
                case .xs, .sm, .md, .lg: return 1.75
                case .xl:                return 1.6
                case .xxl:               return 1.5
                }
            }

            /// All 6 cases ordered smallest → largest. `CaseIterable`'s synthesized
            /// order already matches declaration order, but stepping logic below
            /// depends on that ordering, so make it explicit rather than assumed.
            private static var orderedCases: [BodySize] {
                allCases.sorted { $0.rawValue < $1.rawValue }
            }

            /// Snaps an arbitrary point size (e.g. a value stored before FAB-311,
            /// when the reader and Settings steppers could each drift onto a size
            /// that isn't one of the 6 designed steps) to the closest real case.
            static func nearest(to size: CGFloat) -> BodySize {
                orderedCases.min { abs($0.rawValue - size) < abs($1.rawValue - size) } ?? .md
            }

            /// Steps to the next/previous case, clamped at both ends of the scale.
            /// `delta` is typically ±1; anything larger just clamps immediately.
            func stepped(by delta: Int) -> BodySize {
                let cases = Self.orderedCases
                guard let index = cases.firstIndex(of: self) else { return self }
                let newIndex = min(max(index + delta, 0), cases.count - 1)
                return cases[newIndex]
            }
        }

        func body(_ size: BodySize) -> Font {
            makeFont(size: size.rawValue, weight: .regular)
        }

        private func makeFont(size: CGFloat, weight: Font.Weight) -> Font {
            fontFamily.isEmpty
                ? .system(size: size, weight: weight)
                : .custom(fontFamily, size: size).weight(weight)
        }
    }
}
