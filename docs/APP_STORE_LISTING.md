# Verso — App Store Connect Listing Draft (FAB-150)

**Status:** Reviewed by Fabio and entered into App Store Connect 2026-08-25 (subtitle, description, keywords, privacy nutrition labels, age rating, and App Review notes all pasted in). Only the final binary submission for review is still pending.

**Public listing name:** `Verso Reader` — renamed from the placeholder `Version Reader` per Fabio's decision, 2026-08-25, to be used consistently across all storefronts/locales (no per-locale name). In-app branding, docs, and this file otherwise keep saying "Verso" everywhere except the literal App Store name field.

---

## Subtitle (30 characters max)

Pick one, or tell me the angle you'd rather hit:

1. "Read & save, as Markdown files" (30 chars) — leads with the mechanism
2. **"Your articles, saved as files"** (29 chars) — leads with ownership ← **Fabio's pick, confirmed 2026-08-25, entered into ASC**
3. "Markdown articles, your files" (29 chars) — similar, "Markdown" first

---

## Description (4000 characters max — draft is ~1,450)

```
Verso is a minimalist article reader built for people who want to own their reading, not rent it from an app.

Save articles from Safari, Chrome, or any app with a single share — Verso strips away ads and clutter, and saves each one as a plain Markdown file in a folder you choose on your iCloud Drive. No proprietary database. No account. No lock-in. Your articles are just files, forever readable in any text editor, and synced across your devices via your own iCloud.

If you use Obsidian, point it at the same folder and your saved articles appear as notes automatically — tags, reading status, and scroll position all live in the file's frontmatter, fully compatible with your vault.

A CALM, BOOK-LIKE READING EXPERIENCE
• Four themes: Paper, Sepia, Night, and Ink
• Choose New York, Georgia, San Francisco, or OpenDyslexic
• Immersive mode hides the interface as you read — tap to bring it back
• Reading progress tracked automatically: Unread → Reading → Read
• Filter and search your library in seconds

BRING YOUR EXISTING LIBRARY
• Import from Pocket, Instapaper, or GoodLinks — your saved articles become Markdown files instantly, ready to read or drop straight into Obsidian

BUILT TO RESPECT YOUR DATA
• Works entirely offline once articles are saved
• No ads, no tracking by default
• Optional, fully anonymous analytics you can turn off any time in Settings — nothing personal or identifying is ever collected

Verso is open source. Read the code or file an issue at github.com/whysasse/verso-app.
```

---

## Keywords (100 characters max, comma-separated — draft is 90)

```
read later,markdown,obsidian,icloud,reading list,pocket,instapaper,goodlinks,save articles
```

Apple indexes the app name and subtitle separately, so no need to repeat "Verso," "Version Reader," "reader," or "articles" from those fields here — this list spends the character budget on terms people would actually search that *aren't* already covered.

---

## Promotional text (170 characters max, optional — editable after submission without a new review)

```
Save articles as plain Markdown files in your own iCloud Drive. Works standalone, or point Obsidian at the same folder and they show up as notes.
```

---

## Support URL

`https://github.com/whysasse/verso-app` — matches what's already in the bundled privacy policy and the in-app About screen, so it's consistent with what a user sees if they go looking.

## Marketing URL (optional)

Leave blank, or reuse the GitHub URL above — there's no separate marketing site right now.

## Privacy Policy URL

