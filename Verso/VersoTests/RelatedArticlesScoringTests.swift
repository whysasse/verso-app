import XCTest
@testable import Verso

/// FAB-298: TF-IDF cosine similarity replacing unweighted Jaccard, which scored effectively every
/// article above its 0.04 threshold (no IDF weighting, set-based so term frequency was ignored,
/// and the union denominator punished length mismatch over topic mismatch). These tests exercise
/// `RelatedArticlesScoring` directly -- it's deliberately Core Data-free, so no managed object
/// context or temp files are needed.
final class RelatedArticlesScoringTests: XCTestCase {

    private func doc(_ key: String, title: String, body: String, tags: [String] = []) -> RelatedArticlesDocument {
        RelatedArticlesDocument(key: key, title: title, body: body, tags: tags)
    }

    // MARK: - Core ranking behavior

    func testTwoRelatedArticlesAmongUnrelatedOnesRankTogetherAndOnlyEachOther() throws {
        let current = doc(
            "sourdough-a", title: "The Art of Sourdough Bread",
            body: """
            Sourdough baking depends on a living starter, a levain cultivated from wild yeast and
            lactic bacteria. Hydration ratio shapes the crumb structure -- a wetter dough produces
            a more open crumb with larger irregular holes, while a stiffer dough yields a tighter
            crumb. Long fermentation develops the tangy flavor sourdough is known for, and proper
            gluten development during folding gives the loaf its structure and chewy crust.
            """
        )
        let related = doc(
            "sourdough-b", title: "Mastering Your Sourdough Starter",
            body: """
            A healthy starter is the foundation of good sourdough. Feed your levain with equal
            parts flour and water and watch for the rise that signals active wild yeast
            fermentation. Hydration affects how the starter behaves -- a higher hydration starter
            ferments faster and produces a looser crumb once baked into a loaf with a crisp crust.
            """
        )
        let unrelated: [RelatedArticlesDocument] = [
            doc("space", title: "Saturn's Rings Explained", body: "Saturn's rings are made of countless ice particles and rocky debris orbiting the planet, visible through even a small telescope. NASA's Cassini probe studied the rings' composition for over a decade before its final plunge into Saturn's atmosphere."),
            doc("marathon", title: "How Marathon Runners Train", body: "Marathon training builds mileage gradually over months, alternating tempo runs with easy recovery days. A taper in the final weeks lets the runner's legs recover before race day, when pacing discipline over 26.2 miles matters more than raw speed."),
            doc("jazz", title: "The History of Jazz Improvisation", body: "Jazz improvisation grew out of blues and ragtime traditions, with saxophonists and trumpeters trading melodic phrases over swinging rhythm sections. Bebop pushed harmonic complexity further, favoring fast chord changes over the simpler forms of earlier jazz."),
            doc("tax", title: "Understanding Capital Gains Tax", body: "Capital gains tax applies when an investor sells an asset for more than its purchase price. Holding periods determine whether the gain is taxed at short-term or long-term rates, with long-term holdings generally receiving preferential tax treatment."),
            doc("volcano", title: "Why Volcanoes Erupt", body: "Volcanic eruptions occur when magma pressure beneath the crust exceeds the strength of overlying rock. Dissolved gases expand rapidly as magma rises, and the eruption style depends heavily on the magma's viscosity and gas content."),
            doc("chess", title: "Opening Theory in Chess", body: "Chess opening theory catalogs the strongest early moves, from the Sicilian Defense to the Queen's Gambit. Grandmasters memorize deep opening lines to reach a favorable middlegame position with a spatial or developmental advantage."),
            doc("coral", title: "Coral Reef Bleaching Explained", body: "Coral bleaching happens when rising ocean temperatures stress the coral, causing it to expel the symbiotic algae living in its tissue. Without the algae's photosynthesis, the coral loses its color and its main energy source, and can starve."),
            doc("violin", title: "Choosing Your First Violin", body: "A beginner violin should have a properly fitted bridge, well-seasoned wood, and strings that hold their tuning. Bow hair tension and rosin quality affect tone production far more than most new players expect.")
        ]

        let scored = RelatedArticlesScoring.score(current: current, candidates: [related] + unrelated)

        XCTAssertEqual(scored.count, 1, "only the genuinely related sourdough article should clear the threshold")
        XCTAssertEqual(scored.first?.key, "sourdough-b")
    }

    func testNoTopicalNeighborReturnsEmpty() throws {
        let current = doc("space", title: "Saturn's Rings Explained", body: "Saturn's rings are made of countless ice particles and rocky debris orbiting the planet, visible through even a small telescope.")
        let unrelated: [RelatedArticlesDocument] = [
            doc("marathon", title: "How Marathon Runners Train", body: "Marathon training builds mileage gradually over months, alternating tempo runs with easy recovery days."),
            doc("jazz", title: "The History of Jazz Improvisation", body: "Jazz improvisation grew out of blues and ragtime traditions, with saxophonists trading melodic phrases."),
            doc("tax", title: "Understanding Capital Gains Tax", body: "Capital gains tax applies when an investor sells an asset for more than its purchase price.")
        ]

        XCTAssertTrue(RelatedArticlesScoring.score(current: current, candidates: unrelated).isEmpty)
    }

    // MARK: - Tag overlap boost (acceptance criterion)

