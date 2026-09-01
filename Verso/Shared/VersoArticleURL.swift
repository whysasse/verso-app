import Foundation

/// Canonical URL comparison for duplicate article detection (Share extension + main app).
///
/// **Matching rules (FAB-296):** Compare after lowercasing scheme and host, stripping
/// `#fragment`, trimming a trailing `/` on the path (except `/` alone), stripping a leading
/// `www.` host label, normalizing `http` to `https`, and dropping known tracking query
/// parameters (the rest, sorted by name, are kept — an unrecognized query parameter still
/// counts as a different article). This is comparison-only: `canonicalKey` never rewrites the
/// stored `url:` frontmatter, which stays exactly as the user's source recorded it.
/// **Library scan scope:** the whole library tree recursively, `.md` files only (FAB-296).
enum VersoArticleURL {

    /// Query parameters stripped before comparison — share-link/analytics noise that doesn't
    /// change which article a URL points to.
    private static let trackingParameterNames: Set<String> = [
        "source", "sk", "gi", "ref", "ref_src", "fbclid", "gclid", "mc_cid", "mc_eid", "_branch_match_id"
    ]

    private static func isTrackingParameter(_ name: String) -> Bool {
        name.lowercased().hasPrefix("utm_") || trackingParameterNames.contains(name.lowercased())
    }

    /// Stable string for equality checks between two article source URLs.
    static func canonicalKey(for url: URL) -> String {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url.absoluteString.lowercased()
        }
        components.fragment = nil
        if let scheme = components.scheme, scheme.lowercased() == "http" {
            components.scheme = "https"
        } else if let scheme = components.scheme {
            components.scheme = scheme.lowercased()
        }
        if let host = components.host {
            let lowered = host.lowercased()
            components.host = lowered.hasPrefix("www.") ? String(lowered.dropFirst(4)) : lowered
        }
        if var path = components.path as String?, path.count > 1, path.hasSuffix("/") {
            path.removeLast()
            components.path = path
        }
        if let items = components.queryItems {
            let filtered = items
                .filter { !isTrackingParameter($0.name) }
                .sorted { $0.name < $1.name }
            components.queryItems = filtered.isEmpty ? nil : filtered
        }
        return components.url?.absoluteString ?? url.absoluteString.lowercased()
    }

    static func matches(_ a: URL, _ b: URL) -> Bool {
        canonicalKey(for: a) == canonicalKey(for: b)
    }
}