`https://whysasse.github.io/verso-app/` — already live (published via the repo's `gh-pages` branch, commit `68e3526`, "Add public privacy policy page"). Confirmed 2026-08-24: page renders, heading "Privacy Policy," dated "Last updated: August 2026," contact info matches the in-app copy. Ready to paste into ASC as-is — nothing left to do here.

*(Correction: an earlier version of this doc claimed this URL didn't exist. That was wrong — I'd only checked the `main` branch's working tree for a policy page and never checked other branches, where this was already shipped. Sorry for the noise.)*

---

## App Privacy section (nutrition labels)

Based on `Verso/Resources/PrivacyInfo.xcprivacy` and `docs/ANALYTICS_STRATEGY.md`, here's how I'd answer Apple's questionnaire:

**Data Used to Track You:** None.

**Data Linked to Your Identity:** None.

**Data Not Linked to You:**
- **Product Interaction** — collected only if the user opts in to analytics during onboarding (off by default). Purpose: *Analytics*. Sent via TelemetryDeck, which hashes/aggregates signals and never receives personal data, article content, or IP-identifying information (per `docs/ANALYTICS_STRATEGY.md` and the privacy policy).

**Reasoning for declaring analytics at all:** Apple's questionnaire asks about data the app *can* collect across all users, not just what a given install collects by default. Since the analytics code path exists and ships in the binary, declaring "Product Interaction, not linked, Analytics purpose, no tracking" is the accurate answer even though most users will likely never opt in.

The Share Extension's manifest (`Verso/ShareExtension/Resources/PrivacyInfo.xcprivacy`) declares zero collected data types — it only touches the `NSPrivacyAccessedAPICategoryUserDefaults` reason API, so nothing to report there.

---

## Age Rating

I'd expect **4+** — there's no user-generated content exposure beyond articles the user explicitly saves themselves, no ads, no gambling, no messaging between users, no unrestricted web browsing (article content is parsed/stripped, not a general browser). Apple has been iterating on the age-rating questionnaire format, so double-check the live questionnaire in App Store Connect rather than assuming this maps 1:1 — worth five minutes to confirm nothing's changed since I last saw it.

---

## App Review notes (draft)

```
Verso has no accounts and no login — nothing to provide reviewers for sign-in.

On first launch, onboarding asks you to choose a folder where articles will be saved (Welcome → Theme → Folder Setup → Quick Tour). This uses the standard iOS Files picker; any folder works, though iCloud Drive is what we recommend in the UI. Please select or create any folder to proceed past onboarding.

To test the Share Extension: open Safari (or any app), tap Share, choose "Verso," and the article saves in the background. It appears in the main app's list within a moment.

Analytics are off by default and can be enabled/disabled anytime in Settings → Privacy. When enabled, only anonymous, non-identifying usage signals are sent (see the in-app Privacy Policy for detail).

No test account is needed. Let us know if anything in this flow is unclear.
```

---

## Screenshots

**✅ Uploaded 2026-08-25.** Resolved — root cause was not the screenshots. The 2026-08-24 batch (1320×2868, 6.9" class) was correct all along; the rejection was Fabio uploading into the wrong App Store Connect slot (6.5" tab instead of 6.9"). Switched tabs, uploaded the original 1320×2868 set, went through cleanly. No reshoot was needed.

1. `01-article-list-paper.png` — Article List, Paper theme, populated
2. `02-article-reader-paper.png` — Reader open on "The Hidden Life of the Deep Ocean"
3. `03-article-reader-immersive.png` — chrome hidden, clean reading view
4. `04-settings-themes.png` — Settings showing all 4 themes (Paper/Sepia/Night/Ink) + fonts
5. `05-article-reader-night.png` — bonus variety shot, same article in Night theme

No device frames or marketing overlays — raw captures only, as scoped.

---

## Open items before this can actually be submitted

- [x] Fabio picks a subtitle — option 2, "Your articles, saved as files" (2026-08-25)
- [x] Fabio reviews/edits the description and keywords — confirmed as drafted (2026-08-25)
- [x] Screenshots — uploaded successfully 2026-08-25 (original 1320×2868 set; the earlier rejection was the wrong ASC tab, not the images)
- [x] Privacy nutrition labels entered in ASC (2026-08-25, per the draft above)
- [x] Age rating questionnaire completed in ASC (2026-08-25, per the draft above)
- [x] App Review notes pasted into ASC (2026-08-25)
- [ ] Final binary submitted for review
