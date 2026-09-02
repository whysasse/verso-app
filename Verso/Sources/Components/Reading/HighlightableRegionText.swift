import SwiftUI
import UIKit

/// FAB-54: selectable region text, bridged to UIKit because neither piece this feature needs
/// exists in SwiftUI's `Text`: a selection-change hook to build a custom "Highlight" menu action,
/// or per-run background color on an `AttributedString` to actually paint the highlight once it
/// exists.
///
/// FAB-303 step 4: renders one or more *consecutive* "text blocks" sharing a single `UITextView`,
/// not just one -- iOS can't extend a native text selection across two separate `UIView`s, so
/// selecting text that spans a block break needs the blocks to share one view. Originally
/// paragraphs only; the headings/lists/blockquotes follow-up (`docs/BACKLOG.md`'s FAB-303
/// checklist) brought headings, both list-item kinds, and blockquotes into the same regions --
/// `MarkdownBodyView.groupIntoRenderUnits` decides which flat nodes merge into one region, this
/// view just renders whatever it's given, kind-aware (font, indent, prefix) per block.
struct HighlightableRegionText: UIViewRepresentable {
    let blocks: [MarkdownRegionBlock]
    /// Index *within `blocks`* (not the flat node index `MarkdownBodyView.highlightedParagraphIndex`
    /// uses) of the block TTS is currently narrating, if any and if it falls inside this region.
    /// TTS only ever narrates `.paragraph` nodes (`ArticleReaderView.ttsParagraphs`), so this never
    /// resolves to a heading/list/blockquote block -- no extra guard needed here for that.
    let activeBlockIndex: Int?
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
        uiView.blockSources = blocks.map(\.source)
        uiView.onHighlightAction = onHighlightAction
        let (attributedString, blockquoteRanges) = Self.buildAttributedString(
            blocks: blocks,
            activeBlockIndex: activeBlockIndex,
            fontFamily: fontFamily,
            fontSize: fontSize,
            lineSpacingValue: lineSpacingValue,
            colors: colors
        )
        uiView.attributedText = attributedString
        // FAB-303 blockquote accent bar: the bar is drawn directly by the text view (TextKit has
        // no attribute for "colored rectangle beside these lines"), so it needs the blockquote
        // ranges and the current accent color as plain state, not baked into the attributed string.
        uiView.blockquoteRanges = blockquoteRanges
        uiView.blockquoteAccentColor = UIColor(colors.accent)
        uiView.setNeedsDisplay()
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
    /// `.versoBlockIndex` (which block in `blocks` a run belongs to -- FAB-303 step 4, so a
    /// selection spanning more than one block can be told apart from one that doesn't).
    ///
    /// Also returns the `NSRange` of each `.blockquote` block's content within the built string --
    /// `HighlightableUITextView.draw(_:)` uses these to draw the colored accent bar (FAB-303), a
    /// property of on-screen geometry that has no `NSAttributedString` attribute equivalent.
    static func buildAttributedString(
        blocks: [MarkdownRegionBlock],
        activeBlockIndex: Int?,
        fontFamily: String,
        fontSize: CGFloat,
        lineSpacingValue: CGFloat,
        colors: ThemeColors
    ) -> (NSAttributedString, blockquoteRanges: [NSRange]) {
        let codeFont = UIFont(name: "SFMono-Regular", size: max(12, fontSize - 2))
            ?? .monospacedSystemFont(ofSize: max(12, fontSize - 2), weight: .regular)
        let accentColor = UIColor(colors.accent)
        let markerColor = UIColor(colors.textSecondary)

        let result = NSMutableAttributedString()
        var blockquoteRanges: [NSRange] = []
        // FAB-303 step 4: the TTS "currently narrating paragraph" wash used to be a SwiftUI
        // `.background()` on the whole (single-block) view; a region can hold several blocks
        // sharing one view, so it's now a background-color attribute scoped to just the active
        // block's own range instead. An actual highlight's own background (set below, via `extra`,
        // which always wins the attribute merge) still paints over this, same visual precedence
        // the single-paragraph version already had.
        let ttsWashColor = UIColor(colors.accent).withAlphaComponent(0.15)

        for (blockIndex, block) in blocks.enumerated() {
            // FAB-303 step 4: reset *per block*, not shared across the region -- `.versoHighlightIndex`
            // has to match `ArticleHighlighter.removeHighlight(at:in:)`'s expectation of "the Nth
            // `==...==` match within *this one block's own* rawText", not a running count across
            // every block sharing this view.
            var highlightIndex = 0
            // FAB-303 blockquote accent bar: where this block's own content starts in `result` --
            // recorded so a `.blockquote` block's full range can be captured once its content (and
            // only its content, not the inter-block "\n" that follows) has been appended below.
            let blockStartLocation = result.length
            let blockFont = baseFont(for: block.kind, family: fontFamily, bodySize: fontSize)
            let blockTextColor = textColor(for: block.kind, colors: colors)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacingValue
            if blockIndex > 0 {
                // FAB-303 headings/lists/blockquotes follow-up: restates `MarkdownBodyView
                // .topSpacing`'s exact existing numbers (24pt before a heading, 6pt between sibling
                // list items, 16pt otherwise) via `regionBlockSpacing`, so the same rule governs
                // spacing *within* a region as between fully separate blocks.
                paragraphStyle.paragraphSpacingBefore = regionBlockSpacing(
                    for: block.kind,
                    hasPrevious: true,
                    previousIsListItem: blocks[blockIndex - 1].kind.isListItem
                )
            }

            // FAB-303 headings/lists/blockquotes follow-up: hanging indent for a list item's
            // bullet/number, or a blockquote's downgraded indent-only treatment (see
            // `indentAndPrefix` below for why there's no colored bar this session).
            let (indent, prefix) = indentAndPrefix(for: block.kind)
            if indent > 0 {
                paragraphStyle.headIndent = indent
                paragraphStyle.firstLineHeadIndent = prefix == nil ? indent : 0
                if prefix != nil {
                    paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: indent, options: [:])]
                    paragraphStyle.defaultTabInterval = indent
                }
            }

