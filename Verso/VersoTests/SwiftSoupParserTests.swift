import XCTest
@testable import Verso

/// Regression coverage for FAB-294: the Share Extension's `SwiftSoupParser` path used to
/// leak Medium-style page chrome (tag lists, toolbar labels, "N min read") into the saved
/// article body because `collectLines` emitted every bare text node it walked past, and
/// the extension never ran the shared `HTMLToMarkdownConverter.sanitizeMarkdownBody` pass
/// the in-app Readability path already benefits from.
final class SwiftSoupParserTests: XCTestCase {

    private let sourceURL = URL(string: "https://medium.com/example/the-hidden-cost-of-always-being-busy")!

    /// A synthetic fixture reproducing the shape of Fabio's 2026-08-30 report: a tag
    /// list, a "N min read ·" byline, toolbar buttons with nested spans (Listen, Share,
    /// a lone "–" and "1"), and a lightbox caption — around real headings, paragraphs,
    /// and a blockquote that must survive untouched.
    private let mediumLikeHTML = """
    <html>
    <head>
        <title>The Hidden Cost of Always Being Busy</title>
        <meta property="og:title" content="The Hidden Cost of Always Being Busy" />
        <meta name="author" content="Jane Doe" />
    </head>
    <body>
        <header><nav>Home Library Stories Stats</nav></header>
        <article>
            <div class="tags">
                <span>Member-only story</span>
                <span>Featured</span>
                <a href="/tag/self-improvement">Self Improvement</a>
                <a href="/tag/psychology">Psychology</a>
                <a href="/tag/self-love">Self Love</a>
                <a href="/tag/mental-health">Mental Health</a>
                <a href="/tag/books">Books</a>
            </div>
            <h1>The Hidden Cost of Always Being Busy</h1>
            <div class="byline">
                <span>Jane Doe</span>
                <span>4 min read</span>
                <span>·</span>
            </div>
            <div class="toolbar" role="toolbar">
                <button aria-label="listen"><span>Listen</span></button>
                <button aria-label="share"><span>Share</span></button>
                <div>–</div>
                <div>1</div>
            </div>
            <p>We live in a culture that treats busyness as a badge of honor.</p>
            <p>But constant motion has a hidden cost: it erodes our capacity for reflection.</p>
            <blockquote>Rest is not idleness, and to lie sometimes on the grass is by no means a waste of time.</blockquote>
            <figure>
                <img src="https://example.com/hero.jpg" alt="A quiet forest path" />
                <figcaption>Press enter or click to view image in full size</figcaption>
            </figure>
            <h2>Why we resist rest</h2>
            <p>Our attention economy rewards constant activity — even when it costs us clarity.</p>
        </article>
    </body>
    </html>
    """

    private static let noiseStrings = [
        "Member-only story",
        "Featured",
        "Self Improvement",
        "Psychology",
        "Self Love",
        "Mental Health",
        "Books",
        "4 min read",
        "Listen",
        "Share",
        "Press enter or click to view image in full size",
    ]

    func testNoiseStringsAreAbsentFromSavedBody() throws {
        let article = try SwiftSoupParser.parse(html: mediumLikeHTML, url: sourceURL)

        for noise in Self.noiseStrings {
            XCTAssertFalse(
                article.contentMarkdown.localizedCaseInsensitiveContains(noise),
                "Expected \"\(noise)\" to be stripped, but it survived: \(article.contentMarkdown)"
            )
        }
    }

    func testLonePunctuationAndDigitLinesAreAbsent() throws {
        let article = try SwiftSoupParser.parse(html: mediumLikeHTML, url: sourceURL)
        let lines = article.contentMarkdown
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        XCTAssertFalse(lines.contains("–"), "A lone toolbar dash leaked into the body")
        XCTAssertFalse(lines.contains("1"), "A lone toolbar digit leaked into the body")
    }

    func testRealBodyContentSurvives() throws {
        let article = try SwiftSoupParser.parse(html: mediumLikeHTML, url: sourceURL)
        let markdown = article.contentMarkdown

        XCTAssertTrue(markdown.contains("We live in a culture that treats busyness as a badge of honor."))
        XCTAssertTrue(markdown.contains("But constant motion has a hidden cost: it erodes our capacity for reflection."))
        XCTAssertTrue(markdown.contains("Rest is not idleness, and to lie sometimes on the grass is by no means a waste of time."))
        XCTAssertTrue(markdown.contains("## Why we resist rest"))
        // The author's own em-dash must survive — only structural noise is stripped.
        XCTAssertTrue(markdown.contains("Our attention economy rewards constant activity — even when it costs us clarity."))
    }

