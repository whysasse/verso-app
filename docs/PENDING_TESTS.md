# Verso — Pending On-Device Tests

**Version:** 2.0 · **Date:** 2026-09-08 · **Status:** Active

Tracks work shipped without on-device confirmation while Fabio was away from
his Mac (2026-09-05–07, see BACKLOG's "Working mode" note), until he could
batch-verify it all at once. That pass happened **2026-09-08** — see "Done"
below. This doc stays around empty for whenever the same working mode
recurs; a genuinely empty "Open" section means nothing is currently
awaiting on-device confirmation.

To pull a branch: `git fetch && git checkout <branch>`, then `cd Verso &&
xcodegen generate` before opening `Verso.xcodeproj`.

---

## Open

*(Nothing currently pending.)*

---

## Merged to `main` — checklist not confirmed as run

*(Nothing currently pending.)*

---

## Done (verified and merged)

### Confirmed 2026-09-08 — the full 2026-09-05/07 batch

Fabio ran a real-device pass (iPhone Simulator + screenshots, Night and a
light theme) covering article rendering, the font sheet, the theme sheet,
and the article list, and confirmed the batch below is good. This was a
spot-check across representative screens, not a box-by-box run of every
granular sub-item each ticket originally listed (VoiceOver announcements,
French/Portuguese strings, and iPhone SE narrow-width checks in particular
weren't individually exercised this pass) — flag anything that turns out
wrong and it'll get its own fix. Full implementation writeups for all of
these are in [DONE.md](DONE.md); this entry just closes out their on-device
verification step.

- **FAB-337** — font/theme sheet stray rectangle, theme-swatch spacing,
  missing "%" on the progress caption. Found *during* this pass (screenshots
  surfaced all three), fixed same-session, then re-confirmed good.
- **FAB-333** — reading measure: OpenDyslexic per-family sizing + new
  Margins control. Margins row confirmed present, unclipped, and usable in
  the font sheet. OpenDyslexic's specific size reduction wasn't singled out
  in this pass (no OpenDyslexic screenshot) — worth a specific look if that
  matters going forward.
- **FAB-308** — localized reading chrome accessibility strings.
- **FAB-311** — rebuilt font/spacing sheet (✕ removed, font-size stepper,
  line-spacing icons). Also closes FAB-335 (theme sheet shares the fix).
- **FAB-329** — folder row disambiguation icon.
- **FAB-324** — unified `ThemeSwatch` component; Night vs. Ink and Paper vs.
  Sepia confirmed clearly distinguishable in both the theme sheet and
  general use.
- **FAB-321** — read time instead of date-added on article cards.
- **FAB-317** — immersive-mode top padding collapse.
- **FAB-318** — reading-view chrome alignment + immersive hint pill.
- **FAB-322** — article list polish (section counts, spacing, date-preset
  radio style, no-source fallback, success-sheet timing). Section counts
  ("Unread 11" etc.) confirmed visible on the list.
- **FAB-328** — onboarding polish (SF Symbols, chevron, captions, equal
  consent buttons).
- **FAB-327** — onboarding global Skip + shrinking page dots (minimum-fix
  scope).
