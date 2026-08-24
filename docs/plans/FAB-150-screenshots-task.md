# FAB-150 — Capture App Store screenshots (task for Claude Code)

**Context:** Part of the FAB-150 App Store release checklist. See `docs/APP_STORE_LISTING.md` for the full listing draft and `docs/BACKLOG.md`'s FAB-150 entry for the release checklist this fits into. Decided 2026-08-24: Claude Code (running locally, since this needs Xcode/Simulator) captures these; Fabio reviews and picks the final set.

## Requirement

Only the **6.9" display class is mandatory** — App Store Connect auto-scales it for every smaller iPhone size. No iPad screenshots needed: `TARGETED_DEVICE_FAMILY` was restricted to iPhone-only this session (2026-08-24), so there's no iPad size class to cover.

- **Simulator device:** iPhone 16 Pro Max or iPhone 17 Pro Max (whichever is available in the installed Simulator runtimes — either satisfies the 6.9" class)
- **Target resolution:** 1320 × 2868 px portrait
- Source: [Apple — Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/)

## Steps

1. Regenerate the Xcode project first — `project.yml` changed this session (`TARGETED_DEVICE_FAMILY` restricted to iPhone-only): `cd Verso && ./generate-xcodeproj.sh`
2. Boot a 6.9"-class simulator (`xcrun simctl list devicetypes` to confirm exact identifier, e.g. `com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro-Max`), build and install Verso (Debug is fine — this doesn't need Release/signing):
   `xcodebuild -project Verso.xcodeproj -scheme Verso -configuration Debug -destination "platform=iOS Simulator,name=iPhone 16 Pro Max" build`
   then install/launch via `xcrun simctl install` / `xcrun simctl launch`.
3. The app bundles 14 sample articles in `SampleArticles/` (nice titles already — "The Philosophy of Walking," "The Science of Sleep," etc.) which should appear in the list on first launch without needing a live iCloud folder — confirm this is actually true for a fresh Simulator install (no folder picked yet); if onboarding blocks the list from showing, you may need to complete the Folder Setup step in onboarding first (any local folder works, per the picker's implementation) before the list is populated.
4. Capture these screens (4–6 total; pick states that show the product's actual differentiators, not just empty defaults):
   - Article List, Paper theme, populated with sample articles
   - Article Reader open on one article (a visually appealing one — e.g. "The Philosophy of Walking" or "The Hidden Life of the Ocean")
   - Immersive reading mode (chrome hidden) — shows the calm, book-like reading experience that's the actual pitch
   - Theme picker or Settings showing the 4 themes (Paper/Sepia/Night/Ink) — a strong visual differentiator
   - Optional: Night or Sepia theme on the reader, if it adds visual variety without repeating the Paper shots
5. Capture with `xcrun simctl io <device> screenshot <output-path>.png` at each state.
6. Save raw PNGs to `docs/printscreens/app-store-2026-08/` (new subfolder — `docs/printscreens/` already exists for other captures) and confirm each is exactly 1320×2868.
7. Report back to Fabio with the file paths — do not add device frames, marketing text, or overlays; that's a design decision for Fabio to make separately if he wants it, not something to bake in automatically.

## Out of scope for this task

- iPad screenshots (not needed — see Requirement above)
- Any device-frame/marketing polish on top of the raw captures
- Actually uploading to App Store Connect (Fabio does that once he's reviewed the set)
