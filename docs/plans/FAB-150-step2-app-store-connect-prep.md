# FAB-150 step 2 — App Store Connect preparation (non-build work)

**Version:** 1.0 · **Date:** 2026-08-03 · **Status:** Active

**Parent issue:** [FAB-150](../BACKLOG.md) — [Phase 2] App Store release checklist
**Follows:** [`FAB-150-step1-signing-and-privacy.md`](FAB-150-step1-signing-and-privacy.md), [`FAB-150-step1a-manifest-and-docs-fixes.md`](FAB-150-step1a-manifest-and-docs-fixes.md)
**Goal:** Complete everything the App Store listing needs that does **not** depend on a submittable binary, so that once the release pipeline works the only remaining work is archive → upload → submit.
**Done when:** Device-family scope is decided, the age-rating blocker is fixed in code, the questionnaire and trader status are complete, nutrition labels match the privacy manifests, listing copy is drafted, and a repeatable screenshot process exists.

> **Requirements were verified against Apple's published rules on 2026-08-03.** App Store rules change often. Re-verify anything in Tasks 3–6 against `developer.apple.com` before acting; do not trust this document's numbers if the on-screen form disagrees with them.

---

## Why now

Everything in this plan is unblocked today and is required regardless of how or when the binary gets built. None of it depends on a toolchain.

> **Correction (2026-08-03):** an earlier version of this plan said TestFlight was gated on **Xcode 27 GA**. That was wrong. Apple's floor is **Xcode 26 / iOS 26 SDK** (since 28 April 2026), and GitHub Actions `macos-26` runners already have it — so a release can be built in CI without waiting for GA. See [`FAB-150-step3-ci-release-pipeline.md`](FAB-150-step3-ci-release-pipeline.md). What remains true is that Fabio's **local Xcode 27 beta** can't produce a submittable binary.

---

## Task 1 — Decide v1.0 device family (Fabio's call — blocks Tasks 6 and 7)

### The finding

The app target ships as **universal**. `project.yml` doesn't set `TARGETED_DEVICE_FAMILY` on the `Verso` target, and XcodeGen's default for an iOS app is `1,2` — confirmed in the generated `Verso.xcodeproj/project.pbxproj`, which has `TARGETED_DEVICE_FAMILY = "1,2"` across every configuration.

So Verso will install and run on iPad. Meanwhile **all iPad work is still open**: FAB-131 (the iPad epic), FAB-152/153 (mockups, sign-off), FAB-154–162 (orientations, hybrid split view, adaptive list, reading column, settings, onboarding, share extension, QA). What exists today is the split-view shell from `47c29ce`, plus `UIRequiresFullScreen: true` and portrait-only `UISupportedInterfaceOrientations_iPad`.

Three consequences:

1. **iPad screenshots become mandatory.** Apple requires at least one screenshot per supported device family; if the app runs on iPad, 13-inch iPad screenshots (2064 × 2752) are required alongside the iPhone set.
2. **App Review will test on iPad.** Half-finished iPad layout is a well-known rejection trigger under the completeness guidelines.
3. **`UIRequiresFullScreen: true` needs re-checking.** Apple has been tightening iPad multitasking expectations, and iPadOS's newer windowing model changes what this flag does. Verify current behaviour before shipping it rather than assuming it still passes review quietly.

### Recommendation: ship v1.0 as iPhone-only

Set `TARGETED_DEVICE_FAMILY: "1"` on the `Verso` target for the 1.0 release. Reasoning:

- It matches the PRD, which already says "iPhone primary, iPad secondary" (§2.3), and matches reality — the iPad epic is unstarted.
- It removes the iPad screenshot requirement and the entire iPad review surface in one line.
- Adding iPad later is a normal feature release with its own screenshots. Shipping universal now and *regressing* to iPhone-only later is not possible without pulling support from users who already have it.
- The iPad work is genuinely wanted (FAB-131 is a real epic) — this defers it, doesn't cancel it.

