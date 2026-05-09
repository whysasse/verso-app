import SwiftUI
import WebKit

struct InAppWebView: View {
    let url: URL
    let title: String

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        _WebView(url: url)
            .background(themeManager.colors.background.ignoresSafeArea())
            .versoNavigationBar(title: title)
    }
}

private struct _WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
