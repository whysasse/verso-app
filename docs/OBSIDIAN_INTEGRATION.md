# Verso — Obsidian Compatibility Technical Spec

**Version:** 2.0
**Date:** 2026-04-19
**Status:** Decisions locked
**Related:** [PRD Section 14](PRD_MinimalistReaderApp.md#14-obsidian-compatibility)

---

## 1. Concept

Obsidian compatibility is not a feature or a mode — it is a natural consequence of the app's file-first architecture. The app saves articles as Markdown files in a user-selected iCloud Drive folder. If the user points their Obsidian vault at that same folder, articles appear as notes automatically. No plugin, no pairing, no configuration on either side.

> **The file is the source of truth.** The app is a Markdown-first reading tool. What users do with those files — including opening them in Obsidian — is entirely up to them.

---

## 2. Architecture Principles

| Principle | Behavior |
|-----------|----------|
| Canonical source | Markdown file on iCloud Drive — app state is always derived from files |
| Write strategy | App writes only on explicit user actions (save article, mark as read) |
| Field ownership | App owns `status` and `added`; all other fields are user-owned |
| Full content | App writes the full parsed article body into the Markdown file — readable natively in Obsidian |
| Graceful degradation | Missing field → use default; invalid frontmatter → skip file with warning; folder moved → prompt re-select |
| Change detection | NSMetadataQuery (iCloud-aware, iOS-native) — reactive re-parse when files change |

---

## 3. File Format

### Frontmatter

```yaml
---
title: "Article title"
url: "https://..."
status: unread   # unread | reading | read
tags: [design, ux]
added: 2026-04-19
---
```

### File body

The full parsed article content follows the frontmatter, formatted as readable Markdown (headings, paragraphs, images as `![]()` links). This makes articles readable natively in Obsidian without opening the Reader app.

### Filename convention

`YYYY-MM-DD Article Title.md`  
Example: `2026-04-19 The Future of Reading Apps.md`

If a file with the same name exists, the app appends a counter: `2026-04-19 The Future of Reading Apps (2).md`

### Field ownership

| Field | Owner | Notes |
|-------|-------|-------|
| `title` | App (initial write) | User can edit; app reads but never overwrites |
| `url` | App (initial write) | Written once on save |
| `status` | App (on user action) | User can also edit directly in Obsidian |
| `tags` | User | App reads for filtering; never modifies |
| `added` | App (initial write) | Written once on save |
| Any other field | User | App ignores completely |

---

## 4. Storage Architecture

| Layer | Role |
|-------|------|
| iCloud Drive folder | Canonical storage — files live here, always accessible |
| Reader app | Saves and displays articles; the primary interface for reading |
| Core Data | Read cache only — rebuilt from files on launch, kept in sync via NSMetadataQuery |
| Obsidian (optional) | Points vault at the same iCloud Drive folder; articles appear as notes |

Core Data is never written to as a primary store. If the cache is lost or stale, the app rebuilds it by scanning the iCloud Drive folder.

---

## 5. iCloud Drive Access (iOS)

The app accesses the user's iCloud Drive folder via iOS's Files framework.

### Initial setup (onboarding)
1. App presents a `UIDocumentPickerViewController` scoped to iCloud Drive
2. User selects or creates a folder (e.g., `Reader/`)
3. App stores a **security-scoped bookmark URL** that persists access across sessions
4. The app begins monitoring the folder via NSMetadataQuery

### Subsequent launches
- App resolves the stored security-scoped bookmark
- If the folder has moved or is inaccessible, app shows an empty state prompting the user to re-select

### Vault path
User-configurable. No fixed convention is enforced. A default suggestion of `Reader/` is shown in onboarding, but the user can select any folder. Obsidian users typically choose a subfolder of their existing vault (e.g., `MyVault/Reading/`).

---

## 6. File Monitoring (NSMetadataQuery)

NSMetadataQuery is the iOS-native, iCloud-aware API for monitoring files in iCloud Drive. It handles both local file changes and changes synced from other devices.

### Query scope
`NSMetadataQueryUbiquitousDocumentsScope` — monitors the iCloud Drive folder for `.md` files

### Events handled
| Event | App behavior |
|-------|-------------|
| File created | Parse frontmatter + body → add to reading list |
| File modified | Re-parse → update list item |
| File deleted | Remove from reading list |
| File renamed | Re-parse under new name → update list item |
| iCloud sync complete | Re-scan affected files |

### Re-parse flow

```
NSMetadataQuery fires notification
    ↓
Identify affected file(s)
    ↓
Parse YAML frontmatter
    ↓
[Valid] → Update Core Data cache → refresh UI
[Invalid frontmatter] → Log warning, skip file, leave cache as-is
[File deleted] → Remove from reading list
[Folder inaccessible] → Show empty state with re-select prompt
```

---

## 7. Writing Articles

When the user saves an article via the Share sheet:

1. Article URL is passed to the app
2. App parses the article using Readability.js via WKWebView (see PRD Section 6.1)
3. App creates a Markdown file in the configured iCloud Drive folder:
   - Writes YAML frontmatter (`title`, `url`, `added`, `status: unread`)
   - Writes full parsed article content as Markdown body
4. iCloud Drive syncs the file to the user's other devices automatically
5. If the user's Obsidian vault points to the same folder, the article appears as a note on the next Obsidian sync

### Status write-back
When the user marks an article as read/unread in the app, the app updates only the `status` field in the file's frontmatter. All other content is untouched.

---

## 8. Conflict Handling

Two concurrent writes (e.g., app and Obsidian both modifying the same file simultaneously):

- **Strategy:** Last-write-wins, with the file on disk as the authoritative final state
- **Flow:** NSMetadataQuery fires → app re-parses → UI updates to match file
- **No merge:** The app does not attempt to merge conflicting changes
- **iCloud conflicts:** iCloud Drive may create a conflict copy (e.g., `Article Title (conflict).md`) — the app treats this as a separate file and adds it to the list with a visual indicator (post-MVP)

---

## 9. Graceful Degradation

| Condition | Behavior |
|-----------|----------|
| Missing `status` field | Default to `unread` |
| Missing `title` field | Use filename (without date prefix and extension) |
| Missing `url` field | Show article without "Open in browser" option |
| Invalid YAML frontmatter | Skip file silently; log warning for debugging |
| File has no frontmatter | Skip file (not treated as a Reader article) |
| Folder moved or deleted | Show empty state with prompt to re-select folder in Settings |
| iCloud Drive unavailable | Show cached articles from Core Data with "Offline" indicator |
| iCloud Drive not enabled | Show setup prompt explaining iCloud Drive is required |

---

## 10. Settings: Folder Configuration

The user manages the iCloud Drive folder in Settings.

**Setting: Reading Folder**
- Displays current folder path
- Button: "Change folder" (opens document picker)
- Button: "Open in Files" (deep link to iCloud Drive folder in Files app)

**No subfolder setting** — the user selects the exact folder during onboarding. If they want a subfolder, they select it directly in the picker.

---

## 11. Implementation Checklist

- [ ] Implement folder selection in onboarding (UIDocumentPickerViewController)
- [ ] Implement security-scoped bookmark persistence
- [ ] Implement NSMetadataQuery file monitor
- [ ] Implement YAML frontmatter parser (title, url, status, tags, added)
- [ ] Implement Markdown file writer (frontmatter + full article body)
- [ ] Implement `status` field write-back (mark read/unread)
- [ ] Implement Core Data cache rebuild from folder scan
- [ ] Implement graceful degradation for all conditions (Section 9)
- [ ] Handle iCloud Drive unavailable / not enabled
- [ ] Write integration tests: save article → verify file created with correct frontmatter
- [ ] Write integration tests: edit `status` in Obsidian → verify app reflects change
- [ ] Write integration tests: mark read in app → verify frontmatter updated, body untouched
- [ ] Stress test: simultaneous writes from app + Obsidian

---

## 12. Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-04-11 | Initial draft (Obsidian as optional mode) |
| 2.0 | 2026-04-19 | Full rewrite: file-first architecture locked, Obsidian reframed as compatibility layer. All open questions resolved. iOS/iCloud Drive approach specified (NSMetadataQuery, security-scoped bookmarks). Full article body in file confirmed. Vault path user-configurable. |
