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
    /// `source.contentRange` to get that run's exact offset within `rawText`. Tagged onto each run
    /// as `.versoSourceOffset` in `buildAttributedString`.
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
    /// carries the custom attributes the text view's menu-building logic reads back:
    /// `.versoHighlightIndex` (source-order index of a `.highlight` run, for remove),
    /// `.versoSourceOffset` (a run's exact raw-file content offset, for an exact same-run wrap --
    /// FAB-303 step 2), `.versoRunKind` and `.versoFullSourceRange` (which kind of run this is and
    /// its full raw span including delimiters, for snap-outward -- FAB-303 step 3).
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
        let codeFont = UIFont(name: "SFMono-Regular", size: max(12, fontSize - 2))
            ?? .monospacedSystemFont(ofSize: max(12, fontSize - 2), weight: .regular)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacingValue

        let result = NSMutableAttributedString()
        var highlightIndex = 0
        let textColor = UIColor(colors.textPrimary)
        let accentColor = UIColor(colors.accent)

        /// `insideHighlight`, when non-nil, means this run is nested inside a `.highlight` node --
        /// every run inside the *same* highlight shares one `versoHighlightIndex` (so "Remove
        /// Highlight" removes the whole thing regardless of which nested word was tapped) and one
        /// `versoRunKind` of `.highlight` (so a selection boundary landing anywhere inside an
        /// existing highlight is treated uniformly, deferring FAB-303 step 3's "merge" case rather
        /// than mis-handling it as an ordinary bold/italic/etc. run).
        func append(
            _ text: String,
            source: MarkdownNode.InlineNode.SourceSpan,
            kind: VersoInlineRunKind,
            font: UIFont,
            color: UIColor,
            extra: [NSAttributedString.Key: Any] = [:],
            insideHighlight: (index: Int, fullRange: Range<Int>)? = nil
        ) {
            let effectiveKind = insideHighlight != nil ? .highlight : kind
            let effectiveFullRange = insideHighlight?.fullRange ?? (contentOffset + source.fullRange.lowerBound)..<(contentOffset + source.fullRange.upperBound)
            var attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle,
                .versoSourceOffset: contentOffset + source.contentRange.lowerBound,
                .versoRunKind: effectiveKind,
                .versoFullSourceRange: effectiveFullRange,
            ]
            if let insideHighlight {
                attributes[.backgroundColor] = UIColor(VersoHighlightColor.wash)
                attributes[.versoHighlightIndex] = insideHighlight.index
            }
            attributes.merge(extra) { _, new in new }
            result.append(NSAttributedString(string: text, attributes: attributes))
        }

        /// Renders one inline node, recursing into `.highlight`'s nested content. `insideHighlight`
        /// carries the enclosing highlight's index/full-range down through recursion so nested
        /// runs (e.g. a bold word inside a highlight) still tag as part of that one highlight.
        func appendInline(_ inline: MarkdownNode.InlineNode, insideHighlight: (index: Int, fullRange: Range<Int>)?) {
            switch inline {
            case .text(let s, let source):
                append(s, source: source, kind: .text, font: baseFont, color: textColor, insideHighlight: insideHighlight)
            case .bold(let s, let source):
                append(s, source: source, kind: .bold, font: baseFont.withSymbolicTraits(.traitBold), color: textColor, insideHighlight: insideHighlight)
            case .italic(let s, let source):
                append(s, source: source, kind: .italic, font: baseFont.withSymbolicTraits(.traitItalic), color: textColor, insideHighlight: insideHighlight)
            case .boldItalic(let s, let source):
                append(s, source: source, kind: .boldItalic, font: baseFont.withSymbolicTraits([.traitBold, .traitItalic]), color: textColor, insideHighlight: insideHighlight)
            case .code(let s, let source):
                append(s, source: source, kind: .code, font: codeFont, color: accentColor, insideHighlight: insideHighlight)
            case .link(let text, let url, let source):
                var extra: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue]
                if let resolved = URL(string: url) {
                    extra[.link] = resolved
                }
                append(text, source: source, kind: .link, font: baseFont, color: accentColor, extra: extra, insideHighlight: insideHighlight)
            case .highlight(let nested, let source):
                let index = highlightIndex
                highlightIndex += 1
                let fullRange = (contentOffset + source.fullRange.lowerBound)..<(contentOffset + source.fullRange.upperBound)
                for inner in nested {
                    appendInline(inner, insideHighlight: (index, fullRange))
                }
            }
        }

        for inline in inlines {
            appendInline(inline, insideHighlight: nil)
        }
        return result
    }
}

/// FAB-303 step 3: which `InlineNode` case a rendered run came from, tagged as `.versoRunKind` so
/// the text view's snap-outward logic (`HighlightableUITextView.applyAddHighlight`) knows whether
/// a selection boundary landing inside a run needs to snap to that run's full (delimiter-included)
/// edge, or can wrap the exact position (`.text`), or must decline (`.code`, entirely within one
/// run; `.highlight`, deferred to a future "merge with existing highlight" step).
enum VersoInlineRunKind {
    case text, bold, italic, boldItalic, code, link, highlight
}

