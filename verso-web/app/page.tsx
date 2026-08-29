"use client";

import { useMemo, useState } from "react";
import { useTranslations } from "next-intl";
import { useRouter } from "next/navigation";
import { useArticleLibrary } from "@/hooks/useArticleLibrary";
import type { Article } from "@/types/article";
import { FilterChipBar, type FilterValue } from "./components/FilterChipBar";
import { SearchBar } from "./components/SearchBar";
import { ArticleCard } from "./components/ArticleCard";
import { EmptyState } from "./components/EmptyState";
import { LoadingState } from "./components/LoadingState";
import { useTheme, type VersoTheme } from "./providers/ThemeProvider";
import { useVersoLocale } from "./providers/LocaleProvider";

const THEMES: VersoTheme[] = ["paper", "sepia", "night", "ink"];

// FAB-284: the picker only ever offers these four -- "pseudo" (part of
// LocaleProvider's broader VersoLocale type) is a developer-only QA locale,
// opted into via the cookie directly, never surfaced here.
type LanguageOption = "automatic" | "en" | "fr-CA" | "pt-BR";
const LANGUAGE_OPTIONS: LanguageOption[] = ["automatic", "en", "fr-CA", "pt-BR"];
// `docs/copy/UI_COPY.md` keys are `language.frCA`/`language.ptBR` (dots split into
// namespaces), which don't match the hyphenated locale codes above -- map between them.
const LANGUAGE_MESSAGE_KEY: Record<LanguageOption, string> = {
  automatic: "automatic",
  en: "en",
  "fr-CA": "frCA",
  "pt-BR": "ptBR",
};

// ── Unsupported browser screen ──────────────────────────────────────
function UnsupportedScreen() {
  const t = useTranslations("web.unsupportedBrowser");

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        minHeight: "100dvh",
        padding: "var(--spacing-xl)",
        textAlign: "center",
        gap: "var(--spacing-sm)",
        color: "var(--color-text-secondary)",
      }}
    >
      <span style={{ fontSize: 48, lineHeight: 1 }}>🌐</span>
      <h1
        style={{
          fontSize: "var(--type-ui-list-title-size)",
          fontWeight: "var(--type-ui-list-title-weight)",
          color: "var(--color-text-primary)",
          margin: 0,
        }}
      >
        {t("headline")}
      </h1>
      <p style={{ margin: 0, maxWidth: 320, fontSize: "var(--type-ui-list-subtitle-size)" }}>
        {t("subheadline")}
      </p>
    </div>
  );
}

// ── Language switcher (top-right, FAB-284) ───────────────────────────
function LanguageSwitcher() {
  const { locale, setLocale } = useVersoLocale();
  const t = useTranslations("language");
  // "Automatic" has no corresponding `locale` value of its own -- it's active
  // whenever nothing else is (i.e. never, once any explicit pick has run,
  // since setLocale always writes a real cookie for the other three). This
  // mirrors the picker only ever reflecting the *last explicit choice*, same
  // as iOS's LocaleManager.
  return (
    <div style={{ display: "flex", gap: "var(--spacing-xxs)" }}>
      {LANGUAGE_OPTIONS.map((option) => (
        <button
          key={option}
          onClick={() => setLocale(option)}
          title={t(LANGUAGE_MESSAGE_KEY[option])}
          style={{
            padding: "2px 8px",
            fontSize: "var(--type-ui-caption-size)",
            borderRadius: "var(--radius-pill)",
            border:
              option === locale
                ? "1px solid var(--color-accent)"
                : "1px solid var(--color-border)",
            color: option === locale ? "var(--color-accent)" : "var(--color-text-secondary)",
            backgroundColor: "transparent",
            cursor: "pointer",
            transition: "border-color 0.15s ease, color 0.15s ease",
          }}
        >
          {option === "automatic" ? "Auto" : option.split("-")[0].toUpperCase()}
        </button>
      ))}
    </div>
  );
}

// ── Theme switcher (top-right) ──────────────────────────────────────
function ThemeSwitcher() {
  const { theme, setTheme } = useTheme();
  const t = useTranslations("theme");
  return (
    <div style={{ display: "flex", gap: "var(--spacing-xxs)" }}>
      {THEMES.map((themeValue) => (
        <button
          key={themeValue}
          onClick={() => setTheme(themeValue)}
          title={t(themeValue)}
          aria-label={t(themeValue)}
          style={{
            width: 20,
            height: 20,
            borderRadius: "50%",
            border:
              theme === themeValue
                ? "2px solid var(--color-accent)"
                : "2px solid var(--color-border)",
            cursor: "pointer",
            padding: 0,
            backgroundColor:
              themeValue === "paper"
                ? "#F5F0E8"
                : themeValue === "sepia"
                ? "#F2E8D5"
                : themeValue === "night"
                ? "#1C1A16"
                : "#111418",
            transition: "border-color 0.15s ease",
          }}
        />
      ))}
    </div>
  );
}

