# FAB-150 step 1a — Privacy manifest reason codes + docs reconciliation

**Version:** 1.0 · **Date:** 2026-08-03 · **Status:** Active

**Parent issue:** [FAB-150](../BACKLOG.md) — [Phase 2] App Store release checklist
**Follows:** [`FAB-150-step1-signing-and-privacy.md`](FAB-150-step1-signing-and-privacy.md) (merged as PR #316)
**Goal:** Correct one real defect in the shipped privacy manifests, and clear two documentation-accuracy problems before App Store metadata gets written from those docs.
**Done when:** Both manifests declare the correct required-reason codes, `PROJECT_STATUS.md` reflects what actually shipped, and no doc implies GitHub Issues is a tracker.

---

## Starting state

`main` has the five FAB-150 step-1 commits merged (PR #316). There is also an **unmerged branch `docs/github-issues-cleanup`** with one commit (`2c35476`) — see Task 3. Start from `main`, and check whether `2c35476` has landed before assuming the file contents below.

**Release timing context** *(corrected 2026-08-03)*: Fabio's local Xcode 27 beta can't produce a submittable binary, but that doesn't gate the release — Apple's floor is **Xcode 26 / iOS 26 SDK**, which GitHub Actions `macos-26` runners already have. The release path is CI, not his laptop; see [`FAB-150-step3-ci-release-pipeline.md`](FAB-150-step3-ci-release-pipeline.md). Either way it does not affect any task in this plan.

---

## Task 1 — Fix the UserDefaults reason codes (the actual defect)

### What's wrong

Both manifests declare `CA92.1` for `NSPrivacyAccessedAPICategoryUserDefaults`. Apple defines that code as accessing user defaults *"that is only accessible to the app itself."*

Verso doesn't do that at the boundary that matters. Every bookmark read/write goes through an **App Group** suite:

- `Verso/Shared/LibraryBookmarkResolver.swift:10` — `UserDefaults(suiteName: AppConstants.appGroupID)`
- `Verso/Sources/Services/FolderBookmarkService.swift:5,10` — `private static let suiteName = AppConstants.appGroupID`

The correct code for app-group access is **`1C8F.1`** — *"accessible to the apps, app extensions, and App Clips that are members of the same App Group."*

### The two targets need different fixes — they are not the same edit

**`Verso/ShareExtension/Resources/PrivacyInfo.xcprivacy` — replace, don't add.**

The extension's source list is `ShareExtension/Sources`, `Generated`, `Shared`. A grep across exactly those three paths finds precisely one UserDefaults call site: `Shared/LibraryBookmarkResolver.swift:10`, which is app-group. There is **no** `UserDefaults.standard` anywhere in the extension's sources.

So `CA92.1` is not merely incomplete here — it describes access the extension never performs. Replace it with `1C8F.1` as the sole reason.

**`Verso/Resources/PrivacyInfo.xcprivacy` — add, don't replace.**

The app genuinely does both. `UserDefaults.standard` appears in `Sources/Design/ThemeManager.swift`, `Sources/App/VersoApp.swift`, and `Sources/Services/ReadingPreferencesService.swift` (among others), while `FolderBookmarkService` uses the app-group suite. Both reasons are true, so the `NSPrivacyAccessedAPITypeReasons` array holds both:

```xml
<array>
    <string>CA92.1</string>
    <string>1C8F.1</string>
</array>
```

### Re-audit rather than trusting the above

The step-1 audit was careful and still landed on the wrong code — it correctly noticed `LibraryBookmarkResolver` compiles into both targets, then classified it under the app-only reason anyway. So don't take this plan's word for it either. Re-run the grep yourself, per target, scoped to each target's real `sources` list in `project.yml`:

```bash
cd Verso
grep -rn "UserDefaults" ShareExtension/Sources Shared Generated   # extension's world
grep -rn "UserDefaults" Sources/                                   # app's world
```

For every hit, check whether it's `.standard` or `(suiteName:)` before assigning a code. Report the call-site inventory you built, not just the conclusion.

`NSPrivacyAccessedAPICategoryFileTimestamp` / `C617.1` on the app target was checked and is correct — `MarkdownReader.swift:135-137` reads `.creationDate` on a file from the user's selected folder, and the value isn't surfaced in UI. Leave it alone.

### Verify

Rebuild and confirm the manifests in the built products actually changed — a stale copy in `Copy Bundle Resources` would be invisible in source:

```bash
find ~/Library/Developer/Xcode/DerivedData -path "*Verso.app*" -name "PrivacyInfo.xcprivacy" \
  -exec echo "--- {}" \; -exec plutil -p {} \;
```

Expect two hits, with the app showing both codes and the extension showing only `1C8F.1`.

**Commit:** `fix: correct UserDefaults privacy manifest reason codes to 1C8F.1 for app-group access (FAB-150)`

---

## Task 2 — Un-stale `docs/PROJECT_STATUS.md`

`2c35476` bumped this file's date to `2026-08-03` and appended a GitHub housekeeping section, but left the **"🔲 Remaining (iOS)"** list untouched. That list still names work that shipped in `d560482` ("feat: Phase 2 — tags, scroll cache, Core Data search, bulk actions").

This is worse than ordinary staleness: the old `2026-06-15` date signalled "don't trust this," and the new date removes that signal while the content stays wrong. It matters specifically because App Store description and metadata copy tend to get written from this file.

**Verify each of the five bullets against the code and `DONE.md` before editing** — don't assume all five shipped:

- Wiring screens to live data via the services layer
- iCloud Drive folder picker integration end-to-end
- Auto-status progression on scroll (unread → reading → read)
- Search functionality (title-only MVP)
- Core Data read cache sync

Useful evidence: `Verso/Sources/Services/` (`ArticleLibraryService`, `FolderBookmarkService`, `ICloudFileWatcher`), `docs/DONE.md`, and `git log --oneline -- Verso/Sources`. Move what's done into the "✅ Done" section with the same level of detail as its neighbours; keep anything genuinely outstanding in the 🔲 list.

While here, check the **Web** section against the same standard — `2c35476`'s HANDOFF edit asserts "Phases 1–3 (FAB-165 through FAB-170) are done," but PROJECT_STATUS still says only Phase 1 is complete and "Phase 2 not yet scoped." Those two statements can't both be true. Reconcile them against `DONE.md` and fix whichever is wrong.

**Commit:** `docs: reconcile PROJECT_STATUS iOS and Web status with shipped work`

---

## Task 3 — Land the GitHub cleanup without implying GitHub is a tracker

### Settled: `docs/BACKLOG.md` is the tracker of record. GitHub Issues is not a tracker.

This is **not an open question** — `AGENTS.md` already says so and it stands. The `docs/github-issues-cleanup` work was one-time housekeeping on leftovers from the Linear→GitHub migration (issues from unrelated projects — Deriva, Solfa, FLUX, Penumbra — sitting in `verso-app`). It was tidying, not the adoption of a second tracker. Do not propose migrating to GitHub Issues, and do not add sync rules between the two.

### 3a. Move the housekeeping log out of `PROJECT_STATUS.md`

`2c35476` appended a **"GitHub Issues Housekeeping — 2026-08-03"** section to `docs/PROJECT_STATUS.md`. That's the wrong home for it on two counts from `AGENTS.md`: `PROJECT_STATUS.md` is "the only place project status lives," and a one-time repo-admin log isn't project status — it's a completed chore. Left there, it also reads as evidence that GitHub Issues is something the project actively maintains.

Move that section into `docs/DONE.md` as a dated completed entry, matching the surrounding format. Keep the substance (98 issues transferred out, 1 test issue closed, 7 closed to match `DONE.md`, FAB-150 reopened) — it's a useful record of *why* the issue counts changed, just not under "status."

### 3b. Keep the HANDOFF fix

The other half of `2c35476` corrects HANDOFF's stale "FAB-166 through FAB-174" web roadmap range. That's a genuine fix — keep it, but make sure it agrees with whatever Task 2 concludes about Web phase status. If Task 2 finds the Web section says something different, they must end up consistent.

### 3c. Add a one-line note so this doesn't recur

In `AGENTS.md`, alongside the existing "Issue Tracker: `docs/BACKLOG.md`" line, note that **GitHub Issues on `whysasse/verso-app` is not a tracker and is not kept in sync** — it's a migration artifact. One sentence. This exists so a future contributor or agent doesn't discover 174 issues and assume they're authoritative, or "helpfully" start reconciling them again.

### 3d. Land the branch

Rework `docs/github-issues-cleanup` (`2c35476`) per 3a–3c and merge it, or cherry-pick the reworked content onto this plan's branch and delete it. Either way, don't leave it dangling.

### Note on the auto-close

FAB-150 was auto-closed when its step-1 PR merged, and had to be reopened. Cause: a `Closes #NNN` / `Fixes #NNN` keyword in the PR body. For long-lived parent checklists like FAB-150, use `Refs #NNN` instead. Worth a line in `AGENTS.md`'s backlog-hygiene section if it fits naturally; don't force it.

---

## Explicitly out of scope

**Do not attempt TestFlight, archive, or submission steps in this plan, and do not propose changing Fabio's local Xcode.**

Fabio's machine builds with **Xcode 27.0 beta (Swift 6.4)**, and App Store Connect doesn't accept beta-toolchain builds. He runs the **macOS 27 public preview**, so no earlier Xcode installs locally. Don't suggest downgrading macOS or sourcing an older Xcode.

> **Correction (2026-08-03):** this section previously concluded that Verso therefore ships after **Xcode 27 GA**. That was wrong — Apple's floor is **Xcode 26 / iOS 26 SDK**, and GitHub Actions `macos-26` runners have it, so releases can be built in CI. See [`FAB-150-step3-ci-release-pipeline.md`](FAB-150-step3-ci-release-pipeline.md). The local constraint stands; the timing conclusion drawn from it did not.

Release-pipeline work belongs in step 3, not here. Local archiving to verify configuration still works — it just can't produce a submittable binary.

**Leave the SwiftSoup floor at `2.13.7`.** The bump (`011122c`) works around a Swift 6.4 compiler regression, and Swift 6.4 is the toolchain this project will be on until GA and likely after. Re-evaluating it belongs at GA, once it's known whether the upstream fix (swiftlang/swift#90408, revert PR scinfu/SwiftSoup#403) has landed in the shipping compiler. Not now, and not as part of this plan.

---

## Commit strategy

Four to five commits: Task 1, Task 2, then Task 3's rework of `2c35476`. Tasks 1 and 2 are independent of each other; Task 3's HANDOFF edit depends on Task 2's conclusion about Web phase status, so do Task 2 first.

Nothing here needs Fabio's sign-off mid-flight. Report at the end.
