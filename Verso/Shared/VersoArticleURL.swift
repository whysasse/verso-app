import Foundation

/// Canonical URL comparison for duplicate article detection (Share extension + main app).
///
/// **Matching rules (MVP):** Compare after lowercasing scheme and host, stripping `#fragment`,
/// trimming a trailing `/` on the path (except `/` alone), and using `URLComponents` for the path/query.
/// Redirects, `http` vs `https`, and tracking query parameters are not normalized beyond this.
/// **Library scan scope:** Library root `.md` files and `Archive/*.md` (same as cache rebuild).
enum VersoArticleURL {

    /// Stable string for equality checks between two article source URLs.
    static func canonicalKey(for url: URL) -> String {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url.absoluteString.lowercased()
        }
        components.fragment = nil
        if let scheme = components.scheme {
            components.scheme = scheme.lowercased()
        }
        if let host = components.host {
            components.host = host.lowercased()
        }
        if var path = components.path as String?, path.count > 1, path.hasSuffix("/") {
            path.removeLast()
            components.path = path
        }
        return components.url?.absoluteString ?? url.absoluteString.lowercased()
    }

    static func matches(_ a: URL, _ b: URL) -> Bool {
        canonicalKey(for: a) == canonicalKey(for: b)
    }
}
