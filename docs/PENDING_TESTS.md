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

**Note on parallel branches:** FAB-311 and FAB-308 were both built off `main`
independently (neither waited for the other to merge), so this file exists
separately on both branches with different content. Whichever PR merges
second will hit a merge conflict on this file — resolve it by keeping both
branches' entries, not by picking one side.

---

## Open

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

### FAB-311 — Rebuild the reader's font/spacing sheet

- **Branch:** `fab-311-reader-font-sheet`
- **PR:** [whysasse/verso-app#371](https://github.com/whysasse/verso-app/pull/371)
- **Also closes:** FAB-335 (verify only, see below)

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

---

## Done (verified and merged)

*(Nothing yet — this fills in as items above get checked off and merged.)*
