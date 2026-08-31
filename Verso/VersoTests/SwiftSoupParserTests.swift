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

    /// FAB-300: Guardian's "Explore more on these topics" / Share / "Reuse this content" block,
    /// reproduced from the real markup Fabio reported (2026-08-31) -- wrapped in
    /// `data-print-layout="hide"`, which `noiseSelector` now covers.
    func testGuardianTopicsListDoesNotLeakIntoBody() throws {
        let article = try SwiftSoupParser.parse(html: Self.guardianLikeHTML, url: sourceURL)
        let markdown = article.contentMarkdown

        for noise in ["Explore more on these topics", "Autobiography and memoir", "Bereavement", "Reuse this content"] {
            XCTAssertFalse(
                markdown.localizedCaseInsensitiveContains(noise),
                "Expected \"\(noise)\" to be stripped, but it survived: \(markdown)"
            )
        }
        XCTAssertTrue(markdown.contains("Ten years after my husband died in a surfing accident, I have learned things about grief that nobody warned me of."))
    }

    static let guardianLikeHTML = """
    <html><body><article>
        <p>Ten years after my husband died in a surfing accident, I have learned things about grief that nobody warned me of.</p>
        <div data-print-layout="hide" class="dcr-swayiu">
            <span class="dcr-1xhbmzr">Explore more on these topics</span>
            <div class="dcr-2c03t5"><ul class="dcr-p7nd18">
                <li class="dcr-r721ee"><a href="/books/autobiography-and-memoir" class="dcr-856iwi">Autobiography and memoir</a></li>
                <li class="dcr-r721ee"><a href="/lifeandstyle/bereavement" class="dcr-856iwi">Bereavement</a></li>
                <li class="dcr-r721ee"><a href="/tone/features" class="dcr-856iwi">features</a></li>
            </ul></div>
            <div class="dcr-313bdz">
                <button type="button" class="dcr-ncybeu">Share</button>
                <a href="https://syndication.theguardian.com/?url=x" title="Reuse this content" class="dcr-1c41onw">Reuse this content</a>
            </div>
        </div>
    </article></body></html>
    """
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

    /// FAB-300: `convert()` (the add-by-URL path, via Readability.js) had no DOM-based noise
    /// removal at all before this fix -- it relied entirely on Readability's own boilerplate
    /// heuristics, which don't catch a block like this sitting inside the article content
    /// container. Same fixture as `SwiftSoupParserTests.testGuardianTopicsListDoesNotLeakIntoBody`,
    /// exercised through the other import path.
    func testConvertStripsGuardianTopicsListViaDOMPrePass() {
        let result = HTMLToMarkdownConverter.convert(SwiftSoupParserTests.guardianLikeHTML, articleTitle: nil, baseURL: nil)

        for noise in ["Explore more on these topics", "Autobiography and memoir", "Bereavement", "Reuse this content"] {
            XCTAssertFalse(
                result.localizedCaseInsensitiveContains(noise),
                "Expected \"\(noise)\" to be stripped, but it survived: \(result)"
            )
        }
        XCTAssertTrue(result.contains("Ten years after my husband died in a surfing accident, I have learned things about grief that nobody warned me of."))
    }

    /// A malformed fragment must degrade to the pre-FAB-300 behavior (still strip tags via the
    /// existing regex pipeline) rather than lose all content when the DOM pre-pass can't parse it.
    func testConvertHandlesUnparseableFragmentGracefully() {
        let result = HTMLToMarkdownConverter.convert("<p>Unclosed paragraph with a stray < angle bracket.", articleTitle: nil, baseURL: nil)
        XCTAssertTrue(result.contains("Unclosed paragraph with a stray"))
    }
}

/// Regression coverage for FAB-295: the Share Extension's `SwiftSoupParser` path had no
/// `<img>`/`<picture>`/`<figure>` handling at all, so imported articles saved with no images —
/// `collectLines` fell through to `default:`, which recurses into an `<img>`'s (nonexistent,
/// since it's a void element) children and emits nothing.
final class SwiftSoupParserImageTests: XCTestCase {

    private let sourceURL = URL(string: "https://example.com/articles/quiet-mornings")!

