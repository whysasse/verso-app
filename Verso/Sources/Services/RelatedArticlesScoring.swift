import Foundation
import NaturalLanguage

/// A plain-value document ready for scoring -- deliberately Core Data-free (no `Article`
/// dependency) so `RelatedArticlesScoring` is pure, `Sendable`-safe across actor boundaries, and
/// directly unit-testable without a managed object context. `key` is the article's `filePath`,
/// used only to map a score back to its `Article` in `RelatedArticlesService`.
struct RelatedArticlesDocument {
    let key: String
    let title: String
    let body: String
    let tags: [String]
}

/// TF-IDF cosine similarity, replacing the old unweighted-Jaccard scoring (FAB-298). Rare shared
/// terms dominate (IDF), term frequency counts (unlike a set), and cosine normalization cancels
/// out document-length mismatch -- the three properties Jaccard was missing that made its "top 3"
/// close to arbitrary. Entirely pure/synchronous so callers control which thread this runs on;
/// `RelatedArticlesService` is the only caller and always runs it off the main actor.
enum RelatedArticlesScoring {

    /// Calibrated against the repo's 14 `SampleArticles` (the app's own seed content, and a
    /// reasonable proxy for the short-essay/long-read material Verso is actually used to read):
    /// the shipped 0.18 guess (borrowed from generic TF-IDF cosine literature, which skews toward
    /// longer/more technical documents) turned out too high -- only 1 of 91 real pairs cleared it,
    /// so Related Articles was effectively always empty. The measured score distribution over
    /// those 91 pairs tops out at 0.24 (one genuinely on-topic pair, sharing a tag too), with a
    /// second tier of plausible-but-looser thematic pairs in the 0.10-0.15 band, and a long tail
    /// below 0.08 of clearly unrelated pairs. 0.10 keeps that second tier -- so an article with a
    /// real thematic neighbor actually surfaces 1-3 results -- while still excluding the bulk of
    /// the unrelated tail. Still a measurement from one small sample library, not Fabio's real one
    /// -- `#if DEBUG` `RelatedArticlesDebugView` remains the way to check and adjust further.
    static let threshold: Double = 0.10
    static let maxResults = 3

    /// Title terms count for this many "copies" of a body term when building a document's term
    /// frequency map -- title words are a stronger relatedness signal than body words appearing
    /// once in a few thousand words of prose. Matches the ticket's "~2-3x" guidance.
    private static let titleWeight = 3

    /// How much a shared user tag can add to the cosine score, scaled by the fraction of the
    /// smaller tag set that overlaps. Tags are explicit user intent -- the strongest signal
    /// available -- so this is deliberately additive on top of, not blended into, the TF-IDF score.
    private static let tagBoostWeight = 0.15

    /// Scores every candidate against `current`, returning up to `maxResults` above `threshold`,
    /// sorted descending. Pure and synchronous -- no Core Data, no file I/O, no actor hops.
    static func score(current: RelatedArticlesDocument, candidates: [RelatedArticlesDocument]) -> [(key: String, score: Double)] {
        rawScores(current: current, candidates: candidates)
            .filter { $0.score >= threshold }
            .sorted { $0.score > $1.score }
            .prefix(maxResults)
            .map { $0 }
    }

    /// Every candidate's score against `current`, unfiltered by `threshold` and unsorted. `score`
    /// above is the normal entry point; this exists for `RelatedArticlesDebugView` (FAB-298
    /// calibration), which needs the full distribution -- including everything below the cutoff --
    /// to show where a threshold would actually land.
    static func rawScores(current: RelatedArticlesDocument, candidates: [RelatedArticlesDocument]) -> [(key: String, score: Double)] {
        guard !candidates.isEmpty else { return [] }

        let allDocs = [current] + candidates
        let termFrequencies = allDocs.map { termFrequency(for: $0) }
        let idf = inverseDocumentFrequency(termFrequencies: termFrequencies, documentCount: allDocs.count)

        let currentVector = tfidfVector(termFrequency: termFrequencies[0], idf: idf)
        guard !currentVector.isEmpty else { return [] }
        let currentMagnitude = magnitude(of: currentVector)
        guard currentMagnitude > 0 else { return [] }

        var scored: [(key: String, score: Double)] = []
        for (index, candidate) in candidates.enumerated() {
            let candidateVector = tfidfVector(termFrequency: termFrequencies[index + 1], idf: idf)
            let candidateMagnitude = magnitude(of: candidateVector)
            guard candidateMagnitude > 0 else { continue }

            let cosine = dotProduct(currentVector, candidateVector) / (currentMagnitude * candidateMagnitude)
            let boost = tagOverlapBoost(current.tags, candidate.tags)
            let final = min(1, cosine + boost)
            scored.append((key: candidate.key, score: final))
        }
        return scored
    }

