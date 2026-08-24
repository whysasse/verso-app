# Verso — Obsidian Compatibility Technical Spec

**Version:** 2.1
**Date:** 2026-08-24
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
| Graceful degradation | Missing field → use default; no frontmatter (or frontmatter missing `title`) → adopt the file with synthesized defaults, see §9; folder moved → prompt re-select |
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
[Valid, or no/incomplete frontmatter] → Update Core Data cache → refresh UI (see §9)
[File deleted] → Remove from reading list
[Folder inaccessible] → Show empty state with re-select prompt
```

Every `.md` file in the watched folder is a candidate article — including one with no frontmatter
at all, or frontmatter missing `title` (FAB-290). There is no longer an "invalid frontmatter, skip
file" branch; see §9.

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
| Missing `added` field | Use the file's creation date |
| File has no frontmatter (or unparseable `---` delimiters) | Whole file content becomes the article body; every field above is synthesized as if `title` and `added` were both missing |
| Folder moved or deleted | Show empty state with prompt to re-select folder in Settings |
| iCloud Drive unavailable | Show cached articles from Core Data with "Offline" indicator |
| iCloud Drive not enabled | Show setup prompt explaining iCloud Drive is required |

### Adopting manually-added files (FAB-290)

A file that hits either of the two synthesized-title rows above (no frontmatter, or frontmatter
missing `title`) is a candidate for **adoption** — the mechanism that turns a manually-dropped note
or an existing Obsidian note into a normal Verso article:

1. **Lazy read, not eager write.** Detecting that a file needs adoption never touches disk. It's
   read into the Core Data cache with synthesized defaults and just appears in the list — the
   original file is untouched until the user interacts with it. This matches the app's write
   strategy principle (§2: writes only on explicit user action) and is the safer choice for a note
   that's also live in an Obsidian vault or another tool.
2. **Adoption commit, on first write-back.** The first time the user does something that would
   normally update an app-authored article's frontmatter — mark read/unread, add/edit a tag, change
   status, or scroll-position auto-save (which fires moments after the file is opened, so this is
   usually the trigger in practice) — Verso performs a one-time adopt-and-rename:
   - Builds a full Verso frontmatter block, **merged** with any frontmatter already in the file —
     unrecognized keys (`aliases`, `cssclass`, a personal `tags` scheme, etc.) are preserved
     verbatim, never dropped.
   - Renames the file to the `YYYY-MM-DD Title.md` convention (§3), using the same collision
     handling (`MarkdownWriter.uniqueFilename`) as any other Verso-authored file.
   - Shows a one-time notice (`notice.fileAdopted.message` in `docs/copy/UI_COPY.md`) so the rename
     is never silent.
3. From that point on the file is indistinguishable from one Verso wrote itself.

**Known trade-off:** renaming on adoption (rather than leaving the filename untouched) can break an
Obsidian `[[wikilink]]` elsewhere in the vault that points at the note under its old name — doing the
rename only on first interaction (not at detection) narrows the risk window but doesn't remove it.
A Settings toggle to disable auto-adoption for a shared/actively-linked vault folder is an open
question — see `docs/DONE.md` FAB-290.

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
| 2.1 | 2026-08-24 | FAB-290: §9 rewritten — "no frontmatter" / "invalid frontmatter" no longer skip the file; both are graceful-degraded and adopted (lazy read, adopt-and-rename on first write-back). §2 and §6 updated to match. |
