"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { useArticleLibrary } from "@/hooks/useArticleLibrary";
import type { Article } from "@/types/article";
import { FilterChipBar, type FilterValue } from "./components/FilterChipBar";
import { SearchBar } from "./components/SearchBar";
import { ArticleCard } from "./components/ArticleCard";
import { EmptyState } from "./components/EmptyState";
import { LoadingState } from "./components/LoadingState";
import { useTheme, type VersoTheme } from "./providers/ThemeProvider";

const THEMES: VersoTheme[] = ["paper", "sepia", "night", "ink"];

// ── Unsupported browser screen ──────────────────────────────────────
function UnsupportedScreen() {
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
        Browser not supported
      </h1>
      <p style={{ margin: 0, maxWidth: 320, fontSize: "var(--type-ui-list-subtitle-size)" }}>
        Verso Web uses the File System Access API, which requires Chrome or Edge 86+. Please open
        this page in a supported browser.
      </p>
    </div>
  );
}

// ── Theme switcher (top-right) ──────────────────────────────────────
function ThemeSwitcher() {
  const { theme, setTheme } = useTheme();
  return (
    <div style={{ display: "flex", gap: "var(--spacing-xxs)" }}>
      {THEMES.map((t) => (
        <button
          key={t}
          onClick={() => setTheme(t)}
          title={t}
          aria-label={`Switch to ${t} theme`}
          style={{
            width: 20,
            height: 20,
            borderRadius: "50%",
            border: theme === t ? "2px solid var(--color-accent)" : "2px solid var(--color-border)",
            cursor: "pointer",
            padding: 0,
            backgroundColor:
              t === "paper"
                ? "#F5F0E8"
                : t === "sepia"
                ? "#F2E8D5"
                : t === "night"
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
          <ThemeSwitcher />
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
                Change folder
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
