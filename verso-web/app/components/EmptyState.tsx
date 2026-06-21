import { useTranslations } from "next-intl";
import type { ArticleStatus } from "@/types/article";

interface EmptyStateProps {
  activeFilter: ArticleStatus | "all";
  hasSearch: boolean;
  hasFolder: boolean;
  onOpenFolder: () => void;
}

// Web filters the list by status (all/unread/reading/read) and shows one empty state
// per filter, plus a search variant. iOS doesn't have a per-status-filter empty state,
// so only `noArticles` ("all", no search) and `noResults` (search) reuse a documented
// iOS key; `noUnread`/`noReading`/`noRead` are net-new rows added to UI_COPY.md
// alongside this wiring pass (see docs/copy/UI_COPY.md "Empty States" section).
function scenarioFor(
  activeFilter: ArticleStatus | "all",
  hasSearch: boolean,
): "noResults" | "noUnread" | "noReading" | "noRead" | "noArticles" {
  if (hasSearch) return "noResults";
  if (activeFilter === "unread") return "noUnread";
  if (activeFilter === "reading") return "noReading";
  if (activeFilter === "read") return "noRead";
  return "noArticles";
}

export function EmptyState({
  activeFilter,
  hasSearch,
  hasFolder,
  onOpenFolder,
}: EmptyStateProps) {
  const t = useTranslations();
  const scenario = scenarioFor(activeFilter, hasSearch);

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: "var(--spacing-sm)",
        padding: "var(--spacing-3xl) var(--spacing-xl)",
        textAlign: "center",
        color: "var(--color-text-secondary)",
      }}
    >
      <span style={{ fontSize: 40, lineHeight: 1 }}>📖</span>
      <p
        style={{
          fontSize: "var(--type-ui-list-title-size)",
          fontWeight: "var(--type-ui-list-title-weight)",
          color: "var(--color-text-primary)",
          margin: 0,
        }}
      >
        {hasFolder ? t(`home.empty.${scenario}.headline`) : t("error.noFolder.headline")}
      </p>
      <p
        style={{
          fontSize: "var(--type-ui-list-subtitle-size)",
          margin: "0 0 var(--spacing-xs)",
          maxWidth: 300,
        }}
      >
        {hasFolder ? t(`home.empty.${scenario}.subheadline`) : t("error.noFolder.subheadline")}
      </p>
      {!hasFolder && (
        <button
          onClick={onOpenFolder}
          style={{
            padding: "var(--spacing-xs) var(--spacing-lg)",
            borderRadius: "var(--radius-pill)",
            border: "none",
            backgroundColor: "var(--color-accent)",
            color: "var(--color-background)",
            fontSize: "var(--type-ui-button-size)",
            fontWeight: "var(--type-ui-button-weight)",
            cursor: "pointer",
          }}
        >
          {t("error.noFolder.cta")}
        </button>
      )}
    </div>
  );
}
