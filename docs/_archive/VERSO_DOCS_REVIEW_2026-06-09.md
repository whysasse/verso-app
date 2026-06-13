> 🗄️ **ARCHIVED 2026-06-12.** Point-in-time review. Actionable items carried into `DOCS_CLEANUP_PLAN_2026-06-12.md`. Kept for history; do not implement from this document.

# Verso — Documentation Review & Localization Plan

**Reviewer:** Claude · **Date:** 2026-06-09 · **Scope:** `docs/`, root `README.md`, `CLAUDE.md`, `HANDOFF.md`
**Status:** Suggestions only — no files changed.

This report has two parts: (1) improvements to the existing documentation, and (2) a plan to localize Verso into **EN-CA, FR-CA, and PT-BR**.

---

## Part 1 — Documentation improvements

The doc set is genuinely strong: `HANDOFF.md` as a thin index, `UI_COPY.md` keyed and plural-flagged, `DESIGN_TOKENS.md` with WCAG rationale, and a real cross-artefact audit. The issues below are mostly *drift* — places where docs disagree with each other or with reality — not gaps in thinking.

### 1.1 Version & status drift (highest priority)

There's no single source of truth for "where is the project and what version is each doc," so the headers have quietly diverged:

| Doc | Says | Problem |
|---|---|---|
| Root `README.md` | "Currently in design/discovery phase" | Contradicts everything else — implementation is underway. Stale. |
| `PRD` top matter | **Version 1.7** | The doc-history table stops at **1.6** (2026-05-02). v1.7 has no changelog entry — you can't tell what changed. |
| `HANDOFF.md` | v1.1, 2026-05-20 | Fine, but carries its own version unrelated to PRD's. |
| `PROJECT_STATUS.md` | "PRD Version 1.7", 2026-06-05 | The only doc that's current. |

**Why it matters:** the project instructions tell every AI agent to "read `HANDOFF.md` first." If the docs it points to carry contradictory versions and a stale README sits at the repo root, an agent (or a new collaborator) gets conflicting signals on day one.

**Recommendation:** Pick `PROJECT_STATUS.md` as the canonical "current state" doc and have every other doc defer to it rather than restating status. Update the root `README.md` one-liner. Add the missing PRD v1.7 changelog row (or revert the header to 1.6 if nothing actually changed).

### 1.2 Unfilled placeholders shipped into "source of truth" docs

`[AppName]` and `[Your Name]` survive in several places even though the app was named **Verso** back in PRD v1.4:

- `PRD §3` use cases: *"Taps share → selects 'Save to [AppName]'"* and *"Selects '[AppName]'"* → should read **Save to Verso**.
- `PRD` owner field and the entire doc-history "Author" column: **[Your Name]**.
- `ERROR_STATES_SPEC.md` / `UI_COPY.md` iCloud error: *"Go to Settings → [Your Name] → iCloud"*. This one is **intentional** — `[Your Name]` is Apple's own label for the device-owner row in iOS Settings. But it reads identically to the unfilled placeholders, so it's worth a one-line note in the copy so a translator doesn't "fix" it. (See 2.6.)

### 1.3 `00-Plan-V2-CBDS.md` contradicts the locked design

This doc proposes a "Context-Based Design System" — time-of-day adaptive themes (Morning/Day/Evening), haptic tokens, opacity that hides metadata at night, and a literary "quote bank" that interrupts the user on context switch. It directly contradicts decisions the rest of the docs treat as settled:

- **4 static themes** (Paper/Sepia/Night/Ink), not time-driven vibes.
- **Static font family** (a stated project constraint) — CBDS keeps the family but rewrites spacing/line-height dynamically.
- **Minimalism** ("no stats, no discovery, gets out of your way") — an interrupting quote dialog is the opposite of that principle.

It also references `design-system.md`, which doesn't exist in the repo.

**Recommendation:** This is either a future exploration or an abandoned branch — either way it shouldn't sit unlabeled at the top of `docs/` (the `00-` prefix makes it sort *first*). Move it to a `docs/explorations/` folder with a status banner ("Exploratory — not adopted; conflicts with current locked design"), or delete it. As-is it's a trap for any agent that reads docs alphabetically.

### 1.4 The 2026-05-02 audit is stale and partly unexecuted

`AUDIT_2026-05-02.md` is excellent work, but it's now a ~5-week-old snapshot with no "done" markers. Spot-checking its execution plan: it scheduled deletion of `COMPONENTS.md` redundancy — both `COMPONENTS.md` (v1.0, Apr 22) and `component-inventory.md` (v1.4, May 2) still exist and overlap heavily. The audit's "32 → 22 files" target wasn't fully reached.

**Recommendation:** Either tick off completed items in the audit doc, or close it out and move remaining open items into Linear (which the audit itself calls the source of truth). A long-lived audit doc that's part-done is itself a drift source. Also resolve the `COMPONENTS.md` vs `component-inventory.md` redundancy — keep the v1.4 inventory, retire the v1.0 one.

