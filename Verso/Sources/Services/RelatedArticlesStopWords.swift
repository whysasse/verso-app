import NaturalLanguage

/// Per-language stopword lists for `RelatedArticlesScoring` (FAB-298), replacing the previous
/// single 60-word English-only list -- Verso is localized to en/pt-BR/fr-CA (FAB-275), and an
/// English-only stoplist left thousands of topic-neutral Portuguese/French words unfiltered.
/// Hand-authored closed-class word lists (articles, prepositions, conjunctions, pronouns, common
/// auxiliary verb forms) -- not exhaustive, but the high-frequency words that would otherwise
/// dominate term-frequency counts without adding any topical signal.
enum RelatedArticlesStopWords {

    /// `language` should come from `NLLanguageRecognizer.dominantLanguage(for:)`. Any language
    /// without a dedicated list (including `nil`/undetected) falls back to English, matching this
    /// app's primary locale.
    static func set(for language: NLLanguage?) -> Set<String> {
        switch language {
        case .some(.portuguese): return portuguese
        case .some(.french): return french
        default: return english
        }
    }

    static let english: Set<String> = [
        "a", "an", "the", "and", "or", "but", "if", "then", "than", "so",
        "that", "this", "these", "those", "with", "from", "have", "has", "had",
        "been", "being", "be", "is", "are", "was", "were", "will", "would",
        "shall", "should", "can", "could", "may", "might", "must", "do", "does",
        "did", "they", "their", "theirs", "them", "when", "what", "which", "who",
        "whom", "whose", "why", "how", "also", "more", "most", "some", "any",
        "each", "every", "both", "few", "many", "much", "such", "no", "not",
        "nor", "only", "own", "same", "very", "just", "into", "onto", "over",
        "under", "about", "above", "below", "between", "through", "during",
        "before", "after", "while", "where", "there", "here", "make", "made",
        "makes", "work", "used", "still", "yet", "of", "in", "on", "at", "by",
        "for", "to", "up", "out", "as", "it", "its", "he", "she", "his", "her",
        "hers", "him", "you", "your", "yours", "we", "our", "ours", "us", "i",
        "me", "my", "mine", "am", "all", "one", "two", "get", "got", "go",
        "goes", "went", "like", "because", "against", "off", "down", "again",
        "once", "having", "does", "doing"
    ]

    static let portuguese: Set<String> = [
        "a", "o", "as", "os", "de", "do", "da", "dos", "das", "em", "no", "na",
        "nos", "nas", "um", "uma", "uns", "umas", "e", "ou", "mas", "que", "se",
        "por", "para", "com", "sem", "sobre", "entre", "até", "desde", "como",
        "quando", "onde", "porque", "então", "também", "muito", "muita",
        "muitos", "muitas", "mais", "menos", "ainda", "já", "não", "sim", "ele",
        "ela", "eles", "elas", "eu", "tu", "você", "vocês", "nós", "meu",
        "minha", "meus", "minhas", "seu", "sua", "seus", "suas", "nosso",
        "nossa", "nossos", "nossas", "isso", "isto", "aquilo", "este", "esta",
        "esse", "essa", "aquele", "aquela", "ser", "estar", "ter", "foi", "era",
        "são", "está", "estão", "têm", "há", "pelo", "pela", "pelos", "pelas",
        "ao", "aos", "à", "às", "num", "numa", "nesse", "nessa", "neste",
        "nesta", "disso", "deste", "desta", "outro", "outra", "outros",
        "outras", "cada", "todo", "toda", "todos", "todas", "algum", "alguma",
        "alguns", "algumas", "nenhum", "nenhuma", "qual", "quais", "quanto",
        "quanta", "quantos", "quantas", "isto", "lá", "aqui", "assim", "só",
        "apenas"
    ]

    static let french: Set<String> = [
        "le", "la", "les", "l", "un", "une", "des", "de", "du", "au", "aux",
        "et", "ou", "mais", "que", "qui", "quoi", "dont", "où", "comme",
        "quand", "si", "ne", "pas", "plus", "moins", "très", "aussi", "encore",
        "déjà", "ce", "cet", "cette", "ces", "il", "elle", "ils", "elles", "je",
        "tu", "nous", "vous", "on", "mon", "ma", "mes", "ton", "ta", "tes",
        "son", "sa", "ses", "notre", "nos", "votre", "vos", "leur", "leurs",
        "être", "avoir", "était", "étaient", "sont", "est", "a", "ont", "avait",
        "pour", "par", "avec", "sans", "sur", "sous", "dans", "entre", "vers",
        "chez", "depuis", "pendant", "ainsi", "alors", "donc", "car", "cela",
        "ceci", "celui", "celle", "ceux", "celles", "tout", "toute", "tous",
        "toutes", "chaque", "autre", "autres", "aucun", "aucune", "quel",
        "quelle", "quels", "quelles", "tel", "telle", "y", "en", "se", "s",
        "d", "n", "être", "faire", "fait", "faites"
    ]
}
