import Foundation

/// Publishes the one-time "Verso added reading metadata and renamed this file" notice (FAB-290)
/// so it can be shown once, at the app root, no matter which screen triggered the adoption
/// (list swipe, reader auto-save, tag edit). See docs/copy/UI_COPY.md "File Adopted".
@MainActor
final class AdoptionNoticeService: ObservableObject {
    /// Set to `true` whenever `MarkdownWriter.adoptIfNeeded` performs an adoption. `ContentView`
    /// observes this and presents the notice; consumers reset it to `false` on dismiss.
    @Published var isPresented = false

    func notify() {
        isPresented = true
    }
}