### 1.5 `UI_COPY.md` is iOS-only but you now ship Web too

The file opens "All user-visible text strings for the **Verso iOS app**." The web platform (`verso-web/`) is now an active track in the same `HANDOFF.md`, but there's no copy source for it. Right now the two platforms will drift in wording the same way tokens would have without `DESIGN_TOKENS.md`.

**Recommendation:** Promote `UI_COPY.md` to platform-neutral and make it the single copy source for iOS *and* Web (the keys already read like a shared namespace). This also sets you up cleanly for Part 2.

### 1.6 Minor

- **Date/number formatting is hardcoded.** `UI_COPY.md` §3 instructs `MMM d, yyyy` "at code level, no key needed." That's a localization bug waiting to happen (see 2.5) — flag it now even before translating.
- **Reading-time WPM** isn't documented anywhere (`{N} min read`). Worth pinning the constant in a spec, since it interacts with localization (2.5).
- **`docs/research/` is empty** — remove or populate.

---

## Part 2 — Localization to EN-CA, FR-CA, PT-BR

Good news: the groundwork is unusually solid. `UI_COPY.md` already uses stable keys, flags plurals with ⚠️, and even marks one string "invariant — do not localise." You're closer to localization-ready than most apps at this stage. The plan below covers strategy, mechanics on both platforms, and the linguistic edge cases specific to these three locales.

### 2.1 Locale strategy & fallback

