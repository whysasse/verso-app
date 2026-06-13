import type { Article, ArticleStatus } from "@/types/article";

const STATUS_COLORS: Record<ArticleStatus, string> = {
  unread: "#4A90D9",
  reading: "#D4A353",
  read: "#5AAF7A",
  archived: "#8F897F",
};

const STATUS_LABELS: Record<ArticleStatus, string> = {
  unread: "Unread",
  reading: "Reading",
  read: "Read",
  archived: "Archived",
};

function formatDate(iso: string): string {
  const d = new Date(iso + "T00:00:00"); // treat as local date
  return d.toLocaleDateString("en-CA", {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

function extractHostname(url?: string): string | null {
  if (!url) return null;
  try {
    return new URL(url).hostname.replace(/^www\./, "");
  } catch {
    return null;
  }
}

interface ArticleCardProps {
  article: Article;
  onClick: (article: Article) => void;
}

export function ArticleCard({ article, onClick }: ArticleCardProps) {
  const statusColor = STATUS_COLORS[article.status];
  const source = article.site_name ?? extractHostname(article.url);

  return (
    <button
      onClick={() => onClick(article)}
      style={{
        display: "block",
        width: "100%",
        textAlign: "left",
        background: "none",
        border: "none",
        padding: "var(--spacing-md) 0",
        cursor: "pointer",
        borderBottom: "1px solid var(--color-border)",
      }}
    >
      <div style={{ display: "flex", alignItems: "flex-start", gap: "var(--spacing-sm)" }}>
        {/* Status dot */}
        <span
          aria-label={STATUS_LABELS[article.status]}
          style={{
            flexShrink: 0,
            width: 8,
            height: 8,
            borderRadius: "50%",
            backgroundColor: statusColor,
            marginTop: 6, // optical alignment with first line of title
          }}
        />

        {/* Text */}
        <div style={{ flex: 1, minWidth: 0 }}>
          <p
            style={{
              margin: "0 0 var(--spacing-xxs)",
              fontSize: "var(--type-ui-list-title-size)",
              fontWeight: "var(--type-ui-list-title-weight)",
              lineHeight: "var(--type-ui-list-title-line-height)",
              color: "var(--color-text-primary)",
              overflow: "hidden",
              textOverflow: "ellipsis",
              whiteSpace: "nowrap",
            }}
          >
            {article.title}
          </p>
          <p
            style={{
              margin: 0,
              fontSize: "var(--type-ui-caption-size)",
              color: "var(--color-text-secondary)",
              overflow: "hidden",
              textOverflow: "ellipsis",
              whiteSpace: "nowrap",
            }}
          >
            {[source, formatDate(article.added)].filter(Boolean).join(" · ")}
          </p>
        </div>
      </div>
    </button>
  );
}
