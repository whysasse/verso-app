import { cookies } from "next/headers";
import { getRequestConfig } from "next-intl/server";

/** Locales with a real message bundle. `en-CA` is an alias of `en` -- see
 * docs/LOCALIZATION.md §1: no separate bundle, just resolve the alias here. */
export const SUPPORTED_LOCALES = ["en", "fr-CA", "pt-BR"] as const;
export type SupportedLocale = (typeof SUPPORTED_LOCALES)[number];
export const DEFAULT_LOCALE: SupportedLocale = "en";
export const LOCALE_COOKIE = "verso-locale";

/** Resolves any locale string (from a cookie or `navigator.language`) to one of
 * the bundles we actually ship. Mirrors the alias/fallback table in
 * docs/LOCALIZATION.md §1: `en-CA` -> `en`; unrecognized locales -> `en`. */
export function resolveLocale(raw: string | undefined | null): SupportedLocale {
  if (!raw) return DEFAULT_LOCALE;
  const normalized = raw.toLowerCase();
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
