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
| `error` | `#C0392B` | `#F87171` | `#FC8181` | Unrecoverable / file failures |
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
- Background: `warning` token at 10% opacity
- Border-bottom: `warning` token, 1pt
- Headline: SF Semibold 15pt, `warning` token
- Subheadline: SF Regular 13pt, `textSecondary`
- No dismiss button — resolves automatically when connectivity returns
- VoiceOver: announces once on appear (`UIAccessibilityPostNotification`)

---

### 2 · Article Parsing Failed

**Trigger:** `ArticleParsingError.allParsersFailed` — Readability.js and SwiftSoup both return no content.

**UI Treatment:** Bottom sheet (`.medium` detent)

**Copy:**

| Key | String |
|-----|--------|
| `error.parsing.headline` | Couldn't read this article. |
| `error.parsing.subheadline` | The page may be behind a paywall or require a login. |
| `error.parsing.openInSafari` | Open in Safari |
| `error.parsing.dismiss` | Dismiss |

**Spec:**
- Icon: `exclamationmark.circle`, 36pt, `textSecondary`
- Headline: SF Semibold 20pt, `textPrimary`
- Subheadline: SF Regular 15pt, `textSecondary`
- Vertical spacing between icon → headline → subheadline: `spacing.md` (16pt)
- CTAs stacked vertically below subheadline, `spacing.lg` (24pt) gap:
  - Primary: "Open in Safari" — full-width pill, `accent` fill, SF Semibold 17pt, white label
  - Secondary: "Dismiss" — full-width pill, `surface` fill + `border` stroke, SF Regular 17pt, `textSecondary`
- Both buttons: height 50pt, corner radius `pill` (20pt)
- Note: URL stub is already saved; article row appears in list with parse-failed indicator

---

### 3 · Folder Not Configured

**Trigger:** User opens the app for the first time after skipping onboarding folder setup, or clears folder in Settings.

**UI Treatment:** Full-screen error state (replaces article list)

**Copy:**

| Key | String |
|-----|--------|
| `error.noFolder.headline` | No folder selected. |
| `error.noFolder.subheadline` | Choose a folder in iCloud Drive to start saving articles. |
| `error.noFolder.cta` | Choose folder |

**Spec:**
- Icon: `folder.badge.questionmark`, 48pt, `textSecondary`
- Headline: SF Semibold 20pt, `textPrimary`
- Subheadline: SF Regular 15pt, `textSecondary`
- CTA: full-width pill (max 280pt), `accent` fill, SF Semibold 17pt, white label, height 50pt
- Vertical layout centered in safe area, spacing `spacing.lg` (24pt) between elements
- Horizontal padding: `spacing.xl` (32pt)

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

**Spec:**
- Same banner component as scenario 1, but uses `error` token instead of `warning`
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
