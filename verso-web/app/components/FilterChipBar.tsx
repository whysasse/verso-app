import type { ArticleStatus } from "@/types/article";

export type FilterValue = ArticleStatus | "all";

interface Chip {
  value: FilterValue;
  label: string;
}

const CHIPS: Chip[] = [
  { value: "all", label: "All" },
  { value: "unread", label: "Unread" },
  { value: "reading", label: "Reading" },
  { value: "read", label: "Read" },
];

interface FilterChipBarProps {
  active: FilterValue;
  counts: Record<FilterValue, number>;
  onChange: (value: FilterValue) => void;
}

export function FilterChipBar({ active, counts, onChange }: FilterChipBarProps) {
  return (
    <div
      style={{
        display: "flex",
        gap: "var(--spacing-xs)",
        overflowX: "auto",
        scrollbarWidth: "none",
        WebkitOverflowScrolling: "touch",
        paddingBottom: 2, // prevent clipping of focus rings
      }}
    >
      {CHIPS.map(({ value, label }) => {
        const isActive = active === value;
        return (
          <button
            key={value}
            onClick={() => onChange(value)}
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "var(--spacing-xxs)",
              padding: "6px var(--spacing-sm)",
              borderRadius: "var(--radius-pill)",
              border: `1px solid ${isActive ? "transparent" : "var(--color-border)"}`,
              backgroundColor: isActive
                ? "var(--color-accent-surface)"
                : "var(--color-surface)",
              color: isActive ? "var(--color-accent)" : "var(--color-text-secondary)",
              fontSize: "var(--type-ui-caption-size)",
              fontWeight: isActive ? 600 : 400,
              cursor: "pointer",
              whiteSpace: "nowrap",
              flexShrink: 0,
              transition: "background-color 0.15s ease, color 0.15s ease",
            }}
          >
            {label}
            <span
              style={{
                fontSize: 11,
                opacity: 0.75,
              }}
            >
              {counts[value]}
            </span>
          </button>
        );
      })}
    </div>
  );
}
