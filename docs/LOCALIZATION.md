# Verso — Localization (i18n) Strategy

**Version:** 1.1 · **Date:** 2026-06-09 · **Ratified:** 2026-06-17 (FAB-276) · **Status:** Signed off; implementation tracked in `docs/BACKLOG.md`

Verso ships in three locales: **EN-CA, FR-CA, PT-BR**. This doc records the decisions so iOS and Web implement i18n the same way. All user-facing strings live in `copy/UI_COPY.md` (the `en` base); this doc covers locale policy, plurals, formatting, and invariants. Implementation work is tracked under the **Localization** epic ([FAB-275](BACKLOG.md)) in `docs/BACKLOG.md` (issue tracker of record since Linear retired 2026-06-12).

---

## 1. Locales & fallback

| Locale | Role | Notes |
|---|---|---|
| `en` | Development base | Copy already uses Canadian spelling (e.g. "acknowledgements"). |
| `en-CA` | **Alias of `en`** — no separate bundle | Verso's copy has no meaningful US↔CA divergence. Do **not** create an empty `en-CA` bundle; let it fall back to `en`. Only fork if a real divergence appears. |
| `fr-CA` | Full translation | Québec French. |
| `pt-BR` | Full translation | Brazilian Portuguese. |

All three are **left-to-right** — no RTL work required.

---

## 2. Plural rules (CLDR) — do not hard-code `count == 1`

The ⚠️-flagged strings in `UI_COPY.md` (`{N} min read`, `{count} articles`, `{N} minutes remaining`) must use language plural categories, not English logic:

| Locale | Category for **0** | Category for **1** | Other |
|---|---|---|---|
| `en` | other → "0 articles" | one → "1 article" | "{N} articles" |
| `fr-CA` | **one → "0 article"** (singular!) | one → "1 article" | "{N} articles" |
| `pt-BR` | **other → "0 artigos"** (plural) | one → "1 artigo" | "{N} artigos" |

French and Portuguese disagree on the zero case — exactly why we delegate to the framework: iOS **String Catalog (`.xcstrings`)** plural variations, Web **ICU** plurals via `next-intl`.

---

## 3. Locale-aware formatting (code-level, must respect active locale)

- **Dates** — medium date style, never hard-coded. `en` "Apr 28, 2025" · `fr-CA` "28 avr. 2025" · `pt-BR` "28 de abr. de 2025".
- **Reading time** — `⌈wordCount ÷ WPM⌉`, `WPM = 220` (MVP constant). Word count comes from the **article's** language, not the UI language.
- **TTS voice** — `TTSService` reads article *content*, so voice selection follows the **content** language (a pt-BR voice for a Portuguese article), independent of UI locale.

---

## 4. Invariant terms — never translate

`Verso` · `Obsidian` · `iCloud Drive` · `Markdown` · `Safari` · `GitHub` · `OpenDyslexic` · theme **enum keys** (`paper`/`sepia`/`night`/`ink`).

Web-only additions (added during FAB-275 step 5): `Verso Web` · `File System Access API` · `Chrome` · `Edge` (browser names) · `Georgia` (font name). See `docs/copy/UI_COPY.md` §11 ("Web-Only Strings") for the rows these appear in.

Special case: the iCloud-error string `Go to Settings → [Your Name] → iCloud` keeps `[Your Name]` — it mirrors Apple's on-screen device-owner label. Translators match Apple's localized term, not a real name.

---

## 5. Theme labels — translate the labels, keep the keys

Enum keys stay in code; user-facing labels are translated:

| Key | en | fr-CA | pt-BR |
|---|---|---|---|
| `paper` | Paper | Papier | Papel |
| `sepia` | Sepia | Sépia | Sépia |
| `night` | Night | Nuit | Noite |
| `ink` | Ink | Encre | Tinta |

---

## 6. Font preview — per-locale, not invariant

The font preview's job is to show the typeface, so each locale uses a sentence that exercises its diacritics while keeping the "verso = left-hand page" wordplay:

| Locale | Preview string |
|---|---|
| `en` | The verso is the left-hand page. |
| `fr-CA` | Le verso est la page de gauche. *(shows é, à, ç-class accents)* |
| `pt-BR` | O verso é a página da esquerda. *(shows á, é, ã-class accents)* |

QA: confirm **OpenDyslexic** renders ç ã õ â ê é à ü cleanly at all six reading sizes before committing it as a localized option.

---

## 7. String expansion

FR/PT run ~15–30% longer than EN. Highest-risk components: **filter chips** ("En cours / Non lus" ≫ "Reading / Unread"), primary buttons, and share-sheet save states. Layouts must flex (scroll/wrap, no truncation). Run **pseudolocalization** (+30% length, accented) in QA before real strings land. See `COMPONENT_SPECS.md`.

---

## 8. Beyond the app

- **App Store metadata** (name, subtitle, description, keywords, screenshots) localizes separately from the binary — budget fr-CA and pt-BR listings.
- **Québec / Bill 96** — French commercial offerings must be available on terms no less favourable than English. If Verso is marketed or sold in Québec, fr-CA in-app **and** store presence is the compliant path.