extension NSAttributedString.Key {
    /// FAB-54: 0-based, left-to-right source-order index of a `.highlight` inline node within its
    /// paragraph -- matches the order `MarkdownParser.parseInlines` encounters `==...==` markers in,
    /// which is the same order `ArticleHighlighter.removeHighlight(at:in:)` expects. Lets
    /// `buildMenu(with:)` know *which* existing highlight a selection landed on without re-matching
    /// text. Shared across every run nested inside one highlight (FAB-303 step 3's recursive
    /// `.highlight([InlineNode])`), not just a single flat run.
    static let versoHighlightIndex = NSAttributedString.Key("versoHighlightIndex")

    /// FAB-303 step 2: the exact raw-file (UTF-16) offset where this run's rendered content starts
    /// -- `MarkdownNode.BlockSource.contentOffset + InlineNode.source.contentRange.lowerBound`.
    /// Lets `buildMenu(with:)` convert a selection directly to a raw position for the exact
    /// same-position case, with no searching.
    static let versoSourceOffset = NSAttributedString.Key("versoSourceOffset")

    /// FAB-303 step 3: which kind of run this is (`VersoInlineRunKind`) -- lets snap-outward tell
    /// a plain-text run (always wrap exactly) apart from a delimited one (snap to its edge instead
    /// of splitting `**`/`` ` ``/etc.) apart from code/highlight (decline in specific cases).
    static let versoRunKind = NSAttributedString.Key("versoRunKind")

    /// FAB-303 step 3: this run's full raw span (`Range<Int>`, UTF-16), delimiters included -- the
    /// whole `**word**`/`` `code` ``/`[text](url)`, not just its rendered content. What a selection
    /// boundary snaps outward *to* when it lands strictly inside a delimited run.
    static let versoFullSourceRange = NSAttributedString.Key("versoFullSourceRange")
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

    /// Everything `applyAddHighlight` needs about the run at one selection boundary.
    private struct RunInfo {
        let kind: VersoInlineRunKind
        /// This run's exact raw content-start offset (`.versoSourceOffset`).
        let contentOffset: Int
        /// This run's full raw span, delimiters included (`.versoFullSourceRange`).
        let fullRange: Range<Int>
        /// The rendered `NSRange` this info applies over -- comparing two `RunInfo`s'
        /// `runRange` is how callers tell whether two positions fall inside the *same* run.
        let runRange: NSRange
    }

    private func runInfo(at location: Int) -> RunInfo? {
        guard let attrText = attributedText else { return nil }
        var effectiveRange = NSRange()
        let attrs = attrText.attributes(at: location, effectiveRange: &effectiveRange)
        guard let kind = attrs[.versoRunKind] as? VersoInlineRunKind,
              let offset = attrs[.versoSourceOffset] as? Int,
              let fullRange = attrs[.versoFullSourceRange] as? Range<Int> else {
            return nil
        }
        return RunInfo(kind: kind, contentOffset: offset, fullRange: fullRange, runRange: effectiveRange)
    }

    /// FAB-303 step 3: converts the selection's *start* boundary to an exact raw offset.
    ///
    /// A markdown delimiter (`**`, `` ` ``, `[`/`]`, etc.) is never itself a rendered character --
    /// it's stripped entirely during parsing. That means *any* rendered position inside a
    /// delimited run's span, even exactly at that run's own first character, still sits inside the
    /// delimiters from the raw file's point of view: there is no "safely outside" rendered
    /// position to fall back to short of the run's full (delimiter-included) span. So only `.text`
    /// (which has no delimiters at all) ever uses the exact content-relative position; every other
    /// kind always snaps to `fullRange.lowerBound`, regardless of exactly where inside it the
    /// selection starts.
    private func snappedRawStart(_ position: Int, info: RunInfo) -> Int {
        guard info.kind == .text else { return info.fullRange.lowerBound }
        return info.contentOffset + (position - info.runRange.location)
    }

    /// Same reasoning as `snappedRawStart`, for the selection's *end* boundary (exclusive -- one
    /// past the last selected character), snapping to `fullRange.upperBound` for any non-text kind.
    private func snappedRawEnd(_ exclusiveEnd: Int, info: RunInfo) -> Int {
        guard info.kind == .text else { return info.fullRange.upperBound }
        return info.contentOffset + (exclusiveEnd - info.runRange.location)
    }

    /// FAB-303 step 3: converts the current selection to an exact raw offset range -- snapping
    /// each boundary outward to its enclosing run's edge when it lands strictly inside a delimited
    /// run (bold/italic/bold-italic/link/code), rather than only handling the exact-same-run case
    /// FAB-303 step 2 shipped. Declines when the whole selection sits inside one inline-code run
    /// (nothing safe to wrap -- `==` is literal inside backticks) or when either boundary lands
    /// inside an *existing* highlight (merging with it is a deliberately deferred follow-up, not
    /// this step -- see `docs/BACKLOG.md`'s FAB-303 checklist).
    private func applyAddHighlight() {
        let start = selectedRange.location
        let end = selectedRange.location + selectedRange.length // exclusive
        guard let startInfo = runInfo(at: start), let endInfo = runInfo(at: end - 1) else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        let sameRun = startInfo.runRange == endInfo.runRange
        if sameRun, startInfo.kind == .code {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        if startInfo.kind == .highlight || endInfo.kind == .highlight {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        let rawStart = snappedRawStart(start, info: startInfo)
        let rawEnd = snappedRawEnd(end, info: endInfo)

        guard rawStart < rawEnd else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
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
