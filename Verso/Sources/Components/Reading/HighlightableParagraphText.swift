import SwiftUI
import UIKit

/// FAB-54: selectable paragraph text, bridged to UIKit because neither piece this feature needs
/// exists in SwiftUI's `Text`: a selection-change hook to build a custom "Highlight" menu action,
/// or per-run background color on an `AttributedString` to actually paint the highlight once it
/// exists. Used only for `.paragraph` regions (`MarkdownBodyView`'s `unitView`) — every other
/// block type keeps rendering as plain `Text`, unchanged.
///
/// FAB-303 step 4: renders one or more *consecutive* paragraphs sharing a single `UITextView`, not
/// just one -- iOS can't extend a native text selection across two separate `UIView`s, so
/// selecting text that spans a paragraph break needs the paragraphs to share one view. Headings,
/// list items, and blockquotes aren't part of a region yet (deferred follow-up; see
/// `docs/BACKLOG.md`'s FAB-303 checklist) -- they keep rendering individually.
struct HighlightableParagraphText: UIViewRepresentable {
    let paragraphs: [(inlines: [MarkdownNode.InlineNode], source: MarkdownNode.BlockSource)]
    /// Index *within `paragraphs`* (not the flat node index `MarkdownBodyView.highlightedParagraphIndex`
    /// uses) of the paragraph TTS is currently narrating, if any and if it falls inside this region.
    let activeParagraphIndex: Int?
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
        uiView.paragraphSources = paragraphs.map { $0.source }
        uiView.onHighlightAction = onHighlightAction
        uiView.attributedText = Self.buildAttributedString(
            paragraphs: paragraphs,
            activeParagraphIndex: activeParagraphIndex,
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
    /// its full raw span including delimiters, for snap-outward -- FAB-303 step 3), and
    /// `.versoParagraphIndex` (which paragraph in `paragraphs` a run belongs to -- FAB-303 step 4,
    /// so a selection spanning more than one paragraph can be told apart from one that doesn't;
    /// actually *writing* a highlight across paragraphs is still step 5, not this one).
    static func buildAttributedString(
        paragraphs: [(inlines: [MarkdownNode.InlineNode], source: MarkdownNode.BlockSource)],
        activeParagraphIndex: Int?,
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

        let result = NSMutableAttributedString()
        let textColor = UIColor(colors.textPrimary)
        let accentColor = UIColor(colors.accent)
        // FAB-303 step 4: the TTS "currently narrating paragraph" wash used to be a SwiftUI
        // `.background()` on the whole (single-paragraph) view; a region can hold several
        // paragraphs sharing one view, so it's now a background-color attribute scoped to just the
        // active paragraph's own range instead. An actual highlight's own background (set below,
        // via `extra`, which always wins the attribute merge) still paints over this, same visual
        // precedence the single-paragraph version already had.
        let ttsWashColor = UIColor(colors.accent).withAlphaComponent(0.15)

        for (paragraphIndex, paragraph) in paragraphs.enumerated() {
            // FAB-303 step 4: reset *per paragraph*, not shared across the region -- `.versoHighlightIndex`
            // has to match `ArticleHighlighter.removeHighlight(at:in:)`'s expectation of "the Nth
            // `==...==` match within *this one paragraph's own* rawText", not a running count
            // across every paragraph sharing this view.
            var highlightIndex = 0
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacingValue
            if paragraphIndex > 0 {
                // Matches `MarkdownBodyView.topSpacing`'s existing default-case spacing between
                // paragraphs (16pt) -- reused, not a new number. `paragraphSpacingBefore` (not
                // `.after` on the previous one) so it only ever affects this paragraph's own
                // layout, regardless of what follows the region as a whole.
                paragraphStyle.paragraphSpacingBefore = 16
            }
            let contentOffset = paragraph.source.contentOffset
            let isActiveParagraph = activeParagraphIndex == paragraphIndex

            /// `insideHighlight`, when non-nil, means this run is nested inside a `.highlight`
            /// node -- every run inside the *same* highlight shares one `versoHighlightIndex` (so
            /// "Remove Highlight" removes the whole thing regardless of which nested word was
            /// tapped) and one `versoRunKind` of `.highlight` (so a selection boundary landing
            /// anywhere inside an existing highlight is treated uniformly, deferring FAB-303 step
            /// 3's "merge" case rather than mis-handling it as an ordinary bold/italic/etc. run).
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
                    .versoParagraphIndex: paragraphIndex,
                ]
                if isActiveParagraph {
                    attributes[.backgroundColor] = ttsWashColor
                }
                if let insideHighlight {
                    attributes[.backgroundColor] = UIColor(VersoHighlightColor.wash)
                    attributes[.versoHighlightIndex] = insideHighlight.index
                }
                attributes.merge(extra) { _, new in new }
                result.append(NSAttributedString(string: text, attributes: attributes))
            }

            /// Renders one inline node, recursing into `.highlight`'s nested content.
            /// `insideHighlight` carries the enclosing highlight's index/full-range down through
            /// recursion so nested runs (e.g. a bold word inside a highlight) still tag as part of
            /// that one highlight.
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

            for inline in paragraph.inlines {
                appendInline(inline, insideHighlight: nil)
            }

            // A literal newline between paragraphs *within this region* -- not just visual, but
            // what makes `paragraphSpacingBefore` above actually apply to the next paragraph:
            // `NSParagraphStyle` spacing is scoped per TextKit paragraph, and TextKit paragraphs
            // are delimited by `\n`. Tagged with the trailing paragraph's own `versoParagraphIndex`
            // so a selection landing exactly on it (e.g. double-tapping right at a paragraph
            // break) still resolves to a real paragraph rather than an untagged gap.
            if paragraphIndex < paragraphs.count - 1 {
                result.append(NSAttributedString(string: "\n", attributes: [
                    .versoParagraphIndex: paragraphIndex,
                    .paragraphStyle: paragraphStyle,
                ]))
            }
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

    /// FAB-303 step 4: which paragraph (0-based index into the `paragraphs` array a region was
    /// built from -- *not* the flat `MarkdownNode` index) a run belongs to. A region can share one
    /// `UITextView` across several paragraphs, so `applyAddHighlight` needs this to tell "selection
    /// stays within one paragraph" (proceeds, same as before this step) from "selection spans more
    /// than one" (declines -- writing a highlight across paragraphs safely is step 5's job, not
    /// this one; see `docs/BACKLOG.md`'s FAB-303 checklist).
    static let versoParagraphIndex = NSAttributedString.Key("versoParagraphIndex")
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
    /// FAB-303 step 4: one entry per paragraph in this region, in the same order as
    /// `.versoParagraphIndex` tags them -- replaces step 1-3's single `rawText`/`lineRange`
    /// (a region can now hold more than one paragraph sharing this view).
    var paragraphSources: [MarkdownNode.BlockSource] = []
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
                self?.applyRemoveHighlight(at: index)
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
        /// FAB-303 step 4: which paragraph in `paragraphSources` this run belongs to.
        let paragraphIndex: Int
    }

