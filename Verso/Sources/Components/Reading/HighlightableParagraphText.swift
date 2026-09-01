import SwiftUI
import UIKit

/// FAB-54: selectable paragraph text, bridged to UIKit because neither piece this feature needs
/// exists in SwiftUI's `Text`: a selection-change hook to build a custom "Highlight" menu action,
/// or per-run background color on an `AttributedString` to actually paint the highlight once it
/// exists. Used only for `.paragraph` nodes (`MarkdownBodyView`'s `blockView`) — every other block
/// type keeps rendering as plain `Text`, unchanged.
struct HighlightableParagraphText: UIViewRepresentable {
    let inlines: [MarkdownNode.InlineNode]
    let rawText: String
    /// FAB-303 step 1: the paragraph's source line range, reported back through
    /// `onHighlightAction` so the caller can splice by exact line index instead of re-locating
    /// this paragraph in the full document by searching for its text.
    let lineRange: ClosedRange<Int>
    /// FAB-303 step 2: `MarkdownNode.BlockSource.contentOffset` -- added to an `InlineNode`'s own
    /// `sourceRange` to get that run's exact offset within `rawText`. Tagged onto each run as
    /// `.versoSourceOffset` in `buildAttributedString`.
    let contentOffset: Int
    let fontFamily: String
    let fontSize: CGFloat
    let lineSpacingValue: CGFloat
    let colors: ThemeColors
    var onHighlightAction: ((_ lineRange: ClosedRange<Int>, _ newRawText: String) -> Void)?

    func makeUIView(context: Context) -> HighlightableUITextView {
        let view = HighlightableUITextView()
        view.isEditable = false
        view.isSelectable = true
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.dataDetectorTypes = []
        return view
    }

    func updateUIView(_ uiView: HighlightableUITextView, context: Context) {
        uiView.rawText = rawText
        uiView.lineRange = lineRange
        uiView.onHighlightAction = onHighlightAction
        uiView.attributedText = Self.buildAttributedString(
            inlines: inlines,
            contentOffset: contentOffset,
            fontFamily: fontFamily,
            fontSize: fontSize,
            lineSpacingValue: lineSpacingValue,
            colors: colors
        )
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: HighlightableUITextView, context: Context) -> CGSize? {
        guard let width = proposal.width, width.isFinite else { return nil }
        let fitSize = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: fitSize.height)
    }

    // MARK: - Attributed string building

    /// UIKit counterpart to `MarkdownBodyView.textForInline` -- same visual mapping (font weight/
    /// style, link color+underline), but as `NSAttributedString` rather than SwiftUI's
    /// `AttributedString`, since only the UIKit type supports `.backgroundColor` per run. Also
    /// carries two custom attributes the text view's menu-building logic reads back: `.versoHighlightIndex`
    /// (source-order index of a `.highlight` run, for remove) and `.versoSourceOffset` (that run's
    /// exact raw-file offset, for add -- FAB-303 step 2).
    static func buildAttributedString(
        inlines: [MarkdownNode.InlineNode],
        contentOffset: Int,
        fontFamily: String,
        fontSize: CGFloat,
        lineSpacingValue: CGFloat,
        colors: ThemeColors
    ) -> NSAttributedString {
        let baseFont: UIFont = fontFamily.isEmpty
            ? .systemFont(ofSize: fontSize)
            : (UIFont(name: fontFamily, size: fontSize) ?? .systemFont(ofSize: fontSize))

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacingValue

        let result = NSMutableAttributedString()
        var highlightIndex = 0

        func append(_ text: String, sourceRange: Range<Int>, font: UIFont, color: UIColor, extra: [NSAttributedString.Key: Any] = [:]) {
            var attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle,
                .versoSourceOffset: contentOffset + sourceRange.lowerBound,
            ]
            attributes.merge(extra) { _, new in new }
            result.append(NSAttributedString(string: text, attributes: attributes))
        }

        let textColor = UIColor(colors.textPrimary)
        for inline in inlines {
            switch inline {
            case .text(let s, let range):
                append(s, sourceRange: range, font: baseFont, color: textColor)
            case .bold(let s, let range):
                append(s, sourceRange: range, font: baseFont.withSymbolicTraits(.traitBold), color: textColor)
            case .italic(let s, let range):
                append(s, sourceRange: range, font: baseFont.withSymbolicTraits(.traitItalic), color: textColor)
            case .boldItalic(let s, let range):
                append(s, sourceRange: range, font: baseFont.withSymbolicTraits([.traitBold, .traitItalic]), color: textColor)
            case .code(let s, let range):
                let codeFont = UIFont(name: "SFMono-Regular", size: max(12, fontSize - 2))
                    ?? .monospacedSystemFont(ofSize: max(12, fontSize - 2), weight: .regular)
                append(s, sourceRange: range, font: codeFont, color: UIColor(colors.accent))
            case .link(let text, let url, let range):
                var extra: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue]
                if let resolved = URL(string: url) {
                    extra[.link] = resolved
                }
                append(text, sourceRange: range, font: baseFont, color: UIColor(colors.accent), extra: extra)
            case .highlight(let s, let range):
                append(
                    s,
                    sourceRange: range,
                    font: baseFont,
                    color: textColor,
                    extra: [
                        .backgroundColor: UIColor(VersoHighlightColor.wash),
                        .versoHighlightIndex: highlightIndex,
                    ]
                )
                highlightIndex += 1
            }
        }
        return result
    }
}

