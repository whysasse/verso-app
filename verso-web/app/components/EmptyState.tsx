import type { ArticleStatus } from "@/types/article";

interface EmptyStateProps {
  activeFilter: ArticleStatus | "all";
  hasSearch: boolean;
  hasFolder: boolean;
  onOpenFolder: () => void;
}

function messageFor(
  activeFilter: ArticleStatus | "all",
  hasSearch: boolean,
): string {
  if (hasSearch) return "No articles match your search.";
  if (activeFilter === "unread") return "No unread articles.";
  if (activeFilter === "reading") return "Nothing in progress.";
  if (activeFilter === "read") return "No read articles yet.";
  return "No articles in your library.";
}

export function EmptyState({
  activeFilter,
  hasSearch,
  hasFolder,
  onOpenFolder,
}: EmptyStateProps) {
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
        {hasFolder ? messageFor(activeFilter, hasSearch) : "No folder selected"}
      </p>
      {!hasFolder && (
        <>
          <p
            style={{
              fontSize: "var(--type-ui-list-subtitle-size)",
              margin: "0 0 var(--spacing-xs)",
              maxWidth: 300,
            }}
          >
            Select the iCloud Drive folder where your Verso articles are stored.
          </p>
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
            Choose Folder
          </button>
        </>
      )}
    </div>
  );
}