    func testBareImgEmitsMarkdownImage() throws {
        let html = """
        <html><body><article>
            <p>Intro paragraph.</p>
            <img src="https://example.com/photo.jpg" alt="A quiet forest path" />
            <p>Closing paragraph.</p>
        </article></body></html>
        """
        let article = try SwiftSoupParser.parse(html: html, url: sourceURL)
        XCTAssertTrue(article.contentMarkdown.contains("![A quiet forest path](https://example.com/photo.jpg)"))
    }

    func testLazyLoadedImgResolvesFromDataSrcWhenSrcIsPlaceholder() throws {
        let html = """
        <html><body><article>
            <img src="data:image/gif;base64,R0lGOD" data-src="https://example.com/real-photo.jpg" alt="Real photo" />
        </article></body></html>
        """
        let article = try SwiftSoupParser.parse(html: html, url: sourceURL)
        XCTAssertTrue(article.contentMarkdown.contains("![Real photo](https://example.com/real-photo.jpg)"))
        XCTAssertFalse(article.contentMarkdown.contains("data:image"))
    }

    func testGuardianStylePictureResolvesFromSourceSrcset() throws {
        let html = """
        <html><body><article>
            <picture>
                <source srcset="https://example.com/hero-1200.jpg 1200w, https://example.com/hero-600.jpg 600w" type="image/jpeg">
                <img src="https://example.com/hero-fallback.jpg" alt="Hero fallback">
            </picture>
        </article></body></html>
        """
        let article = try SwiftSoupParser.parse(html: html, url: sourceURL)
        // bestImageURLAndAlt prefers a resolvable <img> within the fragment over <source>; either
        // real (non-placeholder) URL from this picture block is an acceptable, correct result.
        XCTAssertTrue(
            article.contentMarkdown.contains("hero-1200.jpg") || article.contentMarkdown.contains("hero-fallback.jpg"),
            "Expected an image line resolved from the <picture> block: \(article.contentMarkdown)"
        )
    }

    func testFigureWithImageAndCaptionUsesFigcaptionAsAlt() throws {
        let html = """
        <html><body><article>
            <figure>
                <img src="https://example.com/lake.jpg" alt="">
                <figcaption>Morning fog over the lake, October 2025</figcaption>
            </figure>
        </article></body></html>
        """
        let article = try SwiftSoupParser.parse(html: html, url: sourceURL)
        XCTAssertTrue(article.contentMarkdown.contains("![Morning fog over the lake, October 2025](https://example.com/lake.jpg)"))
    }

    func testFigureWrappingNonImageContentFallsBackToRecursion() throws {
        let html = """
        <html><body><article>
            <p>Some setup text.</p>
            <figure>
                <pre><code>let x = 1</code></pre>
                <figcaption>Listing 1</figcaption>
            </figure>
        </article></body></html>
        """
        let article = try SwiftSoupParser.parse(html: html, url: sourceURL)
        // No image was found in the figure -- its content (the code block) must still survive
        // via the fallback recursion, not vanish.
        XCTAssertTrue(article.contentMarkdown.contains("let x = 1"))
    }

    func testTrackingPixelWithSmallExplicitDimensionsIsSkipped() throws {
        let html = """
        <html><body><article>
            <p>Real paragraph.</p>
            <img src="https://example.com/pixel.gif" width="1" height="1" alt="">
        </article></body></html>
        """
        let article = try SwiftSoupParser.parse(html: html, url: sourceURL)
        XCTAssertFalse(article.contentMarkdown.contains("pixel.gif"))
    }

    func testImageWithoutDeclaredDimensionsIsNotSkipped() throws {
        let html = """
        <html><body><article>
            <img src="https://example.com/undeclared-size.jpg" alt="No dimensions given">
        </article></body></html>
        """
        let article = try SwiftSoupParser.parse(html: html, url: sourceURL)
        XCTAssertTrue(article.contentMarkdown.contains("undeclared-size.jpg"))
    }

    func testRelativeImageSrcResolvesAgainstArticleURL() throws {
        let html = """
        <html><body><article>
            <img src="/media/photo.jpg" alt="Relative path photo">
        </article></body></html>
        """
        let article = try SwiftSoupParser.parse(html: html, url: sourceURL)
        XCTAssertTrue(article.contentMarkdown.contains("![Relative path photo](https://example.com/media/photo.jpg)"))
    }
}
