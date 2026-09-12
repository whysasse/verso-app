# Verso — Error States & Messaging Spec

**Issue:** FAB-85  
**Status:** Draft  
**Date:** 2026-05-03

Defines what the user sees for every failure scenario in Verso: copy, UI treatment, actions, and token references.

---

## Design Principles

- **Offline ≠ error.** Verso's file-first architecture means saved articles always work offline. Connectivity loss is a soft notice, not a failure.
- **Don't block when you can recover silently.** Use toasts and banners before modals and sheets.
- **Always provide an exit.** Every blocking error has at least one action that un-blocks the user.
- **Preserve the URL.** When parsing fails, a stub is saved so the article isn't lost.

---

## Semantic Color Tokens (all themes, WCAG AA)

| Token | Paper/Sepia | Night | Ink | Usage |
|-------|------------|-------|-----|-------|
| `error` | `#AD3327` | `#F87171` | `#FC8181` | Unrecoverable / file failures |
| `warning` | `#B45309` | `#FCD34D` | `#F6E05E` | Recoverable / connectivity |
| `success` | `#166534` | `#4ADE80` | `#68D391` | Confirmations |

Tokens are used as **text tints and border colors only** — never as large fill backgrounds.

---

## Error Scenarios

### 1 · No Internet / Network Failure

**Trigger:** `ArticleParsingError.networkFailed` — URLSession request fails due to no connectivity.

**UI Treatment:** Inline banner (persistent until connectivity returns)

**Copy:**

| Key | String |
|-----|--------|
| `error.offline.banner.headline` | You're offline. |
| `error.offline.banner.subheadline` | Saved articles are still available. |

**Spec:**
- Full-width, sits below navigation bar, above article list
- Background: `warningSurface` (added 2026-09-12 specifically for this — was "`warning` token at 10% opacity" freeform, now a named token; see `docs/DOC_DRIFT_AUDIT_2026-09-12.md` §E1)
- Border-bottom: `warning` token, 1pt
- Headline: SF Semibold 15pt, `warning` token
- Subheadline: SF Regular 13pt, `textSecondary`
- No dismiss button — resolves automatically when connectivity returns
- VoiceOver: announces once on appear (`UIAccessibilityPostNotification`)

---

### 2 · Article Parsing Failed

> **Rewritten 2026-09-12 to match what's actually shipped** — the
> previous version of this section described a bottom-sheet UI with
> "Open in Safari" / "Dismiss" buttons that was never built this way; the
> real screen has different copy, a different button pair, and no
> "Dismiss" at all. See `docs/DOC_DRIFT_AUDIT_2026-09-12.md` §E2 (the
> corner-radius finding that led to checking the rest of the spec against
> code). Ground truth: `Verso/Sources/Screens/ArticleList/AddArticleView.swift`,
> `failureContent`.

**Trigger:** `ArticleParsingError.allParsersFailed` — Readability.js and SwiftSoup both return no content.

