import { cookies } from "next/headers";
import { getRequestConfig } from "next-intl/server";

/** Locales with a real message bundle. `en-CA` is an alias of `en` -- see
 * docs/LOCALIZATION.md §1: no separate bundle, just resolve the alias here.
 * `pseudo` is a developer-only pseudo-locale for layout-flex QA (accented
 * text + ~30 % expansion), opted in via the cookie directly -- it is never
 * returned from `navigator.language`. */
export const SUPPORTED_LOCALES = ["en", "fr-CA", "pt-BR", "pseudo"] as const;
export type SupportedLocale = (typeof SUPPORTED_LOCALES)[number];
export const DEFAULT_LOCALE: SupportedLocale = "en";
export const LOCALE_COOKIE = "verso-locale";

/** Resolves any locale string (from a cookie or `navigator.language`) to one of
 * the bundles we actually ship. Mirrors the alias/fallback table in
 * docs/LOCALIZATION.md §1: `en-CA` -> `en`; unrecognized locales -> `en`.
 * `pseudo` is only returned when the cookie is *exactly* `"pseudo"` -- it is
 * never matched from a browser-language string. */
export function resolveLocale(raw: string | undefined | null): SupportedLocale {
  if (!raw) return DEFAULT_LOCALE;
  const normalized = raw.toLowerCase();
  if (normalized === "pseudo") return "pseudo";
  if (normalized === "en-ca" || normalized.startsWith("en")) return "en";
  if (normalized.startsWith("fr")) return "fr-CA";
  if (normalized.startsWith("pt")) return "pt-BR";
  return DEFAULT_LOCALE;
}

export default getRequestConfig(async () => {
  const store = await cookies();
  const locale = resolveLocale(store.get(LOCALE_COOKIE)?.value);

  return {
    locale,
    messages: (await import(`../messages/${locale}.json`)).default,
  };
});
