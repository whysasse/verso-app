# Product Requirements Document: Verso

**Version:** 1.7  
**Date:** 2026-05-10  
**Status:** Draft  
**Owner:** Fabio Sasseron

---

## 1. Executive Summary

Verso is a beautifully designed, open-source article reading app for iPhone that saves articles as Markdown files to a user-selected iCloud Drive folder. Users own their reading data — no proprietary database, no lock-in, no accounts. Verso works standalone as a clean, distraction-free reading experience and works especially well with Obsidian: point your vault at Verso's folder and every saved article becomes a note you can link, annotate, and connect to your knowledge base.

**Target User:** Readers who save articles for later and value owning their data — especially those already using Obsidian or plain Markdown for notes.

**Differentiation:** File-first architecture (articles are plain Markdown in iCloud Drive), zero tracking, open-source transparency, Obsidian-native compatibility, and intentionally limited feature scope. The only reading app where your articles live in your own files, not a company's database.

---

## 2. Product Overview

### 2.1 Vision
A reading app that gets out of your way. Save articles. Read them beautifully. That's it.

### 2.2 Core Principles
- **Minimalism:** Only features that directly improve reading. No discovery, no social, no stats.
- **File ownership:** Articles are plain Markdown files in the user's iCloud Drive. No proprietary database, no lock-in, no export needed — the files are always yours.
- **Privacy:** No user data collection. No accounts. Open-source for transparency.
- **Excellence:** Reading experience is best-in-class. Typography, dark mode, and parsing are carefully designed.
- **Simplicity:** Navigation should be obvious. Setup should take under a minute.

### 2.3 Target Platform
- **iOS 16+** (iPhone primary, iPad secondary support)
- **Tech Stack:** SwiftUI, Core Data (read cache), iCloud Drive
- **Bundle ID:** `com.fabiosasseron.verso`
- **Distribution:** Open-source (GitHub) + App Store

---

## 3. Use Cases

### Primary Use Case
1. User reads an article on the web
2. Taps share → selects "Save to Verso"
3. Article is parsed and stored locally
4. User opens app and reads article with distraction-free UI
5. Article is marked as read, automatically archived or kept in list

### Secondary Use Cases
- User revisits a saved article later via search
- User offline: opens app and reads previously saved content
- User exports highlights/notes for research

---

## 4. Feature Requirements

### 4.1 Priority 1 (MVP - Critical)

**4.1.1 Article Parsing & Display**
- Parse articles from shared URLs and extract main content
- Strip ads, navigation, popups, and clutter automatically
- Preserve article structure: headings, paragraphs, bullet points, links
- Display clean, readable text with proper spacing and margins
- Support embedded images with proper scaling
- Handle edge cases: paywalled content, video embeds, code blocks

**4.1.2 Theme System (Paper / Sepia / Night / Ink)**
- Four reading themes: Paper (default warm light), Sepia (vintage warm), Night (warm dark), Ink (cool dark)
- User selects theme in Settings and optionally during onboarding
- Theme persists across sessions

**4.1.3 Typography Fundamentals**
- Font size adjustment (6 sizes: small to extra large)
- Font selection (at least 3 readable serif/sans-serif options)
- Basic text layout (no advanced line height control in MVP)

**4.1.4 Performance**
- Article parsing completes in < 2 seconds
- Smooth 60fps scrolling on iPhone 12+
- App opens and displays saved articles < 500ms
- Minimal memory footprint (target: < 50MB)

**4.1.5 Core Storage & Sync**
- Save articles as Markdown files to a user-selected iCloud Drive folder
- Core Data used as a local read cache only (rebuilt from files — never the source of truth)
- iCloud Drive handles sync automatically across the user's devices — no separate sync setup
- No account required

**4.1.6 Basic Organization**
- Track article status automatically: **Unread** (never opened), **Reading** (opened but not scrolled to end), **Read** (scrolled to end)
- Filter chips on the Home screen: **All / Unread / Reading / Read**
- Sort articles by date saved (newest first, oldest first)
- Simple list view with article title, source, date, and a status indicator
- **Inline title search (MVP):** A search bar on the Home screen filters the visible list by article title in real-time. This is a simple list filter — no search index required. Full-text body search (4.2.2) is post-MVP because it requires indexing and has meaningful performance implications on large Markdown files.

