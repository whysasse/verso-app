import Foundation

enum ShareDuplicateArticleTitle {
    /// Appends ` (Copy)` for a duplicate save, or ` 2` when the title already ends with ` (Copy)`.
    static func titleByAppendingCopySuffix(to title: String) -> String {
        let suffix = " (Copy)"
        if title.hasSuffix(suffix) {
            return title + " 2"
        }
        return title + suffix
    }
}