// ── Main page ───────────────────────────────────────────────────────
export default function ArticleListPage() {
  const router = useRouter();
  const t = useTranslations("web");
  const library = useArticleLibrary();
  const [activeFilter, setActiveFilter] = useState<FilterValue>("all");
  const [searchQuery, setSearchQuery] = useState("");

  // Chip counts — always computed from full article list
  const counts = useMemo(() => {
    const all = library.articles.length;
    const unread = library.articles.filter((a) => a.status === "unread").length;
    const reading = library.articles.filter((a) => a.status === "reading").length;
    const read = library.articles.filter((a) => a.status === "read").length;
    return { all, unread, reading, read, archived: 0 } as Record<FilterValue, number>;
  }, [library.articles]);

  // Filter pipeline
  const visibleArticles = useMemo(() => {
    let result = library.articles;
    if (activeFilter !== "all") {
      result = result.filter((a) => a.status === activeFilter);
    }
    if (searchQuery.trim()) {
      const q = searchQuery.trim().toLowerCase();
      result = result.filter((a) => a.title.toLowerCase().includes(q));
    }
    return result;
  }, [library.articles, activeFilter, searchQuery]);

  function handleArticleClick(article: Article) {
    router.push(`/article/${encodeURIComponent(article.filename)}`);
  }

  if (!library.isSupported) return <UnsupportedScreen />;

  return (
    <div
      style={{
        minHeight: "100dvh",
        backgroundColor: "var(--color-background)",
        display: "flex",
        flexDirection: "column",
      }}
    >
      {/* ── Top bar ── */}
      <header
        style={{
          position: "sticky",
          top: 0,
          zIndex: 10,
          backgroundColor: "var(--color-background)",
          borderBottom: "1px solid var(--color-border)",
          padding: "var(--spacing-md) var(--spacing-lg)",
        }}
      >
        <div
          style={{
            maxWidth: 680,
            margin: "0 auto",
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            gap: "var(--spacing-md)",
          }}
        >
          <h1
            style={{
              margin: 0,
              fontSize: "var(--type-ui-screen-title-size)",
              fontWeight: "var(--type-ui-screen-title-weight)",
              lineHeight: "var(--type-ui-screen-title-line-height)",
              color: "var(--color-text-primary)",
            }}
          >
            Verso
          </h1>
          <div style={{ display: "flex", alignItems: "center", gap: "var(--spacing-sm)" }}>
            <LanguageSwitcher />
            <ThemeSwitcher />
          </div>
        </div>
      </header>

      {/* ── Content ── */}
      <main
        style={{
          flex: 1,
          maxWidth: 680,
          width: "100%",
          margin: "0 auto",
          padding: "var(--spacing-lg)",
          boxSizing: "border-box",
        }}
      >
        {library.isLoading ? (
          <LoadingState />
        ) : !library.hasFolder ? (
          <EmptyState
            activeFilter={activeFilter}
            hasSearch={false}
            hasFolder={false}
            onOpenFolder={library.openFolder}
          />
        ) : (
          <>
            {/* Search */}
            <div style={{ marginBottom: "var(--spacing-sm)" }}>
              <SearchBar value={searchQuery} onChange={setSearchQuery} />
            </div>

            {/* Filter chips — always visible */}
            <div style={{ marginBottom: "var(--spacing-md)" }}>
              <FilterChipBar
                active={activeFilter}
                counts={counts}
                onChange={setActiveFilter}
              />
            </div>

            {/* Article list or empty state */}
            {visibleArticles.length === 0 ? (
              <EmptyState
                activeFilter={activeFilter}
                hasSearch={searchQuery.trim().length > 0}
                hasFolder={true}
                onOpenFolder={library.openFolder}
              />
            ) : (
              <div>
                {visibleArticles.map((article) => (
                  <ArticleCard
                    key={article.filename}
                    article={article}
                    onClick={handleArticleClick}
                  />
                ))}
              </div>
            )}

            {/* Re-select folder link */}
            <div
              style={{
                marginTop: "var(--spacing-xl)",
                textAlign: "center",
              }}
            >
              <button
                onClick={library.openFolder}
                style={{
                  background: "none",
                  border: "none",
                  color: "var(--color-text-secondary)",
                  fontSize: "var(--type-ui-caption-size)",
                  cursor: "pointer",
                  textDecoration: "underline",
                  textDecorationColor: "var(--color-border)",
                }}
              >
                {t("changeFolder.label")}
              </button>
            </div>
          </>
        )}

        {library.error && (
          <p
            style={{
              marginTop: "var(--spacing-md)",
              color: "var(--color-error)",
              fontSize: "var(--type-ui-caption-size)",
              textAlign: "center",
            }}
          >
            {library.error}
          </p>
        )}
      </main>
    </div>
  );
}