**4.1.7 Offline Reading**
- All saved articles accessible without internet
- Cached article content loads instantly
- No "sync" error messages if offline

**4.1.8 Privacy & Data**
- Zero tracking, no analytics
- No user accounts
- Privacy policy clearly displayed in app
- No data export feature needed — articles are plain Markdown files in the user's own iCloud Drive folder, always accessible outside the app

**4.1.9 Text-to-Speech**
- Built-in speech for article text
- Adjustable playback speed
- Skip forward/back by paragraph
- Works with or without internet

**4.1.10 UI/UX Essentials**
- Single NavigationStack rooted at Home; Settings as full-screen modal
- Obvious "Share" sheet integration
- Minimalist interface—no unnecessary buttons or menus
- Clear onboarding flow (3-4 screens max)
- Accessibility: proper font scaling, color contrast, VoiceOver support
- Support for dynamic type (iOS accessibility feature)

---

### 4.2 Priority 2 (Post-MVP - High Value)

**4.2.1 Typography Refinements**
- Line height adjustment (3 options: tight, normal, loose)
- Letter spacing adjustment
- Text alignment (justify, left)

**4.2.2 Search**
- Full-text search across article titles and content
- Filter by date range
- Filter by source/domain

**4.2.3 Progress Saving**
- Remember scroll position and return to reading location
- Visual progress indicator (e.g., "page 3 of 8")

**4.2.4 Bookmarks**
- Mark specific passages as bookmarks within articles
- Quick jump to bookmarks in reading view

**4.2.5 Tagging System**
- Add tags to articles (e.g., "research", "work", "design")
- Filter/search by tags
- No complex hierarchy (flat tagging only)

**4.2.6 Advanced Organization**
- Bulk mark as read
- Bulk delete
- Quick actions via swipe gestures

**4.2.7 Cross-Device Sync Enhancement**
- Seamless iCloud sync across iPhone, iPad, Mac
- Last read position syncs across devices
- Conflict resolution (last write wins)

---

### 4.3 Priority 3 (Polish - Nice to Have)

**4.3.1 Reading Features**
- Highlighting with color options
- Free-form note-taking within articles
- Export highlights/notes as Markdown

**4.3.2 Content Features**
- Reading time estimates per article
- Article source tracking (clean display of domain/publication)

**4.3.3 Customization**
- Font customization beyond basic options

**4.3.4 Cross-Device Features**
- iCloud backup and restore
- Merge articles from multiple devices

---

### 4.4 Explicitly Out of Scope

The following features are **intentionally NOT included**:

