# Verso — Pending On-Device Tests

**Version:** 1.0 · **Date:** 2026-09-05 · **Status:** Active

Fabio is away from his Mac/device and can't run a real build or open the
Simulator to confirm each change as it ships (see BACKLOG's "Working mode"
note). Work keeps moving — every item below already compiled clean via
`xcodebuild` and has an open PR — but none of it has been confirmed on a real
Simulator/device yet. Work through this list top to bottom when back at a
Mac; check an item off once it's confirmed, and move its PR to merge (or
report back here if something's actually broken).

To pull a branch: `git fetch && git checkout <branch>`, then `cd Verso &&
xcodegen generate` before opening `Verso.xcodeproj`.

---

## Open

### FAB-333 — Reading measure: OpenDyslexic per-family sizing + new Margins control

- **Branch:** `claude/fab-333-reading-measure`
- **PR:** (opening next)

This is the one I most want your honest read on, not just check/uncheck —
two real judgment calls I made without being able to see either on a
device.

- [ ] **OpenDyslexic at its default size (18pt) now renders noticeably
      smaller** than before (effectively one step down, ~16pt) — pick
      OpenDyslexic in Settings or the reader's font sheet, and judge: does
      the reading column now comfortably fit ~45+ characters per line? If
      it's still cramped, this one-step reduction wasn't enough and needs
      to go further (I flagged this as a real possibility, not a guess I'm
      confident in).
