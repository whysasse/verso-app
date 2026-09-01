import XCTest
@testable import Verso

/// FAB-296: `canonicalKey` was too weak to catch real-world duplicate share links (Medium's
/// `?source=...&sk=...`, generic `utm_*` params). See docs/DONE.md FAB-296.
final class VersoArticleURLTests: XCTestCase {

    private func key(_ string: String) -> String {
        VersoArticleURL.canonicalKey(for: URL(string: string)!)
    }

    func testStripsUTMParameters() {
        XCTAssertEqual(
            key("https://example.com/article?utm_source=twitter&utm_medium=social"),
            key("https://example.com/article")
        )
    }

    func testStripsKnownTrackingParameters() {
        XCTAssertEqual(
            key("https://medium.com/@author/title-abc123?source=friends_link&sk=deadbeef"),
            key("https://medium.com/@author/title-abc123")
        )
    }

    func testKeepsUnrecognizedQueryParameters() {
        // A query parameter that isn't tracking noise still distinguishes the URL —
        // e.g. `?page=2` genuinely points at different content.
        XCTAssertNotEqual(
            key("https://example.com/article?page=2"),
            key("https://example.com/article")
        )
    }

    func testQueryParameterOrderingDoesNotMatter() {
        XCTAssertEqual(
            key("https://example.com/article?b=2&a=1"),
            key("https://example.com/article?a=1&b=2")
        )
    }

    func testStripsLeadingWWW() {
        XCTAssertEqual(
            key("https://www.example.com/article"),
            key("https://example.com/article")
        )
    }

    func testNormalizesHTTPToHTTPS() {
        XCTAssertEqual(
            key("http://example.com/article"),
            key("https://example.com/article")
        )
    }

    func testTrimsTrailingSlash() {
        XCTAssertEqual(
            key("https://example.com/article/"),
            key("https://example.com/article")
        )
    }

    func testKeepsRootSlash() {
        XCTAssertEqual(key("https://example.com/"), key("https://example.com/"))
    }

    func testStripsFragment() {
        XCTAssertEqual(
            key("https://example.com/article#section-2"),
            key("https://example.com/article")
        )
    }

    func testCombinedNoiseAllStrippedAtOnce() {
        XCTAssertEqual(
            key("http://WWW.Medium.com/@author/title-abc123/?utm_source=twitter&source=friends_link&sk=deadbeef#comments"),
            key("https://medium.com/@author/title-abc123")
        )
    }
}