    // MARK: - Term frequency

    /// Raw term counts for one document, with title terms weighted `titleWeight`x by simply
    /// counting them that many times -- the simplest correct way to weight without a second
    /// bookkeeping pass.
    private static func termFrequency(for document: RelatedArticlesDocument) -> [String: Double] {
        let titleTokens = tokenize(document.title)
        let bodyTokens = tokenize(document.body)

        var counts: [String: Double] = [:]
        for token in bodyTokens {
            counts[token, default: 0] += 1
        }
        for token in titleTokens {
            counts[token, default: 0] += Double(titleWeight)
        }
        return counts
    }

    // MARK: - TF-IDF / cosine

    private static func inverseDocumentFrequency(termFrequencies: [[String: Double]], documentCount: Int) -> [String: Double] {
        var documentFrequency: [String: Int] = [:]
        for tf in termFrequencies {
            for term in tf.keys {
                documentFrequency[term, default: 0] += 1
            }
        }
        // Smoothed IDF (add-one on both N and df) so a term appearing in every document still
        // gets a small positive weight instead of log(1) = 0 collapsing it out entirely.
        let n = Double(documentCount)
        return documentFrequency.mapValues { df in
            log((n + 1) / (Double(df) + 1)) + 1
        }
    }

    private static func tfidfVector(termFrequency: [String: Double], idf: [String: Double]) -> [String: Double] {
        var vector: [String: Double] = [:]
        for (term, tf) in termFrequency {
            guard let weight = idf[term] else { continue }
            vector[term] = tf * weight
        }
        return vector
    }

    private static func dotProduct(_ a: [String: Double], _ b: [String: Double]) -> Double {
        // Iterate the smaller map -- dot product only needs keys present in both.
        let (smaller, larger) = a.count <= b.count ? (a, b) : (b, a)
        var sum = 0.0
        for (term, value) in smaller {
            if let other = larger[term] {
                sum += value * other
            }
        }
        return sum
    }

    private static func magnitude(of vector: [String: Double]) -> Double {
        sqrt(vector.values.reduce(0) { $0 + $1 * $1 })
    }

    private static func tagOverlapBoost(_ a: [String], _ b: [String]) -> Double {
        let setA = Set(a)
        let setB = Set(b)
        let denominator = max(setA.count, setB.count)
        guard denominator > 0 else { return 0 }
        let shared = setA.intersection(setB).count
        return tagBoostWeight * (Double(shared) / Double(denominator))
    }

    // MARK: - Tokenization

    /// Lemma-based tokens for `text`, filtered against a language-appropriate stopword set.
    /// Detects the document's dominant language (mirrors the pattern `TTSService` already uses
    /// for voice selection) and falls back to English when detection is inconclusive.
    static func tokenize(_ text: String) -> [String] {
        guard !text.isEmpty else { return [] }

        let language = NLLanguageRecognizer.dominantLanguage(for: text) ?? .english
        let stopWords = RelatedArticlesStopWords.set(for: language)

        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = text
        tagger.setLanguage(language, range: text.startIndex..<text.endIndex)

        var tokens: [String] = []
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .omitOther]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lemma, options: options) { tag, range in
            let raw = tag?.rawValue.isEmpty == false ? tag!.rawValue : String(text[range])
            let word = raw.lowercased()
            if word.count >= 2, !stopWords.contains(word), word.rangeOfCharacter(from: .letters) != nil {
                tokens.append(word)
            }
            return true
        }
        return tokens
    }
}