- [ ] **New "Margins" row** in the reader's font sheet (tap the font/spacing
      icon in the bottom bar), below Font Size and Line Spacing. 4 options:
      Wide (today's unchanged default) / Normal / Narrow / Narrowest.
      Confirm the sheet isn't clipped or scrollable-feeling with the third
      row added (I widened its fixed height from 218 to 286 to fit it, but
      couldn't see the actual result).
- [ ] **Tap through all 4 margin levels** and confirm the reading column
      visibly widens as you go from Wide to Narrowest, at a normal font
      size. The new icon (small page outline with two inset marks) is a
      first pass — tell me if it doesn't read clearly as "margin width."
- [ ] **VoiceOver:** swipe to a margin option and confirm it announces
      Wide/Normal/Narrow/Narrowest, and the selected one announces as
      selected.
- [ ] **Pick Narrow or Narrowest, then increase font size toward the top of
      the scale** (26pt) — confirm the column doesn't go edge-to-edge or
      look broken; the size-based taper and your manual margin choice both
      pull toward the same 16pt floor, so they shouldn't fight each other,
      but this is exactly the kind of interaction I can't verify without a
      device.
- [ ] If easy to check: switch device language to **French (Canada)** or
      **Português (Brasil)** and confirm the margin option labels
      ("Large"/"Étroite"/... and "Larga"/"Estreita"/...) show correctly —
      first-draft translations, not yet linguistically reviewed.

### FAB-308 — Localize the reading chrome's accessibility strings

- **Branch:** `fab-308-localize-reading-chrome`
- **PR:** [whysasse/verso-app#372](https://github.com/whysasse/verso-app/pull/372)

Open any article and reveal the reading chrome (tap the article to show/hide
the bars). Ideally test with the device language set to **French (Canada)**
or **Português (Brasil)** — that's the actual point of this fix.

- [ ] **Top bar back button** now announces "Back to reading list" (was just
      "Back") when VoiceOver is on — tap into the reader, turn on VoiceOver,
      swipe to the top-left chevron, confirm the new wording.
- [ ] **Bottom bar's 3 buttons** (font/spacing, listen, theme) all announce
      correctly in VoiceOver, and — this is the actual point of the fix — in
      the **device's selected language**, not always English. Switch the
      device language (Settings → General → Language & Region, or the
      in-app language picker in Settings) to French or Portuguese and
      re-check all three.
- [ ] **TTS button still alternates correctly**: "Listen to article" before
      playback starts, "Stop listening" once it's playing — same as before,
      just now localized.
- [ ] **No regressions to the search bar** — the article list's search field
      and the filter panel's tag-search field still show their placeholder
      text normally (this fix only removed an unused fallback default, no
      visible behavior should change here).

---

## Merged to `main` — checklist not confirmed as run

### FAB-311 — Rebuild the reader's font/spacing sheet

- **Branch:** `fab-311-reader-font-sheet` (merged 2026-09-05)
- **PR:** [whysasse/verso-app#371](https://github.com/whysasse/verso-app/pull/371) — merged
- **Also closes:** FAB-335 (verify only, see below)

This shipped to `main` already. Moving it here rather than straight to "Done"
below since I don't have confirmation the checklist itself was actually run
device-side — flag me if it was and I'll move it down, or work through it now
that it's live and report back if anything's off.

Open any article → tap "Font and spacing" (the font-sheet button) to reach
`ReadingControls`.

- [ ] **✕ is gone, sheet still dismisses.** No close button visible in either
      the font sheet or the theme sheet. Swipe down anywhere on the sheet to
      confirm it still dismisses normally.
- [ ] **Font-size stepper stops cleanly at both ends.** Step the "A"/"A"
      buttons down to the smallest size and up to the largest. It should stop
      exactly at 14 and 26, never show an in-between value like 24, and both
      buttons should look identical (same accent color) at every step —
      including right at the limits, where tapping further should just do
      nothing (no visual "disabled" treatment expected).
- [ ] **Settings' font-size stepper agrees with the reader's.** Settings →
      Reading → font size +/− should land on the exact same 6 sizes
      (14/16/18/20/22/26), in the same order, as the reader's stepper.
- [ ] **Line-spacing row shows 4 icons, not text.** Each of the 4 buttons
      shows a small stack of horizontal bars (5 bars → 2 bars, left to
      right), not the words Compact/Normal/Relaxed/Airy. The selected one
      should be accent-colored with a tinted background; turn on VoiceOver
      and confirm each one announces its name (Compact/Normal/Relaxed/Airy)
      even though the name isn't printed on screen.
- [ ] **No stray dark rectangle below the controls**, in either the font
      sheet or the **theme sheet** (this second check is FAB-335 — the fix
      is shared code, so the theme sheet should already be clean too, but it
      wasn't independently screenshotted). The sheet's surface color should
      reach every edge of the rounded drawer at both heights.
- [ ] **Check this in at least one dark theme (Night or Ink)** — the
      line-spacing bar icons are custom-drawn specifically so they'd tint
      correctly there; a plain bundled asset would have gone invisible on a
      dark background, so this is the one check that actually exercises why
      that choice was made.

### FAB-329 — Folder row disambiguation

- **Branch:** `claude/fab-329-folder-row-icon` (merged 2026-09-05)
- **PR:** [whysasse/verso-app#381](https://github.com/whysasse/verso-app/pull/381) — merged

Settings → the "Articles folder" row (Storage section).

- [ ] **Folder row now shows a small folder icon** before the folder name/path
      text, not just the bare name (previously "Articles folder · Verso" gave
      no visual cue it was a filesystem location).
- [ ] **No truncation regression on a narrow device** (iPhone SE) — icon +
      path text + trailing chevron should still fit without clipping.
- [ ] **Row still opens the folder picker normally** on tap — purely additive
      change, no behavior should differ.

---

### FAB-324 — One `ThemeSwatch` component instead of three

- **Branch:** `claude/fab-324-theme-swatch` (merged 2026-09-05)
- **PR:** [whysasse/verso-app#382](https://github.com/whysasse/verso-app/pull/382) — merged

The compact 32pt swatch's 2-bar layout was my own judgment call, not a
spec'd design — this is the one most worth a close look.

- [ ] **Onboarding theme picker** (only reachable pre-onboarding-completion,
      or via a fresh install/reset — see FAB-328 below for the same
      constraint): the full 120pt swatches show the 4-bar mini-page mockup,
      visually unchanged from before this PR.
- [ ] **Settings → theme picker row** (the 4 small swatches): now shows a
      compact 2-bar mini-page (title + one line) instead of a flat color
      rectangle. Check it reads clearly as "a page," not as noise, in **all
      four themes** — Paper, Sepia, Night, Ink.
- [ ] **Reading view theme sheet** (bottom bar → theme button, the circular
      icon): same 32pt swatches — specifically check **Night vs. Ink** and
      **Paper vs. Sepia** are now clearly distinguishable even when
      unselected (this was the actual bug: they were ~1.06:1 contrast,
      nearly identical flat rectangles, before this fix).
- [ ] **Selected swatch's label is accent-colored**; unselected labels are
      the secondary text color — check this in Settings and the reading
      sheet (previously only the onboarding screen did this).
- [ ] **VoiceOver:** swipe to a theme swatch and confirm the selected one
      announces as selected (`.isSelected` trait added this pass).

---

### FAB-321 — Read time instead of date added on article cards

- **Branch:** `claude/fab-321-read-time` (merged 2026-09-05)
- **PR:** [whysasse/verso-app#383](https://github.com/whysasse/verso-app/pull/383) — merged

Article list, any section except Continue Reading.

- [ ] **Cards show `source.com · 12 min read` on one line**, replacing the
      old separate source + date-added lines.
- [ ] **An article with no source/URL** (e.g. a plain `.md` file dropped into
      the folder with no frontmatter) shows an em dash or read-time-only
      fallback — the card should **not** be visibly shorter than its
      neighbors (that's actually FAB-322's fix, but the fallback logic
      lives in this same card — worth checking together).
- [ ] **Continue Reading section cards are unchanged** — still show the
      source line, progress bar, and percentage caption; no read time there.
- [ ] **VoiceOver, non-Continue-Reading card:** swiping onto a card should
      announce "[title], [source], [N min read]" as **one** stop, then
      swiping again should land on the status badge ("Unread"/"Reading"/
      "Read") as a **separate** stop — not swallowed into the first
      announcement.
- [ ] **VoiceOver hint:** the card announces "Double tap to open."

---

### FAB-317 — Immersive mode top padding

- **Branch:** `claude/fab-317-immersive-top-space` (merged 2026-09-05)
- **PR:** [whysasse/verso-app#384](https://github.com/whysasse/verso-app/pull/384) — merged

**This one has an unresolved contradiction from the original ticket — please
report what you actually see, not just check/uncheck.**

- [ ] Open an article, don't scroll. Note where the H1 title starts with
      chrome visible.
- [ ] Tap once to enter immersive mode. The title/content should visibly
      shift **up** to reclaim the space the now-hidden top bar occupied,
      animating smoothly (~0.3s).
- [ ] **Report back specifically:** did the content *already* shift up
      correctly before this fix (matching some 2026-09-03 screenshots the
      original ticket cited), making this PR redundant? Or did this PR
      actually fix a real "no movement" bug? I couldn't run this test myself
      (no Xcode/simulator here) and pushed the fix based on reading the code,
      not on-device confirmation.
- [ ] **Reduce Motion on** (Settings app → Accessibility → Motion → Reduce
      Motion): repeat the toggle — the shift should be instant, not animated.
- [ ] Try toggling immersive mode **mid-scroll** (partway through a long
      article) — should reflow smoothly, not jump or clip content.

---

### FAB-318 — Reading-view chrome alignment and immersive hint pill

- **Branch:** `claude/fab-318-reading-view-polish` (merged 2026-09-05)
- **PR:** [whysasse/verso-app#385](https://github.com/whysasse/verso-app/pull/385) — merged

- [ ] **Start TTS playback** (bottom bar → listen icon). The transport row
      (skip back / play-pause / skip forward / speed) that appears above the
      main bar should read as **centered**, not hugging the left edge with a
      big empty gap on the right.
- [ ] **Transport icons match the main bar's icon size** (font/spacing,
      listen, theme icons below) — previously visibly smaller/inconsistent.
- [ ] **First time entering immersive mode** (may need a fresh install if the
      "seen hint" flag can't be reset from Settings): the "Tap anywhere to
      reveal controls" pill should appear near the **bottom** of the screen,
      not floating mid-screen over body text.
- [ ] **Tap the pill** — it dismisses. Also check with VoiceOver on: it
      should now announce properly as a real button (was a bare tap gesture
      with no accessibility label before).

---

### FAB-322 — Article list polish (5 separate fixes)

- **Branch:** `claude/fab-322-list-polish` (merged 2026-09-06)
- **PR:** [whysasse/verso-app#386](https://github.com/whysasse/verso-app/pull/386) — merged

- [ ] **Section headers show a count** — "Unread", "Read", "Archived",
      "Continue Reading" now display a number next to the title, not just
      the bare word.
- [ ] **More visual space between sections** than before (top padding raised
      16pt → 24pt) — should read as separated groups, not barely-wider card
      gaps.
- [ ] **Filter panel (tag icon in header) → date presets:** each date option
      (Today / This week / etc.) now shows a circle indicator — filled when
      selected, outline when not — instead of a checkmark. Exactly one
      should always be filled.
- [ ] **Filter panel → tags:** unchanged, still checkmark-only on selected
      tags (multi-select, no regression expected).
- [ ] **An article with no source/URL** shows an em dash instead of a
      shorter, collapsed-looking card (see also FAB-321 above — same card).
- [ ] **Add Article, with VoiceOver on:** submit a URL, let it succeed, and
      confirm the success screen stays up long enough (~4s) to finish
      reading "Article saved" + the subheadline before auto-dismissing
      (previously always dismissed after a flat 1.5s, cutting VoiceOver off).

---

### FAB-328 — Onboarding polish (4 of 5 bullets)

- **Branch:** `claude/fab-328-onboarding-polish` (merged 2026-09-06)
- **PR:** [whysasse/verso-app#387](https://github.com/whysasse/verso-app/pull/387) — merged

Onboarding only runs once per install — you'll likely need a fresh install
(or check Settings' Debug section for a reset option) to see these screens
again.

- [ ] **Folder Setup screen:** the cloud icon above the headline is a crisp
      SF Symbol (outline cloud), not the colored 3D emoji cloud it was
      before.
- [ ] **Folder-picker row's trailing arrow** is a proper thin chevron
      matching the app's other chevrons (was a different typographic mark
      before).
- [ ] **Before choosing a folder,** the caption below "Continue" reads
      "Choose a folder to continue." instead of the privacy note.
- [ ] **After choosing a folder,** the caption switches to "Verso never
      uploads your files. They live in your iCloud Drive." — confirm the
      swap happens live, right when you pick a folder.
- [ ] **Analytics consent screen:** both buttons ("Allow" and "No thanks")
      now look the same visual weight — both outlined, neither filled solid.
- [ ] **Accept button reads "Allow"** (was "Sure, why not").
- [ ] If easy to check: switch device language to **French (Canada)** or
      **Português (Brasil)** and confirm "Autoriser"/"Permitir" show
      correctly — these are first-draft translations, not yet linguistically
      reviewed.

---

### FAB-327 — Onboarding: global Skip + shrinking page dots (minimum fix)

- **Branch:** `claude/fab-327-onboarding-skip-dots` (merged 2026-09-06)
- **PR:** [whysasse/verso-app#389](https://github.com/whysasse/verso-app/pull/389) — merged

Also closes FAB-328's last bullet (Skip stayed in the accessibility tree on
the last tour step) as a side effect — nothing separate to check for that.

Delete the app (or reset onboarding some other way — it only runs once per
install) and go through onboarding fresh.

- [ ] **Skip is now visible on every screen** (Welcome, Theme, Folder,
      Analytics consent, Tour steps 1–2) top-trailing, not just on the tour.
      Confirm it doesn't collide with anything on any of those screens —
      none of them were designed with a persistent top-trailing control
      before this.
- [ ] **Skip disappears on the last tour step** (step 3, "Start reading") —
      confirm there's no ghost tap target where it used to be, and with
      VoiceOver on, swipe through the screen and confirm Skip is not
      announced at all on that last step.
- [ ] **Tapping Skip from each screen** ends onboarding cleanly and lands on
      the article list. From before Folder is picked, confirm you land on
      the "choose a folder" prompt rather than anything broken. From before
      Analytics consent, confirm Settings still shows analytics as off
      (unanswered = opted out, same as "No thanks").
- [ ] **Page dots shrink as you advance** — screen 1 shows 7 dots, and by
      the last tour step only 1 dot remains, instead of always showing 7
      with the highlight moving along. Check this feels right in motion,
      not just correct as a snapshot.
- [ ] **Swiping back still works** on any screen (unrelated to this fix, but
      worth confirming the dot-shrinking didn't do anything odd to layout
      when swiping backward before Skip has hidden any dots).

---

## Done (verified and merged)

*(Nothing yet — this fills in as items above get checked off and confirmed.)*
