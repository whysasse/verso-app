import SwiftUI
import CoreData

struct ArticleTagsEditorSheet: View {
    @ObservedObject var article: Article
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var folderBookmarkService: FolderBookmarkService
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var tagText: String = ""
    @FocusState private var fieldFocused: Bool
    @State private var saveFailed = false

    private var colors: ThemeColors { themeManager.colors }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: VersoSpacing.md) {
                Text(L10n.TagsEditor.instructions)
                    .font(VersoTypography.UI.caption)
                    .foregroundColor(colors.textSecondary)

                TextField(L10n.TagsEditor.placeholder, text: $tagText)
                    .textFieldStyle(.plain)
                    .font(VersoTypography.UI.input)
                    .foregroundColor(colors.textPrimary)
                    .padding(VersoSpacing.md)
                    .background(colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: VersoRadius.md, style: .continuous))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($fieldFocused)

                Spacer()
            }
            .padding(VersoSpacing.md)
            .background(colors.background)
            .navigationTitle(L10n.Home.tagFilterTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.TagsEditor.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.TagsEditor.save) { save() }
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            tagText = article.tagList.joined(separator: ", ")
            fieldFocused = true
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .alert(L10n.TagsEditor.saveFailedTitle, isPresented: $saveFailed) {
            Button(L10n.TagsEditor.saveFailedOk, role: .cancel) {}
        } message: {
            Text(L10n.TagsEditor.saveFailedMessage)
        }
    }

    private func save() {
        let tags = tagText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard let folderURL = folderBookmarkService.folderURL else {
            dismiss()
            return
        }
        let path = article.filePath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !path.isEmpty else {
            dismiss()
            return
        }
        let accessed = folderURL.startAccessingSecurityScopedResource()
        defer { if accessed { folderURL.stopAccessingSecurityScopedResource() } }
        do {
            try MarkdownWriter.updateTags(tags, for: path)
            article.tagsSerialized = Article.makeTagsSerialized(from: tags)
            try viewContext.save()
            dismiss()
        } catch {
            saveFailed = true
        }
    }
}