**Cost to be honest about:** iPhone-only apps still run on iPad in compatibility mode, letterboxed at iPhone size. Some users dislike that. The alternative is finishing FAB-155–162 before 1.0, which is a substantial amount of design and implementation work and would delay the release by months.

**Do not change this setting until Fabio decides.** Note that the `ShareExtension` and `VersoTests` targets set `1,2` explicitly (lines 101 and 124 of `project.yml`); if the app goes iPhone-only, the extension should match, or it will be the only iPad-capable piece of the bundle.

---

## Task 2 — Fix `InAppWebView` before it forces an 18+ age rating

### The finding

`Verso/Sources/Screens/Settings/InAppWebView.swift` wraps a bare `WKWebView`:

```swift
func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.load(URLRequest(url: url))
    return webView
}
```

No `WKNavigationDelegate`, no navigation policy, no allow-list. `AboutView.swift:69` loads `https://github.com/whysasse/verso-app` into it.

GitHub is a full website. From that page a user can reach any repository, any user profile, GitHub search, and any outbound link — without ever leaving Verso. That is **unrestricted web access** as Apple's age-rating questionnaire means it, and declaring it truthfully pushes the rating to the top of the scale. Under the rating system Apple overhauled in 2025 (4+, 9+, 13+, 16+, 18+ — the old 12+ and 17+ are gone), a minimalist reading app would end up rated **18+**. That is both wrong and actively harmful to discovery.

Answering "no" while shipping this code is not an option — it's a false declaration on a compliance form.

### The fix

Don't render external sites in-app at all. Two viable approaches, in order of preference:

1. **Open external URLs in Safari** via `@Environment(\.openURL)` or `UIApplication.shared.open`. Simplest, zero maintenance, and unambiguously outside the app.
2. **`SFSafariViewController`** if keeping users nominally in-app matters. It's a system-provided browser chrome that Apple treats differently from an embedded `WKWebView`, and it gives users a visible address bar and Done button.

Either removes the "unrestricted web access" question entirely. A third option — keeping `WKWebView` but adding a `WKNavigationDelegate` that blocks off-host navigation — technically works but is more code, and silently swallowing a link tap is worse UX than handing off to Safari.

**Check for other call sites** before deciding: `AcknowledgementsView.swift:9-11` holds three more external URLs (SwiftSoup, TelemetryClient, Readability.js). Confirm how those are presented today and make the handling consistent.

**This is a code change, not metadata**, so it needs a normal build verification — but it does *not* need an archive, and is therefore in scope despite the Xcode constraint. Reference `docs/copy/UI_COPY.md` if any new user-facing string is needed, per the project's copy rules.

---

## Task 3 — Age rating questionnaire

Apple's questionnaire was overhauled in 2025 and **completion is mandatory** — apps that haven't answered the updated questions are blocked from new submissions. New question groups cover in-app controls, capabilities, medical/wellness topics, and violent themes. A further update in 2026 added social-media questions; any app with social capabilities gets a floor of 13+.

For Verso, after Task 2 lands, the expected answers are all "none": no violence, no medical content, no gambling, no user-generated content shared between users, no social features, no unrestricted web access. Expected outcome: **4+**.

Two things to get right:

- **Tags are not user-generated content in the App Store sense.** They're local metadata in the user's own files, never transmitted or shared with other users. Don't over-declare.
- **Article content is user-supplied but not user-generated-content-sharing.** Users save arbitrary web articles, which could be any subject matter. This is the same position Pocket, Instapaper, and every read-later app occupy. It doesn't create a moderation obligation, because nothing is shared between users — but be ready to say so plainly in the review notes (Task 8).

This is done in App Store Connect, so **Fabio executes it**; the agent's job is to prepare the answers and flag anything ambiguous rather than guess.

---

## Task 4 — EU Digital Services Act trader status

Apple requires a trader-status declaration to submit or update apps distributed in the EU, and **the declaration is required even for developers who don't distribute in the EU**. Apps that fall out of compliance are removed from all 27 EU territories.

If Fabio declares as a trader, the DSA requires his **address, phone number, and email to be published on the App Store product page** for EU users. That's a real privacy consideration for an individual developer publishing a free open-source app from home, and it's the main reason this task deserves a decision rather than a checkbox.

