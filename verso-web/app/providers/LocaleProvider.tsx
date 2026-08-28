"use client";

import { createContext, useContext, useEffect } from "react";
import { useRouter } from "next/navigation";

/** Keep in sync with verso-web/i18n/request.ts -- these are the only locales with a
 * shipped message bundle. `en-CA` is an alias of `en` (see docs/LOCALIZATION.md §1),
 * resolved server-side, so it never appears here. `pseudo` is a developer-only
 * pseudo-locale for layout-flex QA, opted in by setting the cookie directly. */
export type VersoLocale = "en" | "fr-CA" | "pt-BR" | "pseudo";

const COOKIE_NAME = "verso-locale";
const COOKIE_MAX_AGE_SECONDS = 365 * 24 * 60 * 60;

interface LocaleContextValue {
  locale: VersoLocale;
  /** FAB-284: explicit language picker. Passing "automatic" clears the cookie
   * instead of writing one -- the effect below already re-detects from
   * `navigator.language` whenever the cookie is absent, so clearing it and
   * refreshing is enough to fall back to auto-detection, no separate code path
   * needed. */
  setLocale: (locale: VersoLocale | "automatic") => void;
}

const LocaleContext = createContext<LocaleContextValue | null>(null);

function readCookie(name: string): string | undefined {
  const match = document.cookie.match(new RegExp(`(?:^|; )${name}=([^;]*)`));
  return match ? decodeURIComponent(match[1]) : undefined;
}

function writeCookie(name: string, value: string) {
  document.cookie = `${name}=${value}; path=/; max-age=${COOKIE_MAX_AGE_SECONDS}; samesite=lax`;
}

function clearCookie(name: string) {
  document.cookie = `${name}=; path=/; max-age=0`;
}

function detectFromBrowser(): VersoLocale {
  const lang = navigator.language?.toLowerCase() ?? "";
  if (lang.startsWith("fr")) return "fr-CA";
  if (lang.startsWith("pt")) return "pt-BR";
  return "en";
}

export function LocaleProvider({
  children,
  initialLocale,
}: {
  children: React.ReactNode;
  /** The locale the server already resolved from the cookie (see i18n/request.ts),
   * passed down from the root layout so this provider doesn't cause a second,
   * separate render decision. */
  initialLocale: VersoLocale;
}) {
  const router = useRouter();

  useEffect(() => {
    // Runs once per browser: if there's no cookie yet (first visit), detect from
    // navigator.language, persist it, and -- only if that differs from what the
    // server already rendered with -- ask the server to re-render with the right
    // messages. Once the cookie exists, this is a no-op on every later visit.
    //
    // Known trade-off: a first-time visitor whose browser is fr-CA/pt-BR will see a
    // brief flash of English before this refresh resolves, since there's no proxy.ts
    // reading Accept-Language ahead of the first response (the plan deliberately
    // skipped adding one -- see docs/plans/FAB-275-step5-web-i18n-infra.md). Worth
    // revisiting if that flash turns out to be noticeable in practice.
    if (readCookie(COOKIE_NAME)) return;
    const detected = detectFromBrowser();
    writeCookie(COOKIE_NAME, detected);
    if (detected !== initialLocale) {
      router.refresh();
    }
  }, [initialLocale, router]);

  function setLocale(next: VersoLocale | "automatic") {
    if (next === "automatic") {
      clearCookie(COOKIE_NAME);
    } else {
      writeCookie(COOKIE_NAME, next);
    }
    router.refresh();
  }

  return (
    <LocaleContext.Provider value={{ locale: initialLocale, setLocale }}>
      {children}
    </LocaleContext.Provider>
  );
}

/** Named to avoid colliding with next-intl's own `useLocale()` -- this one exposes our
 * app-level locale context (locale + setLocale), next-intl's is for reading the active
 * locale inside message formatting. */
export function useVersoLocale(): LocaleContextValue {
  const ctx = useContext(LocaleContext);
  if (!ctx) {
    throw new Error("useVersoLocale must be used within a LocaleProvider");
  }
  return ctx;
}
