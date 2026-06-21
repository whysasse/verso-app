# FAB-275 step 5 — Web i18n infrastructure

**Goal:** Web renders `docs/copy/UI_COPY.md` strings in `en` / `fr-CA` / `pt-BR`, the same way iOS does after steps 3–4. *Done when:* web renders per-locale strings (per the epic checklist in `docs/BACKLOG.md`).

**Status of the app today** (checked directly in `verso-web/`, 2026-06-21): pure client-side App Router app, no `[locale]` segment, no i18n library installed yet, ~10 small components, no settings/preferences screen at all (the only "preference" UI is the 4-dot `ThemeSwitcher` in the header, persisted to `localStorage`). `package.json` has Next.js `16.2.6` / React `19.2.4`.

---

## Decision: skip locale-based URL routing

`LOCALIZATION.md` §2 ratifies **next-intl** as the library (for ICU plurals) but doesn't mandate *how* it's wired in. next-intl supports two setups: a routed one (`app/[locale]/...`, middleware-driven redirects, e.g. `/fr-CA/about`) and a ["without i18n routing"](https://next-intl.dev/docs/getting-started/app-router/without-i18n-routing) one (locale comes from a cookie, no URL segment).

**Recommendation: use the cookie-based setup, not routing.** Reasoning:

- Verso Web reads articles from a locally-selected folder via the File System Access API — there's no shareable, indexable, or SEO-relevant content behind a URL. Locale-per-path exists to make `/fr/about` linkable and crawlable; neither applies here.
- The app currently has **zero** route segments (`app/page.tsx`, `app/article/[id]/page.tsx` are the only two routes). Adding `[locale]` would mean moving every route one level deeper and adding a proxy/redirect step, for a benefit the app can't use.
- It directly mirrors the existing `ThemeProvider` pattern (client context + `localStorage`, no routing) that's already proven in this codebase — same shape, same place a user would expect to find it later if a picker gets added.

If Verso Web ever grows public, shareable article pages, this can be revisited — next-intl supports adding routing later without a rewrite.

**Next.js 16 note:** the *routed* next-intl setup needs `proxy.ts` (Next 16 renamed `middleware.ts` → `proxy.ts`). Since we're skipping routing, this doesn't apply to us now — but worth remembering if routing gets added later, since most next-intl examples online still say `middleware.ts`.

## Decision: no language picker yet (matches iOS)

Checked `Verso/Sources/Screens/Settings` — iOS has **no in-app language picker either**; it just follows the system/device language via the String Catalog, which is the idiomatic iOS pattern. To stay consistent, Web should do the same for now: detect from the browser (`navigator.language` / `Accept-Language`) and fall back to `en`, with no visible switcher. Persist the resolved locale in a cookie (same role `localStorage` plays for theme) so a user's choice — once we add the ability to override — survives reloads.

If you'd rather Web have an explicit picker before iOS does, flag it — that's a product/UX call, not a technical constraint, and easy to layer on top of the plan below (it would just mean wiring a setter into the same `LocaleProvider`, similar to `useTheme`'s `setTheme`).

---

## Step 1 — Install next-intl, wire the plugin

1. `npm install next-intl` in `verso-web/`. Confirm the installed version supports Next 16 / React 19 (as of this check, next-intl 4.4+ does).
2. `next.config.ts`: wrap the config with `createNextIntlPlugin()` from `next-intl/plugin`.
3. Add `verso-web/i18n/request.ts`:
   ```ts
   import { cookies } from "next/headers";
   import { getRequestConfig } from "next-intl/server";

   const SUPPORTED = ["en", "fr-CA", "pt-BR"] as const;
   const DEFAULT_LOCALE = "en";

   export default getRequestConfig(async () => {
     const store = await cookies();
     const cookieLocale = store.get("verso-locale")?.value;
     const locale = SUPPORTED.includes(cookieLocale as any) ? cookieLocale! : DEFAULT_LOCALE;
     return {
       locale,
       messages: (await import(`../messages/${locale}.json`)).default,
     };
   });
   ```
4. Root layout (`app/layout.tsx`): wrap `children` in `NextIntlClientProvider` (needed because every component in this app is `"use client"`).

**Done when:** app builds and renders with the English messages file (created in step 2) with no runtime errors.

---

## Step 2 — Extend `generate.py` to emit `messages/<locale>.json`

Same source (`UI_COPY.md`), same script (`docs/copy/codegen/generate.py`), one more output. Add a third generation block alongside the existing `.xcstrings`/`L10n.swift` ones:

- **Key shape:** keep the exact dotted keys from `UI_COPY.md` (e.g. `filter.unread.accessibilityLabel`) as nested JSON objects (`{"filter": {"unread": {"accessibilityLabel": "..."}}}`). next-intl supports nested namespaces natively via `useTranslations("filter.unread")`, and reusing the same key string as iOS (instead of inventing a separate Web namespace convention) means a key can be looked up in `UI_COPY.md` once and trusted on both platforms — no separate mapping table to keep in sync.
- **Placeholders:** UI_COPY.md already writes placeholders as `{N}`, `{count}`, `{existingTitle}` — that's already valid ICU MessageFormat syntax (the format next-intl uses), so unlike the Swift output (`%lld`/`%@`), **no placeholder translation is needed** here. Reuse the existing `param_name()` helper only to normalize multi-word placeholders (e.g. `{existing title}` → `{existingTitle}`) into valid ICU variable names.
- **True plurals:** for the 6 keys in `TRUE_PLURAL_KEYS`, emit ICU plural syntax instead of a flat string:
  ```json
  "filter": { "unread": { "accessibilityLabel": "{count, plural, one {Unread, # article} other {Unread, # articles}}" } }
  ```
  Reuse `PLURAL_ONE_FORMS` for the `one` branch text (same hand-written singular forms already used for the `.xcstrings` output). No `=0` override needed for fr-CA/pt-BR — confirmed their CLDR cardinal rules already route `0` to the correct category (fr-CA's `one` covers 0 and 1; pt-BR's `one` covers only 1), exactly matching what `LOCALIZATION.md` §2 specifies, so the plain `one`/`other` pair is sufficient on both platforms.
- **Output files:** `verso-web/messages/en.json`, `fr-CA.json`, `pt-BR.json`. No `en-CA.json` — `LOCALIZATION.md` §1 says `en-CA` aliases `en` with no separate bundle; resolve that alias in `i18n/request.ts`'s locale matching, not with a duplicate file.
- Re-run the script, diff the new files against nothing (first run) to sanity-check structure, and add `messages/` to whatever the project already does for generated-file conventions (it's generated — same treatment as `Verso/Generated/`).

**Done when:** `messages/en.json` / `fr-CA.json` / `pt-BR.json` exist, are well-formed ICU/JSON, and the key set exactly matches `UI_COPY.md` (regenerating should be a no-op against itself, same idempotency check already used for the iOS outputs).

---

## Step 3 — `LocaleProvider` (mirrors `ThemeProvider`)

New `verso-web/app/providers/LocaleProvider.tsx`:

- Resolves initial locale: read the `verso-locale` cookie if present; otherwise match `navigator.language` against `["en", "fr-CA", "pt-BR"]` (simple prefix/region match — `fr-*` → `fr-CA`, `pt-*` → `pt-BR`, everything else → `en`); write the resolved value back to the cookie so the server-side `i18n/request.ts` picks it up on the next request.
- No setter exposed yet (no picker — see decision above), but shape the context the same way `ThemeContext` is shaped so adding `setLocale` later is a small diff, not a rewrite.

**Done when:** loading the app in a French-language browser renders fr-CA strings without any explicit user action.

---

## Step 4 — Wire components to `useTranslations`

Start with the components `LOCALIZATION.md` §7 flags as highest expansion-risk, since those are the ones most likely to reveal layout problems early:

1. `FilterChipBar.tsx` — chip labels (`CHIPS` array) + the accessibility labels with real plurals (`filter.unread.accessibilityLabel` etc.) — these chips must **stay visible even when the filtered view is empty** (see existing project convention on filter chips/empty states — this is a layout invariant, not something localization should change).
2. `EmptyState.tsx` — all 5 `messageFor()` branches, "No folder selected", "Select the iCloud Drive folder...", "Choose Folder" button.
3. `SearchBar.tsx` — `placeholder="Search articles"`, `aria-label="Clear search"`.
4. `LoadingState.tsx` — "Loading articles…".
5. `page.tsx` — `UnsupportedScreen` copy, `ThemeSwitcher`'s `aria-label`, "Change folder" button, the `library.error` display.
6. `ArticleCard.tsx`, `MarkdownRenderer.tsx`, `app/article/[id]/page.tsx` — re-check these for literals (first pass above didn't show obvious hardcoded text via grep, but grep on JSX text is unreliable — read each file directly before declaring it clean, same lesson from the iOS sweep).

For each string: look up the matching key in `UI_COPY.md` §2 ("Home / Article List") first. **If the shipped Web copy doesn't match the documented wording** (it may not — Web was scaffolded independently), follow the same policy used for the iOS view-wiring pass (FAB-281/FAB-283 precedent): don't silently change visible copy to match the doc. Wire an interim key that matches what's actually shipped, and file the wording mismatch as its own backlog entry for a deliberate copy decision later.

**Done when:** no hardcoded user-facing string literals remain in `verso-web/app/`, `npm run build` succeeds, and switching the browser's language (or the cookie, for manual testing) changes the rendered text.

---

## Step 5 — Verification

1. `npm run build` — confirm no missing-message errors from next-intl (it throws at build/runtime if a key referenced in code is missing from the JSON).
2. Manual smoke check in all three locales: load the app, confirm filter chips, empty states, and the search placeholder render correctly and don't visibly overflow/truncate. This is an informal check, not the real pseudolocalization pass — that's epic step 6, out of scope here.
3. Re-run `generate.py` once more at the end and confirm zero diff, same idempotency guarantee already established for the iOS outputs.
4. Update `docs/BACKLOG.md`'s FAB-275 checklist: check off step 5, same annotation style used for steps 3–4.

---

## Notes for whoever picks this up

- Fabio is a UX designer, not a developer — trusts technical calls but wants the reasoning. The two decisions above (no URL routing, no picker yet) are exactly the kind of call to explain rather than make silently — flag if either should be revisited.
- Don't reach for the routed next-intl setup "to be safe" — it adds real complexity (a `proxy.ts`, a `[locale]` segment migration for both existing routes) for a capability (linkable per-locale URLs) this app has no current use for.
- Reuse `UI_COPY.md` keys verbatim on Web. Inventing a parallel Web-only key naming convention is the kind of decision that quietly causes the iOS/Web copy to drift over time.