**Whether Verso's distribution constitutes "acting as a trader" is a legal question about Fabio's circumstances, and neither this plan nor the executing agent should answer it.** The relevant inputs — free app, no in-app purchases, open source, individual rather than company account — point one way, but "commercial activity" under the DSA is defined by the regulation, not by whether money changes hands in-app. Read Apple's compliance page, summarize the options and what each publishes publicly, and hand the decision to Fabio. If he wants certainty, that's a question for a lawyer.

A related consideration worth surfacing at the same time: if he declares non-trader and Apple restricts EU distribution as a result, that affects whether the FR-CA localization work has an EU audience — though FR-CA is primarily for Canada, so the localization case stands on its own.

---

## Task 5 — Privacy nutrition labels

These are the App Store Connect questionnaire answers that produce the "App Privacy" section on the product page. They are **separate from `PrivacyInfo.xcprivacy`** but must not contradict it — reviewers do compare them.

Source of truth for the answers:

- `Verso/Resources/PrivacyInfo.xcprivacy` (as corrected in step 1a)
- `Verso/Sources/Services/AnalyticsService.swift`
- `docs/ANALYTICS_STRATEGY.md`

Expected shape, to be verified against the code rather than assumed:

- **Data not collected** for everything except analytics.
- **Analytics:** the manifest declares `NSPrivacyCollectedDataTypeProductInteraction`, not linked to identity, not used for tracking. The nutrition label equivalent is "Usage Data → Product Interaction," marked not linked and not used for tracking.
- **Nothing else.** No contact info, no identifiers, no location, no content. Article text never leaves the device.

**The opt-in matters and should be stated.** Analytics is gated behind an onboarding consent step. Apple still requires declaring the data type, but the consent flow is worth describing in the review notes so the reviewer understands the default state.

Sanity check to run explicitly: confirm `AnalyticsService` sends **no** article titles, URLs, or content as event parameters. A single URL in a telemetry payload would change the nutrition label from "Product Interaction" to something considerably worse, and this is exactly the kind of thing that drifts as events get added.

---

## Task 6 — Listing metadata

Current limits, per localization: **name 30, subtitle 30, keywords 100 (bytes, comma-separated), promotional text 170, description 4000.** Only name + subtitle + keywords are indexed for search — 160 characters total. The description is not indexed on iOS, so it's for conversion, not ranking.

Draft all fields in **EN-CA, FR-CA, and PT-BR**, matching the locales in `docs/LOCALIZATION.md`. Source the positioning from `docs/PRD_MinimalistReaderApp.md` §1–2.2 and the audience from `docs/proto-personas.md` — Alex Chen (Obsidian power user) and Sophie Lavoie (distraction-free commuter reader) are the two people this copy is for, and they want different things: Alex wants "Markdown files you own," Sophie wants "calm reading, no algorithm."

Guidance for the draft:

- **Name:** "Verso" alone is 5 characters and wastes indexed space, but a subtitle carries the qualifier better than a stuffed name. Propose both a bare and a qualified option with reasoning rather than picking silently.
- **Subtitle:** the single highest-leverage field. It should land the file-first differentiator, since that's the actual wedge against Pocket/Instapaper.
- **Keywords:** don't repeat words already in the name or subtitle — Apple indexes across all three, so repetition wastes the budget. Competitor names are a policy risk; avoid them.
- **Description:** lead with the differentiator, not a feature list. `docs/user-frustrations-pocket-instapaper.md` documents the frustrations this app answers and is the best raw material.
- **Promotional text:** editable without a new submission. Keep it for launch/version news, not evergreen copy.
- **Do not invent claims.** No "AI-powered," no unverifiable performance numbers, no comparative claims about named competitors.

**Write the copy into `docs/copy/` as a new file**, per the docs rules — not into BACKLOG or PROJECT_STATUS. Follow the existing header convention (`**Version:** · **Date:** · **Status:**`). Fabio pastes it into App Store Connect; it lives in the repo so it's reviewable and translatable like every other string.

