# Verso — Key Interactions & Gestures

**FAB-62** · The complete list of core interactions, gestures, and what they trigger across every screen. Needed before wireframes.

> Navigation transitions (push, modal, bottom sheet) are documented in [navigation-patterns.md](navigation-patterns.md). This document focuses on **interactions within screens** — taps, swipes, long-presses, and other gestures — and their outcomes.

---

## Share Extension

| Interaction | Trigger | Result |
|---|---|---|
| Tap **Save** | Save button | Parse article → write Markdown file to iCloud Drive folder → show "Saved" confirmation → close extension |
| Tap **Cancel** | Cancel button | Close extension without saving; return to originating app |
| Tap **"Open in Safari?"** | Error state link | Open original URL in Safari; close extension |
| Tap **"Open Verso"** | No-folder-configured state | Deep link into main app to prompt folder setup |

---

## Onboarding

| Interaction | Screen | Trigger | Result |
|---|---|---|---|
| Tap **Continue / Get Started** | All OB screens | Primary CTA button | Push to next onboarding screen |
| Tap **theme option** | OB-2 · Theme Picker | Tap a theme card | Select theme; preview updates in real time |
| Tap **folder picker** | OB-3 · Vault / Folder Setup | Tap "Choose Folder" | Native iOS folder picker sheet; folder confirmed on selection |
| Tap **Skip** | OB-4 · Quick Tour | Skip button | Replace navigation stack with Home |
| Tap **Start Reading** | OB-4 · Quick Tour | Primary CTA | Replace navigation stack with Home |

---

## Home · Article List

| Interaction | Trigger | Result |
|---|---|---|
| Tap **article row** | Tap anywhere on a row | Push to Reading View |
| **Swipe left** on article row | Horizontal swipe | Reveal two trailing actions: **Delete** (red) and **Archive** (gray) |
| Tap **Delete** (swipe action) | Swipe action button | Confirmation dialog: "Delete this article? This cannot be undone." → confirm deletes Markdown file from iCloud Drive |
| Tap **Archive** (swipe action) | Swipe action button | Move Markdown file to `/archived/` subfolder; remove row from list with slide-out animation |
| **Long-press** article row | 0.5s press | Context menu: Open · Archive · Delete · Mark as Read |
| Tap **search bar** | Tap search field | Activate inline search; keyboard appears; list filters in real time as user types |
| Tap **✕** in search bar | Clear button | Clear query; restore full list; keyboard dismisses |
| Tap **filter chip** (All / Unread / Reading / Read) | Tap chip | Switch active filter; list re-filters immediately |
| Tap **sort button** | Nav bar sort icon | Toggle sort order: newest first ↔ oldest first |
| Tap **Archive toggle** | Toggle button (nav bar or inline) | Switch to Archive View (inline filter change, no navigation push) |
| Tap **Settings** button | Nav bar gear icon | Open Settings as full-screen modal cover |
| **Pull to refresh** | Pull down on list | Force re-scan of iCloud Drive folder; reconcile any file changes made outside the app (e.g. via Obsidian) |

---

## Archive View

Archive View is a filtered state of the article list, not a separate screen. Interactions mirror Home with two differences:

| Interaction | Trigger | Result |
|---|---|---|
| **Swipe left** on article row | Horizontal swipe | Reveal two trailing actions: **Delete** (red) and **Unarchive** (blue) |
| Tap **Unarchive** (swipe action) | Swipe action button | Move Markdown file back to main folder; remove row from archived list |
| **Long-press** article row | 0.5s press | Context menu: Open · Unarchive · Delete |
| Tap **Archive toggle** (again) | Toggle button | Return to main article list (same toggle, same in-place switch) |

All other interactions (tap row, search, sort, pull to refresh, Settings) behave identically to Home.

---

## Reading View