    func testSharedTagOutranksSharedVocabularyAlone() throws {
        let current = doc(
            "current", title: "A Guide to Home Espresso",
            body: "Pulling a good espresso shot depends on grind size, dose, and extraction time. A finer grind slows the flow and increases extraction, while a coarser grind speeds it up.",
            tags: ["coffee"]
        )
        // Identical body content -- same raw vocabulary overlap with `current` -- but only one
        // shares the "coffee" tag. If the tag boost works, the tagged one ranks strictly higher
        // despite having the same cosine similarity.
        let sameBody = "Pulling a good espresso shot depends on grind size, dose, and extraction time. Dialing in the grind takes practice and patience."
        let tagged = doc("tagged", title: "Dialing In Your Grinder", body: sameBody, tags: ["coffee"])
        let untagged = doc("untagged", title: "Dialing In Your Grinder", body: sameBody, tags: [])

        let scored = RelatedArticlesScoring.score(current: current, candidates: [tagged, untagged])
        let taggedScore = try XCTUnwrap(scored.first { $0.key == "tagged" }?.score)
        let untaggedScore = try XCTUnwrap(scored.first { $0.key == "untagged" }?.score)

        XCTAssertGreaterThan(taggedScore, untaggedScore)
        XCTAssertEqual(taggedScore - untaggedScore, 0.15, accuracy: 0.001, "tag boost weight is 0.15 for a single fully-shared tag")
    }

    // MARK: - Regression: the old Jaccard failure mode (everything clears threshold)

    func testGenericOverlappingVocabularyDoesNotClearThreshold() throws {
        // Every document below shares the same generic, topic-neutral filler sentence -- the
        // exact shape of the old bug: high raw word overlap with no actual topical relationship.
        // Crucially the documents are NOT identical: each also has its own unrelated topic, so
        // this isn't trivially cosine=1 (two identical documents are always "related" regardless
        // of IDF -- that would prove nothing). With the filler suppressed by IDF (it's in every
        // document, so its df is maximal) and each document's own unique vocabulary inflating its
        // magnitude without contributing to the dot product, cosine should stay well under
        // threshold -- verifying the specific failure mode reported in FAB-298 can't return.
        let filler = "People often think about important things, and everyone believes different changes happen now; understanding this takes real time."
        let topics: [(title: String, body: String)] = [
            ("The Secret Life of Plants", "Photosynthesis converts sunlight into chemical energy using chlorophyll inside plant leaves, releasing oxygen as a byproduct of the light-dependent reactions."),
            ("Why Volcanoes Erupt", "Volcanic eruptions release magma, ash, and sulfur dioxide gas when pressure inside the crust exceeds the surrounding rock's strength."),
            ("How Marathon Runners Train", "Marathon runners taper their mileage in the final weeks before race day to let their legs recover from months of training."),
            ("The History of Jazz Improvisation", "Jazz saxophonists improvise over chord changes, drawing on blues scales and rhythmic phrasing developed throughout the twentieth century."),
            ("Understanding Capital Gains Tax", "Capital gains tax rates depend on how long an investor holds an asset before selling it for a profit."),
            ("Coral Reef Bleaching Explained", "Coral reefs bleach when rising ocean temperatures cause the coral to expel its symbiotic algae, draining its color and energy source."),
            ("Opening Theory in Chess", "Chess grandmasters memorize opening theory to reach a favorable middlegame with a spatial or developmental advantage."),
            ("Choosing Your First Violin", "A violin bow needs properly tensioned horsehair and quality rosin to produce a clean, resonant tone."),
            ("Saturn's Rings Explained", "Saturn's rings consist of countless ice particles and rocky debris orbiting the planet in a thin, flat disk."),
            ("The Art of Sourdough Bread", "Sourdough bread relies on a living starter cultured from wild yeast and lactic acid bacteria for its rise and flavor.")
        ]
        let documents = topics.enumerated().map { index, topic in
            doc("generic-\(index)", title: topic.title, body: "\(filler) \(topic.body)")
        }
        let current = documents[0]
        let candidates = Array(documents.dropFirst())

        XCTAssertTrue(RelatedArticlesScoring.score(current: current, candidates: candidates).isEmpty)
    }

    // MARK: - Language-aware tokenization

    func testPortugueseArticleDoesNotRelateToUnrelatedEnglishArticles() throws {
        let current = doc(
            "bolo", title: "Receita de Bolo de Chocolate",
            body: "Este bolo de chocolate fica úmido e macio, com uma cobertura de ganache cremosa. Misture o cacau em pó com a farinha antes de adicionar aos ovos batidos com açúcar."
        )
        let unrelated: [RelatedArticlesDocument] = [
            doc("marathon", title: "How Marathon Runners Train", body: "Marathon training builds mileage gradually over months, alternating tempo runs with easy recovery days."),
            doc("jazz", title: "The History of Jazz Improvisation", body: "Jazz improvisation grew out of blues and ragtime traditions, with saxophonists trading melodic phrases.")
        ]

        XCTAssertTrue(RelatedArticlesScoring.score(current: current, candidates: unrelated).isEmpty)
    }

    // MARK: - Performance sanity check

    func testScoringFiveHundredSyntheticDocumentsIsFast() throws {
        // Synthetic vocabulary -- not real prose -- purely to exercise the scoring path's
        // performance at roughly the library size named in the ticket's acceptance criteria.
        let vocabulary = (0..<300).map { "term\($0)" }
        func syntheticDoc(_ n: Int) -> RelatedArticlesDocument {
            var generator = SystemRandomNumberGenerator()
            let words = (0..<200).map { _ in vocabulary.randomElement(using: &generator)! }
            return doc("doc-\(n)", title: "Synthetic Document \(n)", body: words.joined(separator: " "))
        }
        let current = syntheticDoc(0)
        let candidates = (1...500).map(syntheticDoc)

        let start = Date()
        _ = RelatedArticlesScoring.score(current: current, candidates: candidates)
        let elapsed = Date().timeIntervalSince(start)

        XCTAssertLessThan(elapsed, 6.0, "scoring ~500 documents should be comfortably fast off the main thread (measured ~2.1s on dev hardware; generous margin against CI variance)")
    }
}
