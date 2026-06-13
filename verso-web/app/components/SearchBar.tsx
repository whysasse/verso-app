interface SearchBarProps {
  value: string;
  onChange: (value: string) => void;
}

export function SearchBar({ value, onChange }: SearchBarProps) {
  return (
    <div style={{ position: "relative" }}>
      {/* Search icon */}
      <span
        aria-hidden
        style={{
          position: "absolute",
          left: "var(--spacing-sm)",
          top: "50%",
          transform: "translateY(-50%)",
          color: "var(--color-placeholder)",
          fontSize: 15,
          pointerEvents: "none",
          lineHeight: 1,
        }}
      >
        🔍
      </span>
      <input
        type="search"
        placeholder="Search articles"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        style={{
          width: "100%",
          boxSizing: "border-box",
          padding: "10px var(--spacing-md) 10px 36px",
          borderRadius: "var(--radius-md)",
          border: "1px solid var(--color-border)",
          backgroundColor: "var(--color-surface)",
          color: "var(--color-text-primary)",
          fontSize: "var(--type-ui-input-size)",
          lineHeight: "var(--type-ui-input-line-height)",
          outline: "none",
          appearance: "none",
          WebkitAppearance: "none",
        }}
        onFocus={(e) => {
          e.currentTarget.style.borderColor = "var(--color-accent)";
        }}
        onBlur={(e) => {
          e.currentTarget.style.borderColor = "var(--color-border)";
        }}
      />
      {value && (
        <button
          onClick={() => onChange("")}
          aria-label="Clear search"
          style={{
            position: "absolute",
            right: "var(--spacing-sm)",
            top: "50%",
            transform: "translateY(-50%)",
            background: "none",
            border: "none",
            color: "var(--color-placeholder)",
            cursor: "pointer",
            fontSize: 15,
            lineHeight: 1,
            padding: 0,
          }}
        >
          ✕
        </button>
      )}
    </div>
  );
}