| Interaction | Trigger | Result |
|---|---|---|
| **Tap** anywhere on content | Single tap (not on a link) | Toggle immersive mode: hide top bar + controls / show them. Chrome fades in/out with a short opacity animation (~0.2s). On first-ever use, if the hint pill is visible, this tap also permanently dismisses it (see First-use hint row below). |
| **First-use hint** | Automatic — appears when chrome auto-hides for the first time ever | A "Tap anywhere to reveal" pill is shown centered over the article. Dismissed on the user's first tap; `UserDefaults` flag `hasShownImmersiveHint` is set to `true` and the hint is never shown again. Not shown when VoiceOver is active (see accessibility-specs.md §5.3). |
| **Tap** a hyperlink | Tap on a link in the article | Open URL in in-app Safari (SFSafariViewController) |
| Tap **back button** | Nav bar back button | Pop to previous list (Home or Archive) |
| **Swipe right from left edge** | Edge swipe | Pop to previous list (same as back button; standard iOS behavior) |
| Tap **Reader Settings** button | Controls area (visible when chrome is shown) | Open Reader Settings as bottom sheet (.medium detent) |
| **Long-press** on text | 0.5s press on body text | iOS native text selection (system behavior; no custom handling needed) |
| Tap **play** (Text-to-Speech) | TTS control | Start audio playback of article; controls appear |
| Tap **pause** (Text-to-Speech) | TTS control | Pause audio |
| Tap **skip forward** (Text-to-Speech) | TTS skip button | Advance to next paragraph |

> **Immersive mode note:** The first tap into an article (coming from the list) should *not* toggle immersive mode — that tap is navigational. Immersive mode toggling only activates once Reading View is fully presented. This avoids the chrome immediately disappearing the moment the user arrives.

---

## Reader Settings (bottom sheet)

| Interaction | Trigger | Result |
|---|---|---|
| Tap **theme** option | Tap a theme swatch | Apply theme to article behind sheet; preview updates immediately |
| Tap **font** option | Tap a font name | Apply font to article behind sheet; preview updates immediately |
| Tap **text size −** | Minus stepper | Decrease text size one step (6 steps total); article re-renders immediately |
| Tap **text size +** | Plus stepper | Increase text size one step; article re-renders immediately |
| **Swipe down** sheet | Downward drag on sheet handle | Dismiss sheet; return to Reading View |
| **Tap outside** sheet | Tap on article area above sheet | Dismiss sheet; return to Reading View |

> All changes in Reader Settings are applied immediately (no "Apply" button). Changes persist to `UserDefaults` and are restored on next launch.

---

## Settings (full-screen modal)

| Interaction | Trigger | Result |
|---|---|---|
| Tap **Folder Setup** row | List row | Push to Folder Setup sub-page |
| Tap **Appearance** row | List row | Push to Appearance sub-page |
| Tap **About** row | List row | Push to About sub-page |
| Tap **Done** button | Nav bar button | Dismiss modal; return to Home |
| **Swipe down** | Downward drag anywhere | Dismiss modal; return to Home |

---

## Folder Setup (Settings sub-page)

| Interaction | Trigger | Result |
|---|---|---|
| Tap **Change Folder** | Button | Native iOS folder picker; on confirmation: dialog → "Move your existing articles to the new folder?" → Yes or No |
| Tap **back** | Nav bar back button | Pop to Settings |

---

## Appearance (Settings sub-page)

| Interaction | Trigger | Result |
|---|---|---|
| Tap **theme** option | Tap theme row/swatch | Set default theme preference; saved to `UserDefaults` |
| Tap **font** option | Tap font row | Set default font preference |
| Tap **text size** stepper | Stepper | Set default text size |
| Tap **back** | Nav bar back button | Pop to Settings |

---

## About (Settings sub-page)

| Interaction | Trigger | Result |
|---|---|---|
| Tap **GitHub** link | Tap link row | Open GitHub repo in SFSafariViewController |
| Tap **Privacy Policy** link | Tap link row | Open privacy policy in SFSafariViewController |
| Tap **back** | Nav bar back button | Pop to Settings |

---

## Summary — gesture types used

| Gesture | Where used |
|---|---|
| Single tap | Article rows, links, buttons, theme/font options, filter chips, immersive mode toggle |
| Swipe left (trailing) | Article rows on Home and Archive View |
| Swipe right (leading edge) | Reading View → back navigation |
| Swipe down | Settings modal, Reader Settings sheet |
| Long-press | Article rows (context menu), body text in Reading View (system selection) |
| Pull down (list) | Home and Archive View → pull to refresh |

---

*Next: Phase 1 wireframes. Reference this document for labeling interaction hotspots and annotating gesture behaviors on each screen.*