    private func runInfo(at location: Int) -> RunInfo? {
        guard let attrText = attributedText else { return nil }
        var effectiveRange = NSRange()
        let attrs = attrText.attributes(at: location, effectiveRange: &effectiveRange)
        guard let kind = attrs[.versoRunKind] as? VersoInlineRunKind,
              let offset = attrs[.versoSourceOffset] as? Int,
              let fullRange = attrs[.versoFullSourceRange] as? Range<Int>,
              let paragraphIndex = attrs[.versoParagraphIndex] as? Int else {
            return nil
        }
        return RunInfo(kind: kind, contentOffset: offset, fullRange: fullRange, runRange: effectiveRange, paragraphIndex: paragraphIndex)
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
    /// (nothing safe to wrap -- `==` is literal inside backticks), or when either boundary lands
    /// inside an *existing* highlight (merging with it is a deliberately deferred follow-up -- see
    /// `docs/BACKLOG.md`'s FAB-303 checklist). When the two boundaries land in the *same* paragraph
    /// this wraps one `==…==` pair directly; when they land in different paragraphs (possible since
    /// FAB-303 step 4 merged consecutive paragraphs into one selectable region), FAB-303 step 5's
    /// `ArticleHighlighter.crossParagraphHighlightRanges` computes one pair per paragraph touched.
    private func applyAddHighlight() {
        let start = selectedRange.location
        let end = selectedRange.location + selectedRange.length // exclusive
        guard let startInfo = runInfo(at: start), let endInfo = runInfo(at: end - 1) else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        guard paragraphSources.indices.contains(startInfo.paragraphIndex),
              paragraphSources.indices.contains(endInfo.paragraphIndex) else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        if startInfo.kind == .highlight || endInfo.kind == .highlight {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        if startInfo.paragraphIndex == endInfo.paragraphIndex {
            let sameRun = startInfo.runRange == endInfo.runRange
            if sameRun, startInfo.kind == .code {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            let rawStart = snappedRawStart(start, info: startInfo)
            let rawEnd = snappedRawEnd(end, info: endInfo)
            guard rawStart < rawEnd else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            let source = paragraphSources[startInfo.paragraphIndex]
            applyHighlightChanges([(source, { ArticleHighlighter.addHighlight(atRawOffsetRange: rawStart..<rawEnd, in: $0) })])
            return
        }

        // FAB-303 step 5: the selection spans more than one paragraph -- one `==…==` pair per
        // paragraph touched, tail of the first through head of the last.
        let rawStart = snappedRawStart(start, info: startInfo)
        let rawEnd = snappedRawEnd(end, info: endInfo)
        guard let ranges = ArticleHighlighter.crossParagraphHighlightRanges(
            fromParagraphIndex: startInfo.paragraphIndex,
            rawStart: rawStart,
            toParagraphIndex: endInfo.paragraphIndex,
            rawEnd: rawEnd,
            paragraphs: paragraphSources
        ) else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        let edits = ranges.map { paragraphIndex, rawRange in
            (paragraphSources[paragraphIndex], { (text: String) in ArticleHighlighter.addHighlight(atRawOffsetRange: rawRange, in: text) })
        }
        applyHighlightChanges(edits)
    }

    /// FAB-303 step 4: `existingHighlightIndex` (from `.versoHighlightIndex`, looked up at the
    /// selection's own start) already identifies *which* highlight and, via its tagged runs,
    /// which paragraph it lives in. FAB-303 step 5: that one piece might be only part of a bigger
    /// highlight that was written as several `==…==` pairs across a paragraph break --
    /// `ArticleHighlighter.chainedHighlightPieces` finds every linked piece so removing any one of
    /// them removes all of them, matching what looks like one continuous highlight on screen.
    private func applyRemoveHighlight(at index: Int) {
        guard let info = runInfo(at: selectedRange.location), paragraphSources.indices.contains(info.paragraphIndex) else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        let pieces = ArticleHighlighter.chainedHighlightPieces(startingAt: (info.paragraphIndex, index), in: paragraphSources)
        let edits = pieces.map { paragraphIndex, highlightIndex in
            (paragraphSources[paragraphIndex], { (text: String) in ArticleHighlighter.removeHighlight(at: highlightIndex, in: text) })
        }
        applyHighlightChanges(edits)
    }

    /// Runs each edit's transform against its own `source.rawText`; only if *every* one succeeds
    /// does it report all the changes upstream and clear the selection (the edit menu doesn't
    /// auto-dismiss otherwise). If any single transform fails (`nil`), the whole batch is declined
    /// with one error haptic -- no partial writes, same quiet no-op every other decline in this
    /// feature uses.
    private func applyHighlightChanges(_ edits: [(source: MarkdownNode.BlockSource, transform: (String) -> String?)]) {
        var changes: [(source: MarkdownNode.BlockSource, newRawText: String)] = []
        for edit in edits {
            guard let newRawText = edit.transform(edit.source.rawText) else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            changes.append((edit.source, newRawText))
        }
        selectedRange = NSRange(location: selectedRange.location, length: 0)
        for change in changes {
            onHighlightAction?(change.source.lineRange, change.newRawText)
        }
    }
}