            let contentOffset = block.source.contentOffset
            let isActiveBlock = activeBlockIndex == blockIndex

            /// `insideHighlight`, when non-nil, means this run is nested inside a `.highlight`
            /// node -- every run inside the *same* highlight shares one `versoHighlightIndex` (so
            /// "Remove Highlight" removes the whole thing regardless of which nested word was
            /// tapped) and one `versoRunKind` of `.highlight` (so a selection boundary landing
            /// anywhere inside an existing highlight is treated uniformly, deferring the "merge"
            /// case rather than mis-handling it as an ordinary bold/italic/etc. run).
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
                    .versoBlockIndex: blockIndex,
                ]
                if isActiveBlock {
                    attributes[.backgroundColor] = ttsWashColor
                }
                if let insideHighlight {
                    attributes[.backgroundColor] = UIColor(VersoHighlightColor.wash)
                    attributes[.versoHighlightIndex] = insideHighlight.index
                }
                attributes.merge(extra) { _, new in new }
                result.append(NSAttributedString(string: text, attributes: attributes))
            }

            /// Renders one inline node, recursing into `.highlight`'s nested content. Every kind's
            /// base font/color now derives from *this block's own* `blockFont`/`blockTextColor`
            /// (a heading's own size, a blockquote's italic + secondary color) instead of a single
            /// fixed body font/color shared by every block -- so a bold or italic word inside a
            /// heading or blockquote composes with the block's own styling (heading-sized bold,
            /// bold-*and*-italic inside a quote) instead of silently reverting to plain body text,
            /// which is what the SwiftUI rendering this replaces actually did. `insideHighlight`
            /// carries the enclosing highlight's index/full-range down through recursion so nested
            /// runs still tag as part of that one highlight.
            func appendInline(_ inline: MarkdownNode.InlineNode, insideHighlight: (index: Int, fullRange: Range<Int>)?) {
                switch inline {
                case .text(let s, let source):
                    append(s, source: source, kind: .text, font: blockFont, color: blockTextColor, insideHighlight: insideHighlight)
                case .bold(let s, let source):
                    append(s, source: source, kind: .bold, font: blockFont.withSymbolicTraits(.traitBold), color: blockTextColor, insideHighlight: insideHighlight)
                case .italic(let s, let source):
                    append(s, source: source, kind: .italic, font: blockFont.withSymbolicTraits(.traitItalic), color: blockTextColor, insideHighlight: insideHighlight)
                case .boldItalic(let s, let source):
                    append(s, source: source, kind: .boldItalic, font: blockFont.withSymbolicTraits([.traitBold, .traitItalic]), color: blockTextColor, insideHighlight: insideHighlight)
                case .code(let s, let source):
                    append(s, source: source, kind: .code, font: codeFont, color: accentColor, insideHighlight: insideHighlight)
                case .link(let text, let url, let source):
                    var extra: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue]
                    if let resolved = URL(string: url) {
                        extra[.link] = resolved
                    }
                    append(text, source: source, kind: .link, font: blockFont, color: accentColor, extra: extra, insideHighlight: insideHighlight)
                case .highlight(let nested, let source):
                    let index = highlightIndex
                    highlightIndex += 1
                    let fullRange = (contentOffset + source.fullRange.lowerBound)..<(contentOffset + source.fullRange.upperBound)
                    for inner in nested {
                        appendInline(inner, insideHighlight: (index, fullRange))
                    }
                }
            }

            // FAB-303 headings/lists/blockquotes follow-up: a list item's literal bullet/number,
            // rendered before its content -- tagged with *none* of the four custom attributes above
            // (no `versoRunKind`/`versoSourceOffset`/`versoFullSourceRange`/`versoBlockIndex`), so
            // `HighlightableUITextView.runInfo(at:)` -- which requires all four -- can never resolve
            // a selection boundary landing on it. That makes the marker inert to selection/wrap by
            // construction, the same technique already used below for the inter-block `\n`.
            if let prefix {
                result.append(NSAttributedString(string: prefix, attributes: [
                    .font: blockFont,
                    .foregroundColor: markerColor,
                    .paragraphStyle: paragraphStyle,
                ]))
            }

            for inline in block.inlines {
                appendInline(inline, insideHighlight: nil)
            }

            if case .blockquote = block.kind {
                blockquoteRanges.append(NSRange(location: blockStartLocation, length: result.length - blockStartLocation))
            }

            // A literal newline between blocks *within this region* -- not just visual, but what
            // makes `paragraphSpacingBefore` above actually apply to the next block: `NSParagraphStyle`
            // spacing is scoped per TextKit paragraph, and TextKit paragraphs are delimited by `\n`.
            if blockIndex < blocks.count - 1 {
                result.append(NSAttributedString(string: "\n", attributes: [
                    .versoBlockIndex: blockIndex,
                    .paragraphStyle: paragraphStyle,
                ]))
            }
        }
        return (result, blockquoteRanges)
    }

    /// FAB-303 headings/lists/blockquotes follow-up: this block's own base font -- a heading's own
    /// size (see `headingFont`), a blockquote's italic body font (matching the SwiftUI version's
    /// `bodyFont.italic()`), or the plain body font for a paragraph/list item.
    private static func baseFont(for kind: MarkdownRegionBlockKind, family: String, bodySize: CGFloat) -> UIFont {
        switch kind {
        case .paragraph, .unorderedListItem, .orderedListItem:
            return systemOrCustomFont(family: family, size: bodySize)
        case .blockquote:
            return systemOrCustomFont(family: family, size: bodySize).withSymbolicTraits(.traitItalic)
        case .heading(let level):
            return headingFont(level: level, family: family)
        }
    }

    private static func systemOrCustomFont(family: String, size: CGFloat) -> UIFont {
        family.isEmpty ? .systemFont(ofSize: size) : (UIFont(name: family, size: size) ?? .systemFont(ofSize: size))
    }

    /// Sizes match `VersoTypography.Reading` exactly (h1 28/bold, h2 24/semibold, h3 20/semibold,
    /// h4 18/semibold). On the system font, `.semibold` is an exact `UIFont.Weight`; on a custom
    /// family, UIKit has no semibold *symbolic trait* the way it has bold/italic, so h2-h4 fall
    /// back to the same bold-symbolic-trait approximation `withSymbolicTraits` below already uses
    /// for a family with no true bold face. Named in `docs/BACKLOG.md`'s FAB-303 checklist as worth
    /// a look on device, not a silent guess.
    private static func headingFont(level: Int, family: String) -> UIFont {
        let size: CGFloat
        switch level {
        case 1: size = 28
        case 2: size = 24
        case 3: size = 20
        default: size = 18
        }
        let weight: UIFont.Weight = level == 1 ? .bold : .semibold
        guard !family.isEmpty else { return .systemFont(ofSize: size, weight: weight) }
        let base = UIFont(name: family, size: size) ?? .systemFont(ofSize: size, weight: weight)
        return base.withSymbolicTraits(.traitBold)
    }

    private static func textColor(for kind: MarkdownRegionBlockKind, colors: ThemeColors) -> UIColor {
        switch kind {
        case .blockquote: return UIColor(colors.textSecondary)
        case .paragraph, .heading, .unorderedListItem, .orderedListItem: return UIColor(colors.textPrimary)
        }
    }

    /// Hanging-indent width and, for a list item, the literal prefix text to render before the
    /// block's own content -- ported from the numbers `MarkdownBodyView.blockView`'s SwiftUI layout
    /// already used (an `HStack` with an 8pt gap for lists, a 3pt `Rectangle` + 12pt gap for a
    /// blockquote), approximated for TextKit's indent model since the two don't translate 1:1.
    ///
    /// The blockquote's 15pt indent reserves exactly the room the original bar (3pt) + gap (12pt)
    /// took -- `HighlightableUITextView.draw(_:)` draws the bar itself into that reserved space,
    /// since TextKit has no attribute for "colored rectangle beside these lines."
    private static func indentAndPrefix(for kind: MarkdownRegionBlockKind) -> (indent: CGFloat, prefix: String?) {
        switch kind {
        case .unorderedListItem:
            return (20, "•\t")
        case .orderedListItem(let index):
            return (32, "\(index).\t")
        case .blockquote:
            return (15, nil)
        case .paragraph, .heading:
            return (0, nil)
        }
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
    /// block -- matches the order `MarkdownParser.parseInlines` encounters `==...==` markers in,
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

    /// FAB-303 step 4: which block (0-based index into the `blocks` array a region was built from --
    /// *not* the flat `MarkdownNode` index) a run belongs to. A region can share one `UITextView`
    /// across several blocks (originally just paragraphs; headings/lists/blockquotes joined via the
    /// follow-up named in `docs/BACKLOG.md`'s FAB-303 checklist), so `applyAddHighlight` needs this
    /// to tell "selection stays within one block" (wraps directly) from "selection spans more than
    /// one" (one `==…==` pair per block touched, via `ArticleHighlighter.crossBlockHighlightRanges`).
    static let versoBlockIndex = NSAttributedString.Key("versoBlockIndex")
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
    /// FAB-303 step 4: one entry per block in this region, in the same order as `.versoBlockIndex`
    /// tags them -- replaces step 1-3's single `rawText`/`lineRange` (a region can now hold more
    /// than one block sharing this view). Originally always paragraphs; can now also hold headings,
    /// list items, and blockquotes.
    var blockSources: [MarkdownNode.BlockSource] = []
    var onHighlightAction: ((_ lineRange: ClosedRange<Int>, _ newRawText: String) -> Void)?

    /// FAB-303 blockquote accent bar: the `NSRange` (within `attributedText`) of each `.blockquote`
    /// block's content -- set by `HighlightableRegionText.updateUIView` alongside `attributedText`
    /// itself, since `buildAttributedString` computes both from the same source data in one pass.
    var blockquoteRanges: [NSRange] = []
    /// The current theme's accent color, for the bar -- this view has no access to `ThemeColors`
    /// on its own (only `HighlightableRegionText`, the SwiftUI wrapper, does).
    var blockquoteAccentColor: UIColor?

    /// Draws the blockquote accent bar: a 3pt-wide rectangle at the region's leading edge, spanning
    /// the full on-screen height of each blockquote block's (possibly multi-line, if the quote
    /// wraps) content -- ported 1:1 from the deleted SwiftUI layout this replaced
    /// (`HStack(spacing: 12) { Rectangle().fill(colors.accent).frame(width: 3); Text(...) }`).
    /// TextKit has no attribute for "colored rectangle beside these lines", so this is a direct
    /// draw override rather than something baked into `attributedText` -- the standard TextKit
    /// technique for a blockquote/pull-quote bar. `indentAndPrefix`'s 15pt blockquote indent
    /// already reserves this exact space (3pt bar + 12pt gap), so the bar's text neighbor never
    /// needs adjusting here.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard !blockquoteRanges.isEmpty, let accentColor = blockquoteAccentColor else { return }
        accentColor.setFill()
        for range in blockquoteRanges {
            let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            guard glyphRange.length > 0 else { continue }
            let bounds = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            let barRect = CGRect(x: 0, y: bounds.minY, width: 3, height: bounds.height)
            UIRectFill(barRect)
        }
    }

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
        /// FAB-303 step 4: which block in `blockSources` this run belongs to.
        let blockIndex: Int
    }

    private func runInfo(at location: Int) -> RunInfo? {
        guard let attrText = attributedText else { return nil }
        var effectiveRange = NSRange()
        let attrs = attrText.attributes(at: location, effectiveRange: &effectiveRange)
        guard let kind = attrs[.versoRunKind] as? VersoInlineRunKind,
              let offset = attrs[.versoSourceOffset] as? Int,
              let fullRange = attrs[.versoFullSourceRange] as? Range<Int>,
              let blockIndex = attrs[.versoBlockIndex] as? Int else {
            return nil
        }
        return RunInfo(kind: kind, contentOffset: offset, fullRange: fullRange, runRange: effectiveRange, blockIndex: blockIndex)
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
    /// run (bold/italic/bold-italic/link/code/highlight), rather than only handling the exact-same-
    /// run case FAB-303 step 2 shipped. Declines when the whole selection sits inside one inline-
    /// code run (nothing safe to wrap -- `==` is literal inside backticks). When the two boundaries
    /// land in the *same* block, a boundary touching an *existing* highlight no longer declines --
    /// `ArticleHighlighter.addOrMergeHighlight` merges into it instead (the "merge" follow-up
    /// named in `docs/BACKLOG.md`'s FAB-303 checklist), snapping through the highlight's own full
    /// range the same way it already snaps through any other delimited run. When the boundaries
    /// land in *different* blocks (possible since regions can merge several blocks, originally
    /// just paragraphs, now also headings/lists/blockquotes), merging isn't attempted -- still
    /// declines if either boundary or any block in between touches an existing highlight, same as
    /// before -- and `ArticleHighlighter.crossBlockHighlightRanges` computes one pair per block
    /// touched.
    private func applyAddHighlight() {
        let start = selectedRange.location
        let end = selectedRange.location + selectedRange.length // exclusive
        guard let startInfo = runInfo(at: start), let endInfo = runInfo(at: end - 1) else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        guard blockSources.indices.contains(startInfo.blockIndex),
              blockSources.indices.contains(endInfo.blockIndex) else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        if startInfo.blockIndex == endInfo.blockIndex {
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
            let source = blockSources[startInfo.blockIndex]
            applyHighlightChanges([(source, { ArticleHighlighter.addOrMergeHighlight(atRawOffsetRange: rawStart..<rawEnd, in: $0) })])
            return
        }

        // Cross-block: merging with an existing highlight here would need finding every touched
        // piece across blocks and re-verifying each one's boundaries after stripping -- the same
        // order of complexity as the same-block merge above, deliberately not attempted this
        // session (see docs/BACKLOG.md's FAB-303 checklist). So this still declines whenever either
        // boundary, or any block the write would touch, has an existing highlight in the way,
        // rather than silently wrapping over -- and corrupting -- it.
        if startInfo.kind == .highlight || endInfo.kind == .highlight {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        let rawStart = snappedRawStart(start, info: startInfo)
        let rawEnd = snappedRawEnd(end, info: endInfo)
        guard let ranges = ArticleHighlighter.crossBlockHighlightRanges(
            fromBlockIndex: startInfo.blockIndex,
            rawStart: rawStart,
            toBlockIndex: endInfo.blockIndex,
            rawEnd: rawEnd,
            blocks: blockSources
        ) else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        for (blockIndex, rawRange) in ranges {
            if ArticleHighlighter.rangeTouchesExistingHighlight(rawRange, in: blockSources[blockIndex].rawText) {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
        }
        let edits = ranges.map { blockIndex, rawRange in
            (blockSources[blockIndex], { (text: String) in ArticleHighlighter.addHighlight(atRawOffsetRange: rawRange, in: text) })
        }
        applyHighlightChanges(edits)
    }

    /// FAB-303 step 4: `existingHighlightIndex` (from `.versoHighlightIndex`, looked up at the
    /// selection's own start) already identifies *which* highlight and, via its tagged runs, which
    /// block it lives in. FAB-303 step 5: that one piece might be only part of a bigger highlight
    /// that was written as several `==…==` pairs across a block break -- `ArticleHighlighter
    /// .chainedHighlightPieces` finds every linked piece so removing any one of them removes all of
    /// them, matching what looks like one continuous highlight on screen.
    private func applyRemoveHighlight(at index: Int) {
        guard let info = runInfo(at: selectedRange.location), blockSources.indices.contains(info.blockIndex) else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        let pieces = ArticleHighlighter.chainedHighlightPieces(startingAt: (info.blockIndex, index), in: blockSources)
        let edits = pieces.map { blockIndex, highlightIndex in
            (blockSources[blockIndex], { (text: String) in ArticleHighlighter.removeHighlight(at: highlightIndex, in: text) })
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
