import Foundation

enum ArticleParsingError: Error, LocalizedError {
    case networkFailed(URL, underlyingError: Error)
    case readabilityFailed(URL)
    case swiftSoupFailed(URL)
    case allParsersFailed(URL)

    var errorDescription: String? {
        switch self {
        case .networkFailed(let url, let error):
            return "Network request failed for \(url.host ?? url.absoluteString): \(error.localizedDescription)"
        case .readabilityFailed(let url):
            return "Readability.js could not parse \(url.host ?? url.absoluteString)."
        case .swiftSoupFailed(let url):
            return "SwiftSoup could not parse \(url.host ?? url.absoluteString)."
        case .allParsersFailed(let url):
            return "Could not parse article at \(url.host ?? url.absoluteString)."
        }
    }

    /// The source URL, available on all cases for "Open in Safari" fallback.
    var sourceURL: URL {
        switch self {
        case .networkFailed(let url, _): return url
        case .readabilityFailed(let url): return url
        case .swiftSoupFailed(let url): return url
        case .allParsersFailed(let url): return url
        }
    }
}
