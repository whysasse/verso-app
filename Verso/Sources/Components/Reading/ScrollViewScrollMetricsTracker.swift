import SwiftUI
import UIKit

/// Bridges SwiftUI `ScrollView` scroll position via its backing `UIScrollView`.
/// GeometryReader + preferences often omit updates during scrolling; this keeps the progress bar in sync.
struct ScrollViewScrollMetricsTracker: UIViewRepresentable {
    var onScrollMetrics: (_ offset: CGFloat, _ contentHeightForProgress: CGFloat, _ viewportHeight: CGFloat) -> Void

    func makeUIView(context: Context) -> ScrollMetricsTrackerUIView {
        let view = ScrollMetricsTrackerUIView()
        view.handler = { o, ch, vh in
            DispatchQueue.main.async {
                onScrollMetrics(o, ch, vh)
            }
        }
        return view
    }

    func updateUIView(_ uiView: ScrollMetricsTrackerUIView, context: Context) {
        uiView.handler = { o, ch, vh in
            DispatchQueue.main.async {
                onScrollMetrics(o, ch, vh)
            }
        }
    }
}

final class ScrollMetricsTrackerUIView: UIView {
    var handler: ((CGFloat, CGFloat, CGFloat) -> Void)?

    private weak var trackedScrollView: UIScrollView?
    private var observations: [NSKeyValueObservation] = []

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        reconnectIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        reconnectIfNeeded()
    }

    private func enclosingScrollView() -> UIScrollView? {
        var current: UIView? = superview
        while let view = current {
            if let scrollView = view as? UIScrollView {
                return scrollView
            }
            current = view.superview
        }
        return nil
    }

    private func reconnectIfNeeded() {
        guard let scrollView = enclosingScrollView() else {
            clearTracking()
            return
        }

        if scrollView !== trackedScrollView {
            clearTracking()
            trackedScrollView = scrollView
            let opts: NSKeyValueObservingOptions = [.initial, .new]
            observations.append(scrollView.observe(\.contentOffset, options: opts) { [weak self] _, _ in
                self?.emitIfPossible()
            })
            observations.append(scrollView.observe(\.contentSize, options: opts) { [weak self] _, _ in
                self?.emitIfPossible()
            })
            observations.append(scrollView.observe(\.bounds, options: opts) { [weak self] _, _ in
                self?.emitIfPossible()
            })
            observations.append(scrollView.observe(\.adjustedContentInset, options: opts) { [weak self] _, _ in
                self?.emitIfPossible()
            })
        }

        emitIfPossible()
    }

    private func clearTracking() {
        observations.forEach { $0.invalidate() }
        observations.removeAll()
        trackedScrollView = nil
    }

    /// Maps `UIScrollView` geometry into the inputs expected by `ArticleReaderView.scrollFraction`:
    /// synthetic `contentHeight = viewport + scrollRange` so `(contentHeight - viewport)` equals the true scroll span including insets.
    private func emitIfPossible() {
        guard let scrollView = trackedScrollView, let handler else { return }

        let viewportHeight = scrollView.bounds.height
        guard viewportHeight.isFinite, viewportHeight > 0 else { return }

        let topInset = scrollView.adjustedContentInset.top
        let bottomInset = scrollView.adjustedContentInset.bottom
        let scrollRange = max(0, scrollView.contentSize.height - viewportHeight + topInset + bottomInset)

        let minOffsetY = -topInset
        let rawOffset = scrollView.contentOffset.y - minOffsetY
        let offset = min(max(rawOffset, 0), scrollRange)

        let contentHeightForProgress = viewportHeight + scrollRange

        handler(offset, contentHeightForProgress, viewportHeight)
    }

    deinit {
        clearTracking()
    }
}
