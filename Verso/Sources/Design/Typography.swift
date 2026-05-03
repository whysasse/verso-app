import SwiftUI

enum VersoTypography {
    enum UI {
        static let screenTitle:  Font = .system(size: 34, weight: .bold)
        static let listTitle:    Font = .system(size: 17, weight: .semibold)
        static let listSubtitle: Font = .system(size: 15, weight: .regular)
        static let button:       Font = .system(size: 17, weight: .semibold)
        static let caption:      Font = .system(size: 13, weight: .regular)
        static let input:        Font = .system(size: 17, weight: .regular)
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
