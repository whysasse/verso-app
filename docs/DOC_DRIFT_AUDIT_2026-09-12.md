# Doc Drift Audit — 2026-09-12

**Version:** 1.0 · **Date:** 2026-09-12 · **Status:** Active

A cross-document fact-drift audit of Verso's `docs/` corpus, prompted by
three unrelated drifts turning up by accident in one day (this session's
own PR descriptions never reaching `docs/BACKLOG.md`; `docs/OBSIDIAN_INTEGRATION.md`
almost getting duplicated; `AGENTS.md`/`CLAUDE.md` independently restating
the same two facts). Three coincidences in one day argued for actually
looking, rather than assuming it was bad luck.

## Method

An earlier pass (same day) found `docs/DOCS_CLEANUP_PLAN_2026-06-12.md` and
4 completed per-issue working docs as archive candidates via orphan-doc
detection (referenced nowhere else) — that work is done and merged
(#400, #401). This audit is the follow-up it flagged as out of scope:
actually reading doc content for restated or contradicting *facts*, not
just checking whether a whole doc is still referenced.

Five parallel passes, one per doc cluster, each instructed to read its
docs in full, cross-reference specific checkable claims (not vague
thematic overlap), and verify against shipped code / `docs/BACKLOG.md` /
`docs/DONE.md` wherever cheap to do so rather than trusting the docs'
own claims about themselves:

1. Design system & tokens (8 docs + `AGENTS.md`'s Swift-identifiers
   section + `verso-web/app/globals.css`)
2. Product & UX flows (9 docs)
3. Process & project state (`AGENTS.md`, `CLAUDE.md`, `HANDOFF.md`,
   `PROJECT_STATUS.md`, `DECISIONS.md`, `FRICTION.md`, `PENDING_TESTS.md`)
4. Platform & integration (Obsidian sync, analytics, localization — 4+ docs)
5. Release & critique (App Store listings, `DESIGN_CRITIQUE_2026-09-01.md`)

`docs/BACKLOG.md` and `docs/DONE.md` were not read in full (66KB / 285KB)
— each pass targeted-grepped them only for the specific facts it needed
to verify.

**Result:** ~20 real contradictions, a dozen-plus facts restated in 2+
places without contradiction yet (drift risk), and one doc confirmed as a
further archive candidate — out of roughly 30 docs checked.

---

## A. Documented but no longer true — shipped changes the docs never caught up to

### A1. Filter-chip status bar — described as live in 7 docs, deleted 5 months ago
**Severity: high.** `FilterChipBar.swift` and `FilterChip.swift` were
**deleted** per FAB-292 (`docs/DONE.md:1737-1740`, done 2026-08-29):
*"Sections replace the status chip bar... groups client-side into
Continue Reading, Unread, Read (collapsed), Archived (collapsed)...
Removed: `FilterChipBar.swift`, `FilterChip.swift`."*

Still described as live, in near-identical language, in:
- `docs/PRD_MinimalistReaderApp.md:92`
- `docs/site-map.md:100`
- `docs/feature-priority-per-screen.md:75`
- `docs/interactions-and-gestures.md:43`
- `docs/component-inventory.md:68-86` (§1.3 — full spec: height, padding,
  chip order, default state)
- `docs/FIGMA_DESIGN_SYSTEM_REFERENCE.md:225-251` (§4.4, plus its
  Components-page table at `:288`)
- `docs/DESIGN_TOKENS.md` cites "filter chip" as a live use case for
  `textSecondary` (`:79`), `accent` (`:95`), and `accentSurface` (`:127`)

`docs/COMPONENT_SPECS.md:101` is the one doc that correctly documents the
removal — so the corpus currently disagrees with itself about whether
this component exists, 7 docs to 1.
`AGENTS.md:30` also still lists "Filter chips: All / Unread / Reading /
Read. Visible even on empty states" as a current architecture fact.

**Recommended fix:** update all 7 to reflect the section-based UI; remove
the chip-count reference in `AGENTS.md`'s Architecture section.

### A2. Reading View — Share button, top bar composition, search MVP framing
**Severity: medium.**
- `docs/site-map.md:116` and `docs/feature-priority-per-screen.md:109`
  both say Share is out of scope / post-MVP for the Reading View.
  `docs/PRD_MinimalistReaderApp.md:227` says it's a persistent bottom
  control. Per `docs/DONE.md:1050` (FAB-299, done 2026-08-31), Share
  shipped — but inside the `⋯` overflow menu, matching neither doc's
  framing exactly.
- `docs/PRD_MinimalistReaderApp.md` §5.1 and `docs/site-map.md` both
  describe the Reading View top bar as "article title, source, date
  saved." Per FAB-299 (`docs/DONE.md:1049-1050`), the actual top bar is
  `← Back | Title | ⋯` — source/date aren't shown there.
- `docs/PRD_MinimalistReaderApp.md:95` and
  `docs/feature-priority-per-screen.md:76,83` both frame full-text body
  search as post-MVP / not yet built. `docs/user-flows.md:87` and
  `docs/site-map.md:100` already describe the shipped behavior
  (title+body) but without noting it as a later addition. Per
  `docs/DONE.md:1757-1773`, FAB-50 (full-text body search) is done —
  the post-MVP framing is simply stale now, not wrong when written.

**Recommended fix:** a documentation refresh pass on the PRD/UX docs'
per-screen feature tables against current `DONE.md` state — batched as
one task rather than one FAB per stale line.

### A3. Reading time and highlighting outgrew their "nice to have" framing
**Severity: low.** `docs/PRD_MinimalistReaderApp.md` §4.3 lists both as
Priority 3 polish. Per `docs/DONE.md`, reading-time estimates (FAB-55) now
replace the save-date on article cards entirely (a bigger role than
"nice to have" implies, per the FAB-292 change), and highlighting
(FAB-54, FAB-303) shipped with cross-block selection — but none of
`site-map.md`, `feature-priority-per-screen.md`, or
`interactions-and-gestures.md` were updated to reflect either now
existing in the shipped reading-view menu.

---

## B. Docs disagree with each other on values that should have one answer

### B1. `error` token — see widened **FAB-339** in `docs/BACKLOG.md`
Wrong in `verso-web/app/globals.css` and 3 more docs
(`DESIGN_SYSTEM_FOUNDATIONS.md`, `FIGMA_DESIGN_SYSTEM_REFERENCE.md`,
`ERROR_STATES_SPEC.md`) — all still show the pre-FAB-336 `#C0392B` for
Paper/Sepia instead of `#AD3327`. Already filed; widened same day this
audit ran.

### B2. Archive subfolder name — three spellings, none agreeing
**Severity: medium.**
- `docs/user-flows.md:97` — `/Archived` (capital A, leading slash)
- `docs/interactions-and-gestures.md:39` — `` `/archived/` `` (lowercase,
  both slashes)
- Actual implementation, per `docs/DONE.md:992,1101,1125` — `Archive/`
  (capital A, no trailing "d", no leading slash)

Three different strings for the same folder, across 2 docs and the code.

**Recommended fix:** correct both docs to `Archive/`.

### B3. `type.ui.input` line-height — `1.0×` vs `1.3×`
**Severity: low.** `docs/DESIGN_TOKENS.md:363` says `1.0×`;
`docs/FIGMA_DESIGN_SYSTEM_REFERENCE.md:104` says `1.3×` for the identical
token — every other UI type style in both tables matches exactly, only
`input` diverges. `verso-web/app/globals.css:57`
(`--type-ui-input-line-height: 1;`) agrees with `DESIGN_TOKENS.md`, so the
Figma doc is the outlier.

**Recommended fix:** correct `FIGMA_DESIGN_SYSTEM_REFERENCE.md:104` to
`1.0×`.

### B4. `AGENTS.md`'s "Folders" section and "Docs Reference" table describe a structure that doesn't exist
**Severity: high.** `ls docs/` is flat — no `product/`, `design/`, or
`engineering/` subfolders (real subdirs: `_archive/`, `copy/`,
`figma-plugin/`, `plans/`, `printscreens/`, `wireframes/`).

`AGENTS.md`'s "Folders" line still asserts that three-way split exists,
and its Docs Reference table builds paths on that false premise —
`docs/design/COMPONENT_SPECS.md`, `docs/design/DESIGN_TOKENS.md`,
`docs/product/user-flows.md`, etc. — none of which resolve. The real
files sit flat. This isn't just stale against the filesystem — it
disagrees with `docs/HANDOFF.md`'s own doc map (lines 197-209), which
uses the correct flat paths for the identical set of files. A session
trusting `AGENTS.md`'s table over `HANDOFF.md`'s will fetch nonexistent
files.

**Recommended fix:** rewrite `AGENTS.md`'s Folders line and Docs
Reference table to match `HANDOFF.md`'s (correct) flat paths.

### B5. `color/divider` — referenced twice, never actually defined
**Severity: low.** `docs/FIGMA_DESIGN_SYSTEM_REFERENCE.md` defines the
border token as `color/border` (`:38`), but references a nonexistent
`color/divider` at `:194` and `:265`. `docs/component-inventory.md` does
the same under a display name (`:261`, `:637` say "Divider" where it
means `border`) — inconsistent even with its own other border references
(`:363-366` call it "Border"). `docs/DESIGN_TOKENS.md` has no token named
anything like "divider." Looks like a leftover from an old token name —
`DESIGN_SYSTEM_FOUNDATIONS.md:375`'s changelog mentions "Divider" from
2026-04-20, never fully renamed across docs since.

**Recommended fix:** replace all "Divider" / `color/divider` references
with `border` / `color/border`.

### B6. `docs/HANDOFF.md`'s `ArticleStatus` is stale, and reintroduces a symbol `AGENTS.md` explicitly warns against
**Severity: high.** Ground truth, `Verso/Shared/Colors.swift:149-153`:
4 cases (`unread, reading, read, archived`) — matches `AGENTS.md:89-96`
exactly, including the FAB-287 note and FAB-325's theme-aware badge
colors.

`docs/HANDOFF.md:87` shows only 3 cases (`unread, reading, read`) — no
`archived`. Worse, `HANDOFF.md:92` lists the SF Symbol for "reading" as
`book.open`, which `AGENTS.md:94` explicitly flags: *"(`book.open` is not
a real SF Symbol — don't reintroduce it.)"* `HANDOFF.md` also shows only
3 badge colors and predates the FAB-325 theme-aware change `AGENTS.md`
documents.

Since `HANDOFF.md` bills itself *"the authoritative entry point... read
this file first"* (`HANDOFF.md:5`, `AGENTS.md:17`), a session following
the stated reading order gets the wrong version first.

**Recommended fix:** update `HANDOFF.md`'s Article Status section to
match `AGENTS.md`'s (4 cases, correct symbols, theme-aware badges), or
better — replace it with a pointer to `AGENTS.md`'s section, the same
direction already used for `## Things Claude gets wrong` in `CLAUDE.md`.

---

## C. Shipped but undocumented

### C1. Two analytics events have shipped values missing from the documented enum; a third event is undocumented entirely
**Severity: medium.**
- `docs/ANALYTICS_STRATEGY.md:52` documents `onboarding.stepCompleted`'s
  `step` as a closed enum: `"welcome" | "folder_picker" | "done"`.
  `Verso/Sources/Screens/Onboarding/OnboardingFlowView.swift:24` sends a
  fourth value, `"theme_picker"` — not in the doc, not in `DONE.md`'s copy
  of the catalog either (`docs/DONE.md:2981`).
- `docs/ANALYTICS_STRATEGY.md:48` documents `article.saved`'s
  `duplicate_resolution` as `"none" | "update" | "copy"`.
  `Verso/Sources/Services/PendingArticleIngester.swift:67-70` sends a
  fourth value, `"backstop_flagged"`. Notably, `docs/DONE.md:1103`
  *does* record this addition — the drift was written down once, in the
  wrong place, and the canonical strategy doc was never updated to match.
- `Verso/Sources/Services/LocaleManager.swift:37` tracks
  `settings.languageChanged`, wired since FAB-284. It appears in zero
  docs — not `ANALYTICS_STRATEGY.md`'s catalog, not `DONE.md`'s FAB-284
  entry, nowhere.

**Recommended fix:** update `ANALYTICS_STRATEGY.md`'s event catalog for
all three.

### C2. PRD still describes frontmatter-error behavior that FAB-290 explicitly retired
**Severity: medium.** `docs/PRD_MinimalistReaderApp.md:473` (v1.7,
2026-05-10): *"invalid frontmatter → skip file with warning."*
`docs/OBSIDIAN_INTEGRATION.md` §9 (v2.1, 2026-08-24) directly contradicts
this — its own changelog (line 247) records that FAB-290 replaced exactly
this behavior with graceful adoption (whole file becomes the article
body; no skip-file branch anymore). The PRD's §14 even links to
`OBSIDIAN_INTEGRATION.md` as "the" spec, but wasn't updated when FAB-290
shipped.

**Recommended fix:** update PRD §14.4, or trim it to a pointer at
`OBSIDIAN_INTEGRATION.md` (the doc that actually keeps a live "Document
History" table and is the one built to stay current).

---

## D. Self-contradicting within one doc

### D1. `animation-spec.md` disagrees with its own code sample, twice
**Severity: low.** Global Timing Tokens table (`:16`):
`VersoAnimation.normal` = easeInOut, 250ms. §4a (`:131`) describes the
same transition as "250ms **easeOut**," then the code sample two lines
below (`:140`) calls `withAnimation(VersoAnimation.normal)` — the
easeInOut token. §4b repeats the pattern (`:150` says "300ms easeOut,"
the code at `:157` again invokes the 250ms easeInOut token). Also: the
widely-repeated chrome-fade timing (300ms/200ms — consistent across 4
other docs, see restated-but-consistent below) matches none of
`animation-spec.md`'s own 4 named tokens, despite the doc's closing note
(`:170`) that they "should be the single source of truth."

**Recommended fix:** reconcile the prose/table with the actual code in
both places, and either name a token for the 300ms/200ms chrome fade or
flag it as an intentional hardcoded exception.

---

## E. Rule violations — mechanically checkable, nothing currently catches them

### E1. `ERROR_STATES_SPEC.md` uses a semantic token as a large fill background
**Severity: medium.** `docs/DESIGN_TOKENS.md:176`: *"Usage constraint for
all semantic tokens: text tints and border colors only. Never as large
fill backgrounds."* `docs/ERROR_STATES_SPEC.md:49` specs the offline
banner's background as *"`warning` token at 10% opacity"* — a full-width
background fill, which the rule forbids. There's no dedicated
`warningSurface`/`errorSurface` token (analogous to `accentSurface`) to
license this. Scenario 5 (`:145`) repeats the same pattern with `error`.

**This one needs a decision, not just a doc fix:** either the rule is
wrong for banners specifically (add `warningSurface`/`errorSurface`
tokens), or the banner spec is wrong and needs a different background.
Flagging for your call rather than picking one.

### E2. Error-state CTA buttons use a different corner radius than every other 50pt button
**Severity: low.** `docs/COMPONENT_SPECS.md:762-763` (and
`SecondaryButton`/`SaveButton`): height 50pt → `radius/md` (12pt),
consistently. `docs/ERROR_STATES_SPEC.md:78-81,104`: "height 50pt, corner
radius `pill` (20pt)." A 20pt radius on a 50pt element isn't even a true
pill by the system's own logic (`radius/pill` is documented elsewhere as
fully rounding a *40pt*-tall element — itself possibly stale, see F1
below).

**Recommended fix:** pick one — most likely `radius/md` to match every
other button — and correct `ERROR_STATES_SPEC.md`.

### E3. Doc-header format — `HANDOFF.md` and `PROJECT_STATUS.md` don't comply with `AGENTS.md`'s own rule
**Severity: low, pre-existing.** `AGENTS.md:148`: every doc's Status must
be one of `Draft`/`Active`/`Locked`/`Archived`. `HANDOFF.md:3` uses
"Ready for development" instead. `PROJECT_STATUS.md:3` has no `Status:`
field at all, and relabels `Version` as `PRD Version`. Both predate the
2026-09-11 `CLAUDE.md` rewrite, so this isn't new drift — but it's a
live, mechanically-checkable violation nothing currently catches
(`scripts/check.sh` only enforces the header's *presence* on new docs,
not its Status vocabulary).

**Recommended fix:** correct both headers; consider adding a Status-value
check to `scripts/checks/check-doc-headers.sh`.

### E4. Status-ownership rule undercut by `HANDOFF.md` itself
**Severity: low, currently harmless.** `AGENTS.md:143`: *"PROJECT_STATUS.md
is the only place project status lives... link to it instead."*
`HANDOFF.md:7,58` restates status directly anyway. The numbers currently
agree with `PROJECT_STATUS.md` — no contradiction today — but this is
exactly the two-owners setup that produced B6 above. Note `AGENTS.md:5`
itself ("Currently in active implementation") does the same thing, by
the rule's own author.

**Recommended fix:** replace both restatements with a link, per the
rule's own logic.

---

## F. Restated-but-consistent — no contradiction today, no single source of truth

Listed for awareness, not action — each one agrees across every place it
appears, right now:

- **Locale set** (en / en-CA / fr-CA / pt-BR) — restated consistently
  across ~10 places (`LOCALIZATION.md`, `copy/UI_COPY.md`,
  `PROJECT_STATUS.md`, `BACKLOG.md`, `HANDOFF.md`,
  `APP_STORE_LISTING_LOCALIZED.md`, a plans doc, codegen, `LocaleProvider.tsx`,
  `LocaleManager.swift`'s `AppLocale` enum).
- **Last-write-wins conflict rule** — identical in `OBSIDIAN_INTEGRATION.md`
  §8 and 4 places in the PRD. (Its sibling rule, two lines away in the
  same PRD section, is the one that drifted — see C2.)
- **CLDR plural quirk** (fr-CA 0=singular, pt-BR 0=plural) — consistent
  across `LOCALIZATION.md`, `copy/UI_COPY.md`, codegen comments,
  `DONE.md`, and an archived doc.
- **NSMetadataQuery as the Obsidian change-detection mechanism** —
  consistent across `OBSIDIAN_INTEGRATION.md`, the PRD (×2), `DONE.md`.
- **ArticleCard and ReadingControls sheet dimensions** — duplicated
  verbatim between `COMPONENT_SPECS.md` and `component-inventory.md`,
  despite each doc's own header claiming the *other* owns that
  information.
- **Chrome hide/reveal timing** (300ms ease-out / 200ms ease-in) —
  consistent across 4 docs, but matches none of `animation-spec.md`'s own
  named tokens (see D1).
- **`radius/lg` = 18pt fully rounds a 36pt chip** — consistent across 2
  docs, but three independent restatements of a derived fact.
- **Analytics App ID** — appears *only* in `AGENTS.md:133`.
  `ANALYTICS_STRATEGY.md` never states one. Actually single-sourced,
  contrary to what might be expected — no drift risk here.

---

## G. Judgment call, not a fact-check

### G1. Is `CLAUDE.md`'s conditional pointer to `AGENTS.md` an adequate replacement for the old `@AGENTS.md` auto-include?
Before 2026-09-11, every session got all of `AGENTS.md` for free.
`CLAUDE.md`'s `## Conventions` now says "Read AGENTS.md before touching
iOS or design-system code" — a conditional trigger. That trigger covers
`AGENTS.md`'s SwiftUI-Gotchas/Design-System content fine (a session doing
that work is likely to trip it). It does **not** cover `AGENTS.md`'s
Documentation Rules section (docs-location, header format,
status-ownership, backlog hygiene, archival, naming) — none of that is
"iOS or design-system code," so a pure docs/backlog session now has no
stated reason to ever open `AGENTS.md` and see those rules, where it used
to get them automatically.

Two fix directions, not mutually exclusive:
1. Broaden `CLAUDE.md`'s pointer to also trigger on doc/backlog changes.
2. Move the Documentation Rules section's substance into `CLAUDE.md`'s
   own `## Workflow` — the same move already made for the
   backlog-move-to-DONE and `Refs`/`Closes` rules.

Not resolved here — this is a `docs/DECISIONS.md`-worthy call, not a
mechanical fix.

---

## H. Archive candidate found by this pass

### H1. `docs/DESIGN_CRITIQUE_2026-09-01.md`
Sampled 11 of its FAB-numbered findings (304, 307, 308, 309, 315, 317,
320, 330, 331, 332, 333) against `BACKLOG.md`/`DONE.md`: 10 are `Done`
with implementation notes that directly refute the critique's original
"broken" claims. The 11th (FAB-320) isn't neglected either — `BACKLOG.md`
shows it deliberately rerouted into FAB-334 (the native-shell epic),
because that rewrite deletes the custom chrome the finding was about.
The doc already carries inline retractions in places (§6.1, §6.11, §7.3)
acknowledging some findings are stale. Same evidence bar as the 5 docs
already archived earlier today (#400, #401) — not archived as part of
this audit, since that's a distinct action from writing the audit down.

---

## BACKLOG filing status

Every finding above with a **Recommended fix** was a candidate for its
own FAB entry (or, for A1–A3, one batched documentation-refresh entry
rather than one per stale line) — filing was a separate decision from
writing the audit down, made after review:

- **Filed as BACKLOG entries:** B1 (widened FAB-339), B2 (FAB-341), B3
  (FAB-342), B5 (FAB-343), E3 (FAB-344), C1 (FAB-345), C2 (FAB-346), D1
  (FAB-347) — every finding with one clear answer and no judgment call
  attached.
- **Fixed directly, no FAB needed** (small enough to just do once decided):
  B4 and B6 (both missed when the mechanical batch above was filed —
  fixed alongside G1 in the same PR, since all three touch
  `AGENTS.md`/`CLAUDE.md`/`HANDOFF.md`); E2 (Fabio's call: match
  `radius.md` — fixed in `docs/ERROR_STATES_SPEC.md`).
- **Decided, not yet done:** E1 (Fabio's call: formalize
  `warningSurface`/`errorSurface` tokens); A1–A3 (Fabio's call: mark the
  PRD historical, batch-refresh `site-map.md`/`feature-priority-per-screen.md`/
  `interactions-and-gestures.md`).
- **Resolved:** G1 — moved into `CLAUDE.md`'s `## Workflow` directly
  (not just a broadened pointer).
