import { useTranslations } from "next-intl";
import type { ArticleStatus } from "@/types/article";

export type FilterValue = ArticleStatus | "all";

const CHIP_VALUES: FilterValue[] = ["all", "unread", "reading", "read"];

interface FilterChipBarProps {
  active: FilterValue;
  counts: Record<FilterValue, number>;
  onChange: (value: FilterValue) => void;
}

export function FilterChipBar({ active, counts, onChange }: FilterChipBarProps) {
  // Each chip's visible label collides in UI_COPY.md with that same key's
  // accessibilityLabel sibling (e.g. `filter.unread` + `filter.unread.accessibilityLabel`),
  // so the codegen pushes the plain label under a reserved "_label" child -- see
  // docs/copy/codegen/generate.py's KEYS_WITH_CHILDREN handling.
  const t = useTranslations("filter");

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
      {CHIP_VALUES.map((value) => {
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
            {t(`${value}._label`)}
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