extension NSAttributedString.Key {
    /// FAB-54: 0-based, left-to-right source-order index of a `.highlight` inline node within its
    /// paragraph -- matches the order `MarkdownParser.parseInlines` encounters `==...==` markers in,
    /// which is the same order `ArticleHighlighter.removeHighlight(at:in:)` expects. Lets
    /// `buildMenu(with:)` know *which* existing highlight a selection landed on without re-matching
    /// text.
    static let versoHighlightIndex = NSAttributedString.Key("versoHighlightIndex")

    /// FAB-303 step 2: the exact raw-file (UTF-16) offset where this run's rendered content starts
    /// -- `MarkdownNode.BlockSource.contentOffset + InlineNode.sourceRange.lowerBound`. Lets
    /// `buildMenu(with:)` convert a selection directly to a raw position instead of re-finding the
    /// rendered text in the raw source.
    static let versoSourceOffset = NSAttributedString.Key("versoSourceOffset")
}

/// UIKit counterpart to `UIFont.withSymbolicTraits` that falls back to the original font rather
/// than becoming `nil` when a trait can't be applied (e.g. a custom font family with no bold face).
private extension UIFont {
    func withSymbolicTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(fontDescriptor.symbolicTraits.union(traits)) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

/// `UITextView` subclass that adds a "Highlight"/"Remove Highlight" action to the system edit menu
/// (FAB-54) -- `isEditable = false, isSelectable = true` already gives native selection, Copy, and
/// (via the `.link` attribute in `buildAttributedString`) tappable links for free; this only adds
/// the one custom action on top.
final class HighlightableUITextView: UITextView {
    var rawText: String = ""
    /// FAB-303 step 1: this paragraph's source line range, reported alongside a change instead of
    /// its old raw text -- see `MarkdownBodyView.onHighlightAction`.
    var lineRange: ClosedRange<Int> = 0...0
    var onHighlightAction: ((_ lineRange: ClosedRange<Int>, _ newRawText: String) -> Void)?

    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        guard attributedText != nil, selectedRange.length > 0 else { return }

        let existingHighlightIndex = attributedText?.attribute(
            .versoHighlightIndex,
            at: selectedRange.location,
            effectiveRange: nil
        ) as? Int

        let action: UIAction
        if let index = existingHighlightIndex {
            action = UIAction(title: L10n.Reading.highlightRemove) { [weak self] _ in
                self?.applyHighlightChange { ArticleHighlighter.removeHighlight(at: index, in: $0) }
            }
        } else {
            action = UIAction(title: L10n.Reading.highlightAdd) { [weak self] _ in
                self?.applyAddHighlight()
            }
        }
        builder.insertSibling(UIMenu(title: "", options: .displayInline, children: [action]), afterMenu: .standardEdit)
    }

    /// The `.versoSourceOffset` tagged at `location`, plus the full run (`effectiveRange`) it
    /// applies to -- so callers can tell whether two locations fall inside the *same* run.
    private func sourceOffset(at location: Int) -> (offset: Int, runRange: NSRange)? {
        guard let attrText = attributedText else { return nil }
        var effectiveRange = NSRange()
        guard let offset = attrText.attribute(.versoSourceOffset, at: location, effectiveRange: &effectiveRange) as? Int else {
            return nil
        }
        return (offset, effectiveRange)
    }

    /// FAB-303 step 2: converts the current selection to an exact raw offset range and wraps it --
    /// only when both ends of the selection landed in the *same* tagged run (an ordinary sentence
    /// with no internal formatting is almost always one contiguous run, so this covers the common
    /// case). A selection crossing from one run into a differently-formatted one still declines,
    /// same as before this step -- wrapping across a run boundary would split a delimiter like
    /// `**`, which needs FAB-303 step 3's "snap outward" logic to handle safely, not this function.
    private func applyAddHighlight() {
        let start = selectedRange.location
        let end = selectedRange.location + selectedRange.length - 1 // last selected character
        guard let (startOffset, startRun) = sourceOffset(at: start),
              let (_, endRun) = sourceOffset(at: end),
              startRun == endRun else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        let rawStart = startOffset + (start - startRun.location)
        let rawEnd = startOffset + (selectedRange.location + selectedRange.length - startRun.location)
        applyHighlightChange { ArticleHighlighter.addHighlight(atRawOffsetRange: rawStart..<rawEnd, in: $0) }
    }

    /// Runs `transform` against the current `rawText`; on success, reports the change upstream and
    /// clears the selection (the edit menu doesn't auto-dismiss otherwise). On failure (`nil`), a
    /// single error haptic is the only feedback -- no blocking alert for what's meant to be a quiet,
    /// no-op decline.
    private func applyHighlightChange(_ transform: (String) -> String?) {
        guard let newRawText = transform(rawText) else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        selectedRange = NSRange(location: selectedRange.location, length: 0)
        onHighlightAction?(lineRange, newRawText)
    }
}