Flag for later, don't solve now: **Québec Bill 96** obligations touch French-language commercial presentation, and `docs/PROJECT_STATUS.md` already tracks this as localization Phase D. It's a legal question, not a copy question.

---

## Task 7 — Screenshot plan (blocked by Task 1)

Current requirements: supply screenshots for the **largest device in each supported family** and Apple scales them down. That means **6.9-inch iPhone at 1320 × 2868** and, only if the app supports iPad, **13-inch iPad at 2064 × 2752**. PNG or JPEG, RGB, **no alpha channel**, exact pixel dimensions — App Store Connect rejects a file that's off by one pixel. One to ten per device class.

If Task 1 lands on iPhone-only, the iPad set disappears entirely.

Rather than capturing by hand — this repeats at every release, across three locales and four themes — plan a **scripted capture** using an XCUITest UI-test target driving `xcrun simctl io … screenshot`, seeded with predictable content. Two existing pieces make this cheap: `DebugSeedService.swift` already exists for seeding sample data, and `SampleArticles/` is already bundled as a resource.

Deliverable for this task is **the plan and the seeding approach**, not the final images — the visual design of the screenshots (captions, framing, ordering) is Fabio's design work, and the story they tell should come from the personas. A reasonable narrative to propose: the reading view first (the actual product), then the four themes, then the Files-app view showing real `.md` files (the differentiator no competitor can show), then the share-extension save flow.

Note the interaction with localization: screenshots are per-locale. If FR-CA and PT-BR ship at 1.0, that's 3× the capture work, which is the strongest practical argument for scripting it.

---

## Task 8 — App Review notes

Verso has two things reviewers reliably get stuck on. Draft notes covering both:

1. **The folder picker.** On first run the app asks the user to choose an iCloud Drive folder, and does nothing useful until they do. A reviewer who taps past onboarding sees an empty app and may file it as broken. Explain the flow, and say explicitly that articles are stored as plain `.md` files in the user's own folder with no account and no server.
2. **The Share Extension.** Reviewers need to be told to save an article from Safari via the share sheet, because it's the primary ingestion path and isn't discoverable from inside the app.

Also state: no account, no login credentials needed (so the reviewer isn't left hunting for a demo account), analytics is opt-in and off by default, and the app makes no network requests other than fetching the article the user explicitly saves.

Write these into the same `docs/copy/` file as Task 6.

---

## Split of work

**Agent can do:** Tasks 2, 5 (drafting), 6, 7 (planning), 8.
**Fabio must do:** Task 1 (decision), Task 3 and 4 (decisions + App Store Connect forms), final entry of all metadata.

Do Task 1 first — it changes the scope of Tasks 6 and 7. Task 2 is independent and can proceed immediately.

---

## Out of scope

No archive, upload, TestFlight, or submission work **in this plan** — that's [`FAB-150-step3-ci-release-pipeline.md`](FAB-150-step3-ci-release-pipeline.md), which runs independently. Do not propose changing Fabio's local Xcode or downgrading macOS; the release path is CI, not his laptop.

The iPad epic (FAB-131, FAB-152–162) is not in scope regardless of how Task 1 is decided.

---

## Sources

Verified 2026-08-03. Re-check before acting — Apple changes these.

- [Updated age ratings in App Store Connect](https://developer.apple.com/news/?id=ks775ehf) — Apple Developer News
- [Age rating questionnaire now includes social media questions](https://developer.apple.com/news/?id=tlur8uvi) — Apple Developer News
- [Age ratings values and definitions](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions/) — App Store Connect Help
- [Manage EU Digital Services Act trader requirements](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/) — App Store Connect Help
- [DSA trader status required for app updates in the EU](https://developer.apple.com/news/upcoming-requirements/?id=10162024a) — Apple Developer
- [App Store screenshot sizes and requirements 2026](https://aso.dev/app-store-connect/screenshots/) — third-party summary, verify against App Store Connect
- [App Store metadata character limits 2026](https://www.applaunchflow.com/blog/app-store-metadata-character-limits-2026) — third-party summary, verify against App Store Connect
