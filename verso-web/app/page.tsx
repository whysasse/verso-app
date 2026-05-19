"use client";

import { useTheme, VersoTheme } from "./providers/ThemeProvider";

const THEMES: VersoTheme[] = ["paper", "sepia", "night", "ink"];

const COLOR_ROLES = [
  { label: "background", var: "--color-background" },
  { label: "surface", var: "--color-surface" },
  { label: "text-primary", var: "--color-text-primary" },
  { label: "text-secondary", var: "--color-text-secondary" },
  { label: "accent", var: "--color-accent" },
  { label: "accent-pressed", var: "--color-accent-pressed" },
  { label: "accent-surface", var: "--color-accent-surface" },
  { label: "border", var: "--color-border" },
  { label: "placeholder", var: "--color-placeholder" },
  { label: "error", var: "--color-error" },
  { label: "warning", var: "--color-warning" },
  { label: "success", var: "--color-success" },
];

const STATUS_ROLES = [
  { label: "status-unread", var: "--color-status-unread" },
  { label: "status-reading", var: "--color-status-reading" },
  { label: "status-read", var: "--color-status-read" },
];

export default function Home() {
  const { theme, setTheme } = useTheme();

  return (
    <main
      style={{
        minHeight: "100vh",
        backgroundColor: "var(--color-background)",
        color: "var(--color-text-primary)",
        padding: "var(--spacing-xl)",
        fontFamily: "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
      }}
    >
      <h1
        style={{
          fontSize: "var(--type-ui-screen-title-size)",
          fontWeight: "var(--type-ui-screen-title-weight)",
          lineHeight: "var(--type-ui-screen-title-line-height)",
          marginBottom: "var(--spacing-lg)",
        }}
      >
        Verso Design System
      </h1>

      {/* Theme selector */}
      <section style={{ marginBottom: "var(--spacing-xl)" }}>
        <h2
          style={{
            fontSize: "var(--type-ui-list-title-size)",
            fontWeight: "var(--type-ui-list-title-weight)",
            marginBottom: "var(--spacing-sm)",
            color: "var(--color-text-secondary)",
          }}
        >
          Theme
        </h2>
        <div style={{ display: "flex", gap: "var(--spacing-xs)" }}>
          {THEMES.map((t) => (
            <button
              key={t}
              onClick={() => setTheme(t)}
              style={{
                padding: "var(--spacing-xs) var(--spacing-sm)",
                borderRadius: "var(--radius-lg)",
                border: "1px solid var(--color-border)",
                backgroundColor: theme === t ? "var(--color-accent-surface)" : "var(--color-surface)",
                color: theme === t ? "var(--color-accent)" : "var(--color-text-primary)",
                fontWeight: theme === t ? 600 : 400,
                fontSize: "var(--type-ui-button-size)",
                cursor: "pointer",
                textTransform: "capitalize",
                transition: "background-color 0.15s ease, color 0.15s ease",
              }}
            >
              {t}
            </button>
          ))}
        </div>
      </section>

      {/* Color swatches */}
      <section style={{ marginBottom: "var(--spacing-xl)" }}>
        <h2
          style={{
            fontSize: "var(--type-ui-list-title-size)",
            fontWeight: "var(--type-ui-list-title-weight)",
            marginBottom: "var(--spacing-sm)",
            color: "var(--color-text-secondary)",
          }}
        >
          Theme Colors
        </h2>
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(160px, 1fr))",
            gap: "var(--spacing-xs)",
          }}
        >
          {COLOR_ROLES.map(({ label, var: cssVar }) => (
            <div
              key={label}
              style={{
                borderRadius: "var(--radius-md)",
                overflow: "hidden",
                border: "1px solid var(--color-border)",
              }}
            >
              <div
                style={{
                  height: 48,
                  backgroundColor: `var(${cssVar})`,
                  borderBottom: "1px solid var(--color-border)",
                }}
              />
              <div
                style={{
                  backgroundColor: "var(--color-surface)",
                  padding: "var(--spacing-xs)",
                  fontSize: "var(--type-ui-caption-size)",
                  color: "var(--color-text-secondary)",
                }}
              >
                {label}
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Status colors */}
      <section style={{ marginBottom: "var(--spacing-xl)" }}>
        <h2
          style={{
            fontSize: "var(--type-ui-list-title-size)",
            fontWeight: "var(--type-ui-list-title-weight)",
            marginBottom: "var(--spacing-sm)",
            color: "var(--color-text-secondary)",
          }}
        >
          Article Status Colors (fixed)
        </h2>
        <div style={{ display: "flex", gap: "var(--spacing-xs)" }}>
          {STATUS_ROLES.map(({ label, var: cssVar }) => (
            <div
              key={label}
              style={{
                borderRadius: "var(--radius-md)",
                overflow: "hidden",
                border: "1px solid var(--color-border)",
                flex: "1",
              }}
            >
              <div
                style={{
                  height: 48,
                  backgroundColor: `var(${cssVar})`,
                  borderBottom: "1px solid var(--color-border)",
                }}
              />
              <div
                style={{
                  backgroundColor: "var(--color-surface)",
                  padding: "var(--spacing-xs)",
                  fontSize: "var(--type-ui-caption-size)",
                  color: "var(--color-text-secondary)",
                }}
              >
                {label}
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* OpenDyslexic font sample */}
      <section>
        <h2
          style={{
            fontSize: "var(--type-ui-list-title-size)",
            fontWeight: "var(--type-ui-list-title-weight)",
            marginBottom: "var(--spacing-sm)",
            color: "var(--color-text-secondary)",
          }}
        >
          OpenDyslexic Font
        </h2>
        <p
          style={{
            fontFamily: "OpenDyslexic, sans-serif",
            fontSize: "var(--type-reading-body-md-size)",
            lineHeight: "var(--type-reading-body-line-height)",
            color: "var(--color-text-primary)",
            maxWidth: 600,
          }}
        >
          The quick brown fox jumps over the lazy dog. Reading should feel effortless.
        </p>
      </section>
    </main>
  );
}