**UI Treatment:** Not a separate sheet — a state (`viewState == .failure`) within the same "Add Article" sheet used for URL entry, saving, and duplicate handling (presented from Home's "+" entry point).

**Copy:**

| Key | String | Note |
|-----|--------|------|
| `addArticle.failure.headline` | Could not save article | Fixed headline |
| — | *(dynamic)* | Subheadline is the parser's actual error text (`error.localizedDescription`), not a fixed string — except the no-library-folder path, which uses `addArticle.errorNoLibraryFolder` |
| `addArticle.failure.tryAgain` | Try Again | Primary button |
| `error.parsing.openInSafari` | Open in Safari | Secondary action — the one string this screen kept from the original spec |

`error.parsing.headline`, `error.parsing.subheadline`, and
`error.parsing.dismiss` are dead keys — still present in
`docs/copy/UI_COPY.md` but referenced nowhere in code. Worth a separate
copy-cleanup pass, not fixed here.

**Spec:**
- Icon: `xmark.circle.fill`, 56pt, `error` token
- Headline: `listTitle` style (17pt semibold), `textPrimary`
- Subheadline: `listSubtitle` style (15pt regular), `textSecondary`, centered, horizontal padding `spacing.md` (16pt)
- Outer vertical spacing (icon → headline → subheadline → button stack): `spacing.md` (16pt)
- Buttons stacked vertically, `spacing.sm` (12pt) gap:
  - Primary: "Try Again" — the shared `VersoButtonStyle(.primary)` component (same styling as every other primary button in the system — no local override)
  - Secondary: "Open in Safari" — a plain `Link`, full-width, height 50pt, `button` style (17pt semibold), `accent` foreground, **no fill, no corner radius** (it's text, not a filled shape)
- No "Dismiss" button — the sheet's own toolbar ✕ (always present) is how this state is exited without retrying
- Note: URL stub is already saved; article row appears in list with parse-failed indicator

---

### 3 · Folder Not Configured

> **Rewritten 2026-09-12 to match what's actually shipped** — this was
> never a full-screen state; it's a small inline card. See the note on
> §2 above for why this got checked. Ground truth:
> `Verso/Sources/Components/FolderPickerPrompt.swift`, embedded in
> `ArticleListView.swift`.

**Trigger:** `folderBookmarkService.folderURL == nil` — no folder bookmarked yet (first run before onboarding folder setup, or after clearing it in Settings).

**UI Treatment:** An inline card pinned above the article list (list still renders below/around it — this does not replace the screen).

**Copy:**

| Key | String |
|-----|--------|
| `error.noFolder.headline` | No folder selected. |
| `error.noFolder.subheadline` | Choose a folder in iCloud Drive to start saving articles. |
| `error.noFolder.cta` | Choose folder |

(`docs/copy/UI_COPY.md`'s description column for these three still says
"Full-screen error headline/subheadline" — same stale claim, worth fixing
there too while it's fresh.)

**Spec:**
- Card: `surface` fill, corner radius `radius.md` (12pt), 1pt `border` stroke, padding `spacing.md` (16pt) on all sides, full width, positioned with `spacing.md` horizontal/top padding from the list's own layout
- Icon: `folder.badge.plus`, 32pt, `accent`
- Headline: `listTitle` style, `textPrimary`
- Subheadline: `caption` style (13pt regular), `textSecondary`, centered
- Inner vertical spacing: `spacing.sm` (12pt)
- CTA: "Choose folder" — content-hugging (not full-width), horizontal padding `spacing.md`, vertical padding `spacing.sm`, `accent` fill, corner radius `radius.pill` (20pt — appropriate here: the button's real height is well under 50pt, close to the ~40pt a true pill is meant for), label color is the theme's `background` color (a knockout effect against the accent fill, not `textPrimary`/white), `spacing.xs` (8pt) top margin above it

---

### 4 · Folder Not Found / Moved / Deleted

**Trigger:** The previously bookmarked folder URL is no longer accessible on launch.

**UI Treatment:** Full-screen error state (replaces article list)

**Copy:**

| Key | String |
|-----|--------|
| `error.folderMissing.headline` | Folder not found. |
| `error.folderMissing.subheadline` | The folder may have been moved or deleted. Choose a new one to continue. |
| `error.folderMissing.cta` | Choose new folder |

**Spec:** Same layout as scenario 3.  
Icon: `folder.badge.minus`, 48pt, `textSecondary`

---

### 5 · iCloud Unavailable / Sync Error

**Trigger:** `UIDevice` reports iCloud Drive disabled, or CloudKit sync returns a persistent error.

**UI Treatment:** Persistent inline banner (not dismissible until resolved)

**Copy:**

| Key | String |
|-----|--------|
| `error.iCloudUnavailable.headline` | iCloud Drive is unavailable. |
| `error.iCloudUnavailable.subheadline` | Go to Settings → [Your Name] → iCloud to re-enable it. |

> **Localization note:** `[Your Name]` here is **intentional** — it mirrors Apple's own label for the device-owner row at the top of iOS Settings. It is *not* an unfilled placeholder. Keep it as-is and do not substitute a real name; translators should match Apple's localized term for that row in each locale.

**Spec:**
- Same banner component as scenario 1, but uses `error`/`errorSurface` instead of `warning`/`warningSurface`
- No action button in banner — user must leave the app to resolve
- Article list remains visible and operable (reads cached data)

---

### 6 · File Write Error

**Trigger:** `MarkdownWriter` throws when saving to the iCloud folder (permission denied, disk full, etc.).

**UI Treatment:** Toast (bottom, 3s auto-dismiss)

**Copy:**

| Key | String |
|-----|--------|
| `error.fileWrite.message` | Couldn't save article. |
| `error.fileWrite.subtext` | Check that your folder is accessible and try again. |

**Spec:**
- Bottom-anchored, 16pt side margins, above home indicator / tab bar
- Background: `surface` token
- Border: `error` token, 1pt
- Corner radius: `radius.md` (12pt)
- Left accent bar: 4pt wide, `error` token fill, full height
- Message: SF Semibold 15pt, `textPrimary`
- Subtext: SF Regular 13pt, `textSecondary`
- Padding: 12pt vertical, 16pt horizontal (after accent bar)
- Auto-dismiss: 3s with slide-down + fade-out (200ms ease-in)
- VoiceOver: announces on appear

---

### 7 · File Read Error (Individual Article)

**Trigger:** `MarkdownReader` throws when loading a specific `.md` file in the reading view.

**UI Treatment:** Inline error state (replaces article body, within reading view frame)

**Copy:**

| Key | String |
|-----|--------|
| `error.fileRead.headline` | This article couldn't be loaded. |
| `error.fileRead.cta` | Open original |

**Spec:**
- Vertically centered in the scroll view body area
- Icon: `exclamationmark.triangle`, 36pt, `textSecondary`
- Headline: SF Semibold 17pt, `textPrimary`
- CTA: text button, `accent` color, SF Regular 15pt — opens `sourceURL` in Safari
- Spacing: `spacing.md` (16pt) between all elements

---

### 8 · Share Extension — Parse Failure

**Trigger:** SwiftSoupParser fails in the Share Extension context.

**UI Treatment:** Inline error state within the share sheet

**Copy:**

| Key | String |
|-----|--------|
| `share.error.headline` | Couldn't save this article. |
| `share.error.subheadline` | The page couldn't be read. You can open it directly in Safari. |
| `share.error.openInSafari` | Open in Safari |
| `share.error.dismiss` | Dismiss |

**Spec:**
- Replaces the saving progress state within the existing share sheet
- Icon: `exclamationmark.circle`, 36pt, Paper theme `textSecondary` (share extension uses Paper theme only)
- Same stacked CTA pattern as scenario 2, but within the compact share sheet height

> **Note:** Share extension is locked to the Paper theme. Do not use theme-adaptive tokens here — use Paper theme literal values.

---

## Component Summary

| Component | Scenarios | Dismiss | Token |
|-----------|-----------|---------|-------|
| Inline banner (persistent) | 1, 5 | Auto (connectivity) or never | `warning` / `error` |
| Bottom sheet | 2 | User action | — |
| Full-screen error state | 3, 4 | CTA resolves issue | — |
| Toast | 6 | 3s auto | `error` |
| Inline reading view | 7 | — (passive) | — |
| Share sheet inline | 8 | User action | — |

---

## Accessibility

- All error announcements use `UIAccessibilityPostNotification(.announcement)` on appear
- Banners and toasts: VoiceOver reads headline + subtext as a single announcement
- Bottom sheet: standard sheet accessibility (focus moves to sheet on present)
- Error tokens meet WCAG AA (4.5:1) on `background` and `surface` in all four themes
- Minimum touch target for all CTA buttons: 44×44pt

---

## Mapping to `ArticleParsingError` Cases

| Error case | Scenario |
|------------|----------|
| `.networkFailed(url, error)` | 1 — Offline banner |
| `.readabilityFailed(url)` | — (intermediate; falls through to SwiftSoup) |
| `.swiftSoupFailed(url)` | — (intermediate; falls through to allParsersFailed) |
| `.allParsersFailed(url)` | 2 — Parsing failed bottom sheet |