| Locale | Role | Notes |
|---|---|---|
| `en` | Development base | Your copy already uses Canadian spelling ("acknowledgements"), so base ≈ EN-CA. |
| `en-CA` | Likely **not needed as a separate bundle** | Verso's copy has almost no US/CA spelling divergence. Don't fork it unless a specific string demands it; let `en-CA` fall back to `en`. This saves a whole translation column. |
| `fr-CA` | Full translation | Québec French, not France French ("courriel" conventions, "magasiner", etc. — though Verso's vocabulary is mostly neutral). |
| `pt-BR` | Full translation | Brazilian Portuguese. |

All three are left-to-right — **no RTL work**, which removes the biggest layout risk.

**Recommendation:** Ship `en` as base, add `fr-CA` and `pt-BR` as full locales, and treat `en-CA` as an alias of `en` until a real divergence appears. Document this decision so nobody later creates an empty `en-CA` bundle "for completeness."

### 2.2 Keep one copy source feeding both platforms

You already do this for design tokens (`DESIGN_TOKENS.md` → iOS + `globals.css`). Mirror that discipline for strings: one master keyed table → generated into each platform's format. Concretely:

- **Master:** the `UI_COPY.md` keys, extended with `en` / `fr-CA` / `pt-BR` columns (or a sibling `LOCALIZATION.md` / a `strings.json` the doc points to).
- **iOS target:** a **String Catalog (`.xcstrings`)** — the modern Xcode format. It handles plural variations natively, so it directly absorbs your ⚠️ plural flags without separate `.stringsdict` files. Prefer this over legacy `Localizable.strings`.
- **Web target:** a small dictionary keyed identically (e.g. `messages/fr-CA.json`), consumed via **`next-intl`** (clean App-Router support, ICU plural syntax). Next.js App Router doesn't ship built-in i18n routing anymore, so a library is the path of least resistance.

The win: a translator touches one place, and "iOS says 'Mark as read' but web says 'Mark read'" can never happen.

### 2.3 Plurals — the one thing that needs real care

English has 2 plural forms (one / other). **French and Portuguese differ**, and your ⚠️-flagged strings are exactly where it bites:

- `{N} min read`, `{count} articles`, `{N} minutes remaining`.
- **FR (CLDR):** category `one` covers **0 and 1** ("0 minute", "1 minute", then "2 minutes"). So *"0 articles"* must render *"0 article"* (singular) in French — English logic would get it wrong.
- **PT-BR (CLDR):** `one` = 1, `other` = everything else, but **0 is plural** ("0 artigos"). Opposite of French on the zero case.

This is precisely why `.xcstrings` / ICU plural rules matter — don't hand-roll `if count == 1`. Each language declares its own categories and the framework picks correctly. **Action:** make sure every ⚠️ string in `UI_COPY.md` becomes a plural-aware entry, not a `%lld`-with-fixed-suffix.

### 2.4 String expansion & layout

FR and PT run roughly **15–30% longer** than EN. The pressure points in Verso:

| EN | FR-CA | PT-BR |
|---|---|---|
| All / Unread / Reading / Read | Tous / Non lus / En cours / Lus | Todos / Não lidos / Lendo / Lidos |
| Get started | Commencer | Começar |
| Choose folder | Choisir un dossier | Escolher pasta |
| Mark as read | Marquer comme lu | Marcar como lido |

**Filter chips** are the highest risk — "En cours / Non lus" are noticeably wider than "Reading / Unread." Verify the `FilterChipBar` scrolls or wraps rather than truncating (tie this to `COMPONENT_SPECS.md`). Buttons and the share-sheet save states ("Saving…" → "Enregistrement…" / "Salvando…") also need flex width. **Recommendation:** add a localization line to `COMPONENT_SPECS.md` and run **pseudolocalization** (accented, +30% length) in QA before real translations land.

### 2.5 Locale-aware formatting (currently hardcoded)

Three things are content/locale-dependent and must not be hardcoded:

- **Dates** — `UI_COPY.md`'s `MMM d, yyyy` should become a locale-aware medium date (`DateFormatter.dateStyle = .medium` on iOS; `Intl.DateTimeFormat` on web). Expected output: EN "Apr 28, 2025" · FR-CA "28 avr. 2025" · PT-BR "28 de abr. de 2025". This is a bug to fix regardless of when translation happens.
- **Reading time** — `{N} min read` is computed from word count ÷ WPM. Two subtleties: (a) it's driven by the **article's** language, not the UI language (a French article in a PT-BR UI still counts French words); (b) pin a documented WPM constant. Keep it simple (single WPM is fine for MVP) but write it down.
- **TTS voice** — `TTSService` reads article *content*, so voice selection must follow the **content** language (pick a pt-BR voice for a Portuguese article), independent of UI locale. Worth an explicit note in the analytics/TTS spec.

### 2.6 Invariant terms & brand wordplay

Lock a do-not-translate list so translators don't "helpfully" localize product nouns: **Verso, Obsidian, iCloud Drive, Markdown, Safari, GitHub, OpenDyslexic**. Theme *enum keys* (`paper/sepia/night/ink`) stay in code; their *labels* are the open question:

- **Theme labels** are descriptive, so translating them reads better: Paper → *Papier* / *Papel*; Night → *Nuit* / *Noite*; Ink → *Encre* / *Tinta*; Sepia → *Sépia* / *Sépia*. `UI_COPY.md` already separates label from key, so this is free. **Recommend translating the labels.**
- **The font preview** — `"The verso is the left-hand page."` is marked "invariant — do not localise." Reconsider: a font preview's *job* is to show the typeface, and in FR/PT that means showing accented glyphs (é è à ç â / ã õ ç á ê). An English sentence with no diacritics is a weak preview for those users. **Recommend a per-locale preview** that exercises the language's accents while still nodding to the brand — e.g. FR *"Le verso est la page de gauche."* (keeps the pun *and* shows é/à/ç), PT *"O verso é a página da esquerda."* (shows ã/á/é).
- **The `[Your Name]` iCloud string** (2.2 above) is iOS's literal Settings label — annotate it "matches Apple's on-screen label, keep the device-owner placeholder" so it isn't mistranslated.

### 2.7 Font diacritic coverage — QA item

New York, Georgia, and SF Pro all cover FR/PT diacritics. **OpenDyslexic** is the one to verify — confirm it renders ç, ã, õ, â, ê, é, à, ü cleanly at all six reading sizes before you commit to it as a localized option.

### 2.8 Beyond the app: store metadata & Québec

- **App Store metadata** (name, subtitle, description, keywords, screenshots) localizes separately from in-app strings — budget for fr-CA and pt-BR store listings, not just the binary.
- **Québec / Bill 96** — since you're distributing from Montréal: Québec's French-language law requires French commercial offerings to be available and on terms "no less favourable" than English. If Verso is marketed or sold in Québec, French isn't just nice-to-have — fr-CA in-app *and* store presence is the compliant path. Worth flagging to whoever owns distribution.

### 2.9 Suggested rollout

1. Promote `UI_COPY.md` to platform-neutral and add `en` / `fr-CA` / `pt-BR` columns (or a `strings.json` it points to). Add the invariant list + plural categories.
2. Fix the hardcoded date format and document the WPM constant (2.5) — these are correctness bugs independent of translation.
3. Adopt `.xcstrings` (iOS) and `next-intl` (web), both reading the shared keys.
4. Pseudolocalize and fix layout (chips, buttons) before real strings.
5. Translate fr-CA and pt-BR; QA diacritics, plurals (esp. the 0-case), and string expansion.
6. Localize store metadata; confirm Québec posture.

---

## Priority summary

| # | Item | Effort | Impact |
|---|---|---|---|
| 1.1 | Fix version/status drift; make `PROJECT_STATUS` canonical; update root README | Low | High |
| 1.2 | Replace `[AppName]`/`[Your Name]` placeholders | Low | Med |
| 1.3 | Relocate/label `00-Plan-V2-CBDS.md` | Low | Med |
| 1.5 | Make `UI_COPY.md` platform-neutral (iOS + Web) | Low | High (unblocks i18n) |
| 2.5 | Locale-aware dates; documented WPM | Low | High (bug) |
| 2.3 | Plural-correct ⚠️ strings via `.xcstrings`/ICU | Med | High |
| 2.2 | Single shared copy source → both platforms | Med | High |
| 1.4 | Close out the May audit; resolve `COMPONENTS.md` dup | Low | Med |
| 2.4 | Layout/pseudoloc for FR/PT expansion | Med | Med |
