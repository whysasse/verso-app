# Verso — Feature Priority Per Screen

**FAB-61** · Which features appear on which screen for MVP vs. post-MVP.  
Guides scope for Phase 1 wireframes.

Sources: [`PRD_MinimalistReaderApp.md`](PRD_MinimalistReaderApp.md) · [`site-map.md`](site-map.md)

---

## Onboarding (first launch only)

### OB-1 · Welcome

| MVP | Post-MVP |
|-----|----------|
| Intro statement: "Your articles. Your files." | — |
| Brief description of the app's philosophy (Markdown-first, no accounts, iCloud-native) | — |
| Single CTA to proceed to next step | — |

---

### OB-2 · Theme Picker

| MVP | Post-MVP |
|-----|----------|
| Choose default reading theme: Paper, Sepia, Night, Ink | Additional background color variants (e.g. warm dark, high-contrast) |
| Changes shown in real-time preview | — |

---

### OB-3 · Vault / Folder Setup

| MVP | Post-MVP |
|-----|----------|
| Native iOS folder picker to select or create an iCloud Drive folder | — |
| Tip for Obsidian users: "Point your vault at this folder" | — |
| Required step — can't skip | — |

---

### OB-4 · Quick Tour

| MVP | Post-MVP |
|-----|----------|
| Brief walkthrough of 3 core actions: save via Share Sheet, read, archive | — |
| Skippable | — |
| Lands on Home when done | — |

---

## Share Extension

### Article Preview & Confirm

| MVP | Post-MVP |
|-----|----------|
| Parse article from shared URL (via Readability.js) | — |
| Show parsed title, estimated read time, thumbnail | — |
| Save and Cancel actions | — |
| "Saving…" indicator + confirmation on success | — |
| Write Markdown file with YAML frontmatter to iCloud Drive folder | — |
| Error state: "Could not parse this article. Open in Safari?" | — |
| No-folder-configured state: prompt to open main app | — |

---

## Main App

### Home · Article List

| MVP | Post-MVP |
|-----|----------|
| Article list: title, source domain, date saved, read status indicator | Bulk mark as read |
| Sort by date saved: newest first / oldest first | Bulk delete |
| Filter chips: All / Unread / Reading / Read | Swipe quick-actions beyond delete/archive (e.g. tag, bookmark) |
| Inline search: filters list by title in real-time | Full-text search across article body content |
| Swipe to delete | Filter by tag (requires Tagging System) |
| Swipe to archive | Filter search by date range or source domain |
| Archive filter toggle → Archive View | — |
| Empty state (no articles saved yet) | — |
| Settings button in nav bar | — |

> **Note on search:** Basic title filtering is in MVP (it's a simple list filter, no indexing required). Full-text body search is post-MVP — it requires a search index and has measurable performance implications.

---

### Archive View

| MVP | Post-MVP |
|-----|----------|
| Filtered list of archived articles (title, source, date) | — |
| Accessible via toggle on Home screen (not a separate tab) | — |
| Swipe to unarchive (moves file back to main folder) | — |
| Swipe to delete permanently | — |
| Empty state (no archived articles yet) | — |

---

### Reading View

| MVP | Post-MVP |
|-----|----------|
| Full-screen Markdown rendering with chosen theme and font | Scroll position memory (returns to last reading position) |
| Auto status update: Unread → Reading on open; Reading → Read on scroll to end | Visual reading progress indicator (e.g. "3 min left") |
| Immersive mode: tap to show/hide top bar and controls | Bookmarks: mark a passage, quick-jump to bookmarks |
| Top bar: article title, source domain, date saved | Highlighting with color options |
| Back button returns to previous list (Home or Archive) | Free-form notes within articles |
| Opens Reader Settings sheet | Export highlights and notes as Markdown |
| Text-to-Speech: play article audio, adjustable speed, skip by paragraph | Share article from within Reading View |

---

### Reader Settings (bottom sheet)

| MVP | Post-MVP |
|-----|----------|
| Theme: Paper, Sepia, Night, Ink | Line height: tight, normal, loose |
| Font: New York, Georgia, San Francisco, OpenDyslexic | Letter spacing adjustment |
| Text size: 6 steps (small → extra large) | Text alignment: justify or left |
| All changes apply immediately with live preview | Additional font options |

---

### Settings

| MVP | Post-MVP |
|-----|----------|
| Navigation entry points to sub-pages (Folder Setup, Appearance, About) | — |
| Privacy policy link | — |
| App version | — |

---

### Folder Setup *(Settings sub-page)*

| MVP | Post-MVP |
|-----|----------|
| Show currently linked iCloud Drive folder | iCloud backup and restore |
| Change folder via native iOS folder picker | Merge articles from multiple device folders |
| Dialog when changing: "Move your existing articles to the new folder? Your old folder won't be touched if you choose No." | — |

---

### Appearance *(Settings sub-page)*

| MVP | Post-MVP |
|-----|----------|
| Default theme preference (Paper, Sepia, Night, Ink) | Default line height, letter spacing, text alignment |
| Default font preference | — |
| Default text size | — |

---

### About *(Settings sub-page)*

| MVP | Post-MVP |
|-----|----------|
| App version and build number | — |
| Open-source acknowledgements | — |
| Link to GitHub repository | — |

---

## Summary counts

| Scope | Screens with MVP features | Post-MVP items total |
|-------|--------------------------|----------------------|
| Onboarding | 4 | 1 (extra theme variants on OB-2) |
| Share Extension | 1 | — |
| Main App | 8 | ~25 items across Reading View, Home, Reader Settings, Folder Setup, Appearance |

---

*Next step: Phase 1 wireframes, starting with Home · Article List and Reading View.*