    func testTitleEchoHeadingIsRemoved() throws {
        let article = try SwiftSoupParser.parse(html: mediumLikeHTML, url: sourceURL)
        // The <h1> duplicating the title (Medium repeats it inside <article>) should be
        // stripped by sanitizeMarkdownBody's title-echo pass, not just left as a literal
        // duplicate of the article's own title field.
        XCTAssertFalse(article.contentMarkdown.contains("# The Hidden Cost of Always Being Busy"))
    }

    /// A plain paragraph that merely contains a pipe/dash character must not be
    /// mistaken for chrome — only known noise patterns and known UI labels are dropped.
    func testOrdinaryParagraphWithPunctuationSurvives() throws {
        let html = """
        <html><body><article>
            <p>The meeting ran from 2 – 3pm and covered three topics.</p>
        </article></body></html>
        """
        let article = try SwiftSoupParser.parse(html: html, url: sourceURL)
        XCTAssertTrue(article.contentMarkdown.contains("The meeting ran from 2 – 3pm and covered three topics."))
    }

    /// Table cells have no GFM rendering yet (FAB-293), but must not silently vanish now
    /// that bare text nodes are no longer emitted by default.
    func testTableCellTextIsPreservedAsLooseLines() throws {
        let html = """
        <html><body><article>
            <p>Results by quarter:</p>
            <table>
                <tr><th>Quarter</th><th>Revenue</th></tr>
                <tr><td>Q1</td><td>$4.2M</td></tr>
            </table>
        </article></body></html>
        """
        let article = try SwiftSoupParser.parse(html: html, url: sourceURL)
        let markdown = article.contentMarkdown
        XCTAssertTrue(markdown.contains("Quarter"))
        XCTAssertTrue(markdown.contains("Revenue"))
        XCTAssertTrue(markdown.contains("Q1"))
        XCTAssertTrue(markdown.contains("$4.2M"))
    }
}

/// Focused coverage for the noise-line rules added to `HTMLToMarkdownConverter` (FAB-294):
/// numeric-only lines, punctuation-only lines, and "N min read" labels, on top of the
/// existing fingerprint set.
final class HTMLToMarkdownConverterNoiseTests: XCTestCase {

    func testDropsStandaloneMinReadLabel() {
        let markdown = "Intro paragraph.\n\n4 min read ·\n\nBody paragraph."
        let result = HTMLToMarkdownConverter.sanitizeMarkdownBody(markdown, articleTitle: nil)
        XCTAssertFalse(result.contains("min read"))
        XCTAssertTrue(result.contains("Intro paragraph."))
        XCTAssertTrue(result.contains("Body paragraph."))
    }

    func testDropsStandaloneDigitOnlyBlock() {
        let markdown = "Intro paragraph.\n\n1\n\nBody paragraph."
        let result = HTMLToMarkdownConverter.sanitizeMarkdownBody(markdown, articleTitle: nil)
        XCTAssertFalse(result.components(separatedBy: "\n\n").contains("1"))
        XCTAssertTrue(result.contains("Intro paragraph."))
        XCTAssertTrue(result.contains("Body paragraph."))
    }

    func testDropsStandalonePunctuationOnlyBlock() {
        let markdown = "Intro paragraph.\n\n–\n\nBody paragraph."
        let result = HTMLToMarkdownConverter.sanitizeMarkdownBody(markdown, articleTitle: nil)
        XCTAssertFalse(result.components(separatedBy: "\n\n").contains("–"))
        XCTAssertTrue(result.contains("Intro paragraph."))
        XCTAssertTrue(result.contains("Body paragraph."))
    }

    func testKnownUILabelsAreDropped() {
        let markdown = "Listen\n\nShare\n\nMember-only story\n\nReal paragraph about the topic."
        let result = HTMLToMarkdownConverter.sanitizeMarkdownBody(markdown, articleTitle: nil)
        XCTAssertFalse(result.contains("Listen"))
        XCTAssertFalse(result.contains("Share"))
        XCTAssertFalse(result.contains("Member-only story"))
        XCTAssertTrue(result.contains("Real paragraph about the topic."))
    }

    func testParagraphContainingEmDashIsNotTreatedAsNoise() {
        let markdown = "The results were surprising — nobody expected this outcome."
        let result = HTMLToMarkdownConverter.sanitizeMarkdownBody(markdown, articleTitle: nil)
        XCTAssertTrue(result.contains("The results were surprising — nobody expected this outcome."))
    }
}