- ❌ Trending/recommended content feed
- ❌ Curated article collections
- ❌ Algorithmic recommendations
- ❌ Social sharing (post/share to Twitter, etc.)
- ❌ Reading statistics dashboard
- ❌ Web app or browser extension
- ❌ User accounts (email signup)
- ❌ User authentication
- ❌ Push notifications
- ❌ Database-backed storage fallback (file-first is the architecture, not a mode)
- ❌ Manual data export (unnecessary — files live in the user's iCloud Drive folder)
- ❌ CloudKit sync (replaced by iCloud Drive's native sync)

**Rationale:** These features add complexity and require server infrastructure or proprietary data storage. The app stays lean, file-first, and focused on core reading.

---

## 5. User Interface & Navigation

### 5.1 Main Screens

**Home / Reading List**
- List of unsaved articles (sorted by date added)
- Pull-to-refresh to sync
- Swipe to delete or archive
- Tap article to open reading view

**Search**
- Full-text search across titles and content
- Search filters (date, read/unread, tag if implemented)
- Recent searches displayed

**Settings**
- Font/typography preferences
- Theme picker (Paper / Sepia / Night / Ink)
- Folder management: view and change the linked iCloud Drive folder. If the user selects a new folder and articles exist in the current one, a dialog asks: *"Move your existing articles to the new folder? Your old folder won't be touched if you choose No."*
- Privacy policy link
- App version and credits

**Reading View (Article)**
- Large, centered text (comfortable margins)
- Top bar: article title, source, date saved
- Bottom controls: text size, theme picker, share, mark read/unread
- Slide-out menu (if more options needed): bookmark, highlight, notes

### 5.2 Share Sheet Integration
- User taps "Share" on article
- Selects "Verso"
- Article URL is sent to app
- App shows brief "Saving..." indicator
- Confirmation when saved

### 5.3 Onboarding
1. **Welcome:** "Your articles. Your files." — brief statement of the app's philosophy
2. **Theme Picker:** User selects their preferred reading theme (Paper / Sepia / Night / Ink)
3. **Vault / Folder Setup:** User selects or creates a folder in iCloud Drive (system folder picker). This is the one required step.
4. **Quick Tour:** One screen showing the share-to-save flow

The folder setup step is mandatory but should feel lightweight — the iOS folder picker is a native, familiar UI.

---

## 6. Technical Approach

### 6.1 Article Parsing Strategy
- **Primary:** Run Mozilla's **Readability.js** inside a hidden `WKWebView` (bundled with the app — no network call required). This is the same engine used by Firefox Reader Mode, battle-tested across millions of sites.
- **Fallback:** SwiftSoup (on-device HTML parser) for cases where WKWebView is unavailable or Readability.js fails to extract content.
- **Caching:** Store parsed content locally to avoid re-parsing
- **Error handling:** Show "Could not parse this article. Open in Safari?" with a fallback link.

**Rationale:** Readability.js is the gold-standard parser, actively maintained by Mozilla, and runs entirely on-device — consistent with the app's offline-first and privacy-first values. A local Swift port (e.g., ReadabilityKit) was considered but ruled out due to limited maintenance. A remote API (e.g., Mercury) was ruled out because it requires internet at save time and introduces a third-party data dependency.

**Web compatibility note:** Readability.js is a JavaScript library at its core. If a web interface is built in the future, it can use Readability.js natively in the browser with no adaptation — this is a deliberately web-friendly choice.

### 6.2 Data Model

**Canonical format: Markdown file with YAML frontmatter**

Each article is a `.md` file in the user's iCloud Drive folder. The file is the record — Core Data is only a cache of this information for fast UI rendering.

```markdown
---
title: "Article title"
url: "https://..."
status: unread   # unread | reading | read
tags: [design, ux]
added: 2026-04-19
---

[Full parsed article content in Markdown]
```

**Filename convention:** `YYYY-MM-DD Article Title.md`  
Example: `2026-04-19 The Future of Reading Apps.md`

**Field ownership:**

| Field | Written by | Editable by user |
|-------|-----------|-----------------|
| `title` | App (initial) | Yes |
| `url` | App (initial) | Yes |
| `status` | App (on user action) | Yes |
| `tags` | User only | Yes |
| `added` | App (initial) | Yes |
| Any other field | — | Yes (app ignores) |

The app never overwrites user-added fields or content. If a file with the same name exists, it appends a counter: `2026-04-19 Article Title (2).md`

**Core Data cache fields (derived from files, never authoritative):**
`id`, `filePath`, `title`, `url`, `status`, `dateAdded`, `source` (extracted from URL domain)

### 6.3 Storage Architecture
- **Primary (source of truth):** Markdown files in a user-selected iCloud Drive folder
- **Cache:** Core Data, rebuilt from files on launch and kept in sync via file system monitoring (NSMetadataQuery). Used only for fast list rendering — never written to as a primary store.
- **No remote servers:** No backend needed. iCloud Drive is the infrastructure.
- **Obsidian compatibility:** If the user points their Obsidian vault at the same iCloud Drive folder, articles appear as notes automatically. No special setup required on either side.

### 6.4 Sync Strategy
- iCloud Drive handles sync automatically across all the user's Apple devices
- No sync toggle, no CloudKit setup, no conflict resolution code needed — the OS handles it
- Conflict resolution (if two devices write simultaneously) is managed by iCloud Drive's native mechanism
- No account required — iCloud Drive uses the user's existing Apple ID

### 6.5 Performance Targets
- App launch: < 500ms
- Article parsing: < 2 seconds
- Article display load: < 200ms (from Core Data)
- Scroll: 60fps
- Memory: < 50MB resident
- Battery impact: minimal (no constant syncing)

---

## 7. Success Metrics

### 7.1 Qualitative
- User can save and read article within 30 seconds total time
- Parsed articles are readable and look good
- No obvious UI friction or confusing interactions
- User considers this a "better" reading experience than Instapaper/Pocket

### 7.2 Quantitative (Post-Launch)
- App store rating: >= 4.5 stars
- Crash rate: < 0.5%
- Average session length: > 5 minutes
- Return user rate (30-day): > 40%

---

## 8. Constraints & Assumptions

### 8.1 Constraints
- **iOS only:** Not planning Android initially
- **No backend:** All processing should happen on device or use public APIs
- **Open-source:** Code must be suitable for public GitHub repo
- **No ads:** Keep app clean (future monetization TBD)

### 8.2 Assumptions
- Users have reliable internet when saving (but not required for reading)
- Users have iOS 16+ devices
- Readability libraries/APIs are available and reliable
- iCloud is available for users who want sync
- Users trust open-source software with their reading data

---

## 9. Risk & Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Article parsing fails for many sites | Low | Test on 20+ major news sites. Provide fallback. User can open in Safari. |
| iCloud sync conflicts cause data loss | High | Implement last-write-wins. Test heavily. Regular local backups. |
| Poor performance on older devices | Medium | Profile and optimize. Test on iPhone 11. Target 60fps only. |
| User data privacy concerns | High | Clear privacy policy. Open-source code. No tracking. File-first storage so users always keep raw Markdown in their chosen folder. |
| Instapaper/Pocket copy our feature | Low | Differentiate on UX polish, not features. Stay focused on reading. |

---

## 10. Release Plan

### Phase 1: MVP (Weeks 1-8)
- Article parsing & clean display
- Dark mode
- Typography controls (size, font)
- Local storage (Core Data)
- Read/unread tracking
- Basic sorting/filtering
- Text-to-speech
- Launch on TestFlight

**Definition of Done:** User can save 5 articles from various sources and read them beautifully offline.

### Phase 2: Polish & Core Features (Weeks 9-12)
- Search functionality (full-text body search, filters)
- Progress saving (scroll position)
- Tagging system (flat tags; stored in frontmatter; filter by tag)
- Improved onboarding
- App Store submission

Articles remain accessible outside the app as plain Markdown in the user’s iCloud Drive folder — **no separate in-app data export feature** (see §4.4).

**Definition of Done:** Feature-complete for Phase 2 priorities. App store ready.

### Phase 3: Enhancement (Weeks 13+)
- Highlighting & notes
- Reading time estimates
- Additional customization
- Community feedback implementation

**Definition of Done:** All Priority 2 features implemented.

---

## 11. Success Criteria for MVP

Before moving to Phase 2:
- ✅ App successfully parses articles from 15+ different websites
- ✅ Articles are readable and visually clean in both light/dark modes
- ✅ Scroll performance is 60fps
- ✅ Articles remain readable without internet
- ✅ Save flow is < 3 taps
- ✅ Onboarding is intuitive (testers don't ask "how do I save?")
- ✅ No crashes in 2 hours of heavy usage
- ✅ Core data survives app restart

---

## 12. Appendix: Competitive Analysis Summary

| Feature | Instapaper | Pocket | Your App |
|---------|-----------|--------|----------|
| Clean reading UX | ✓ | ✓ | ✓ (focus) |
| Offline reading | ✓ | ✓ | ✓ |
| Dark mode | ✓ | ✓ | ✓ |
| Text-to-speech | ✓ | ✓ | ✓ |
| Search | ✓ | ✓ | ✓ |
| Highlighting | ✓ | ✓ | ✓ (later) |
| Sync | ✓ | ✓ | ✓ (iCloud) |
| Open-source | ✗ | ✗ | ✓ |
| Zero tracking | ✓ | ✗ | ✓ |
| Trending content | ✗ | ✓ | ✗ |
| Stats dashboard | ✗ | ✓ | ✗ |
| Web app | ✓ | ✓ | ✗ |

**Your app wins on:** UX focus, open-source, privacy, simplicity. Loses on: cross-device features (initially), social/sharing, stats.

---

## 13. Glossary

- **CloudKit:** Apple's backend service for storing data in iCloud
- **Core Data:** iOS local database framework for offline-first apps
- **Mercury API:** Web service for parsing articles cleanly (evaluated but not chosen — requires internet at save time)
- **Obsidian:** Local-first knowledge management app using Markdown files in a vault
- **Readability.js:** Mozilla's open-source JavaScript library for extracting article content from HTML — the engine behind Firefox Reader Mode. Bundled with the app and run inside a hidden WKWebView.
- **ReadabilityKit:** A Swift port of the Readability algorithm (evaluated but not chosen — limited maintenance activity)
- **SwiftSoup:** A Swift port of Java's jsoup HTML parser. Used as a fallback parsing layer when Readability.js cannot extract content.
- **SwiftUI:** Apple's modern UI framework for iOS apps
- **iCloud Sync:** Automatic syncing of data across user's Apple devices

---

## 14. Obsidian Compatibility

*See full technical spec in [`OBSIDIAN_INTEGRATION.md`](OBSIDIAN_INTEGRATION.md)*

### 14.1 Overview

Obsidian compatibility is not a separate mode — it is a natural consequence of the app's file-first architecture. Because the app saves articles as Markdown files with YAML frontmatter in an iCloud Drive folder, any Obsidian vault that points to that same folder will automatically surface those articles as notes. No plugin, no special setup, no configuration on either side.

> **Central principle: The file is the source of truth.** The app is a Markdown-first reading tool. Obsidian is one of many things users can do with those files.

### 14.2 How It Works

| Layer | Role |
|-------|------|
| iCloud Drive folder | Canonical storage — files live here |
| Reader app | Saves and displays articles; writes Markdown files |
| Obsidian (optional) | Points vault at the same folder; articles appear as notes |
| Core Data | Read cache only — rebuilt from files, never authoritative |

### 14.3 Frontmatter & File Format

See Section 6.2 for the canonical data model. The app writes full parsed article content into the Markdown file body, making articles readable natively in Obsidian without opening the Reader app.

### 14.4 Key Behaviors

- **Change detection:** NSMetadataQuery (iOS, iCloud-aware) — reactive re-parse when files change
- **Graceful degradation:** missing field → use default; invalid frontmatter → skip file with warning; folder moved → prompt user to re-select in Settings
- **Simultaneous writes:** last-write-wins on disk; app re-parses on next file event
- **No data export needed:** files are always accessible in iCloud Drive

---

## 15. Document History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | Apr 2026 | Initial draft | Fabio Sasseron |
| 1.1 | 2026-04-11 | Added Section 14: Obsidian Integration + glossary entry | Fabio Sasseron |
| 1.2 | 2026-04-19 | Section 6.1: parsing strategy locked to Readability.js via WKWebView + SwiftSoup fallback | Fabio Sasseron |
| 1.3 | 2026-04-19 | Major architecture pivot: file-first storage (Markdown + iCloud Drive) replaces Core Data as primary layer. Obsidian compatibility reframed as natural consequence of architecture, not a mode. Executive summary, core principles, data model, storage, sync, onboarding, out-of-scope, and Obsidian sections updated accordingly. | Fabio Sasseron |
| 1.4 | 2026-04-19 | App named: **Verso** | Fabio Sasseron |
| 1.5 | 2026-04-19 | Added three-state article status (Unread / Reading / Read), filter chips on Home screen, and folder-change dialog behavior in Settings | Fabio Sasseron |
| 1.6 | 2026-05-02 | Sync with current architecture: §4.1.2 Dark Mode → Theme system (Paper/Sepia/Night/Ink); §4.1.10 tab navigation → Single NavigationStack; §4.3.3 removed background color options (already MVP via theme system); §5.1 Settings dark-mode toggle → theme picker; §5.3 onboarding reduced to 4 screens (Welcome → Theme Picker → Vault Setup → Quick Tour); §10 removed iCloud sync from Phase 2 (handled natively by iCloud Drive). | Claude |
| 1.7 | 2026-05-10 | §10 Phase 2: removed in-app data export (files are user-accessible per §4.4); moved tagging from Phase 3 into Phase 2 roadmap; §9 privacy risk mitigation wording aligned with file-first model. | Claude |

