import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import type { Components } from "react-markdown";

export type FontFamily = "georgia" | "system" | "mono" | "dyslexic";
export type FontSize = 14 | 16 | 18 | 20 | 22 | 26;
export type LineHeight = "compact" | "normal" | "relaxed" | "airy";

const FONT_FAMILY_CSS: Record<FontFamily, string> = {
  georgia: "Georgia, 'Times New Roman', serif",
  system: "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
  mono: "'Courier New', Courier, monospace",
  dyslexic: "OpenDyslexic, sans-serif",
};

const LINE_HEIGHT_VALUE: Record<LineHeight, number> = {
  compact: 1.4,
  normal: 1.6,
  relaxed: 1.75,
  airy: 2.0,
};

interface MarkdownRendererProps {
  content: string;
  fontFamily?: FontFamily;
  fontSize?: FontSize;
  lineHeight?: LineHeight;
}

export function MarkdownRenderer({
  content,
  fontFamily = "georgia",
  fontSize = 18,
  lineHeight = "relaxed",
}: MarkdownRendererProps) {
  const ff = FONT_FAMILY_CSS[fontFamily];
  const lh = LINE_HEIGHT_VALUE[lineHeight];

  const base: React.CSSProperties = {
    fontFamily: ff,
    fontSize,
    lineHeight: lh,
    color: "var(--color-text-primary)",
  };

  const components: Components = {
    // Headings
    h1: ({ children }) => (
      <h1
        style={{
          ...base,
          fontSize: "var(--type-reading-h1-size)",
          fontWeight: "var(--type-reading-h1-weight)",
          lineHeight: "var(--type-reading-h1-line-height)",
          marginTop: "1.5em",
          marginBottom: "0.5em",
        }}
      >
        {children}
      </h1>
    ),
    h2: ({ children }) => (
      <h2
        style={{
          ...base,
          fontSize: "var(--type-reading-h2-size)",
          fontWeight: "var(--type-reading-h2-weight)",
          lineHeight: "var(--type-reading-h2-line-height)",
          marginTop: "1.4em",
          marginBottom: "0.4em",
        }}
      >
        {children}
      </h2>
    ),
    h3: ({ children }) => (
      <h3
        style={{
          ...base,
          fontSize: "var(--type-reading-h3-size)",
          fontWeight: "var(--type-reading-h3-weight)",
          lineHeight: "var(--type-reading-h3-line-height)",
          marginTop: "1.3em",
          marginBottom: "0.4em",
        }}
      >
        {children}
      </h3>
    ),
    h4: ({ children }) => (
      <h4
        style={{
          ...base,
          fontSize: "var(--type-reading-h4-size)",
          fontWeight: "var(--type-reading-h4-weight)",
          lineHeight: "var(--type-reading-h4-line-height)",
          marginTop: "1.2em",
          marginBottom: "0.3em",
        }}
      >
        {children}
      </h4>
    ),
    h5: ({ children }) => (
      <h5 style={{ ...base, fontSize: fontSize * 0.9, fontWeight: 600, marginTop: "1.2em", marginBottom: "0.3em" }}>
        {children}
      </h5>
    ),
    h6: ({ children }) => (
      <h6
        style={{
          ...base,
          fontSize: fontSize * 0.85,
          fontWeight: 600,
          color: "var(--color-text-secondary)",
          marginTop: "1.2em",
          marginBottom: "0.3em",
        }}
      >
        {children}
      </h6>
    ),

    // Paragraph
    p: ({ children }) => (
      <p style={{ ...base, margin: "0 0 1em" }}>{children}</p>
    ),

    // Links
    a: ({ href, children }) => (
      <a
        href={href}
        target="_blank"
        rel="noopener noreferrer"
        style={{
          color: "var(--color-accent)",
          textDecoration: "underline",
          textDecorationColor: "var(--color-accent-surface)",
        }}
      >
        {children}
      </a>
    ),

    // Lists
    ul: ({ children }) => (
      <ul style={{ ...base, margin: "0 0 1em", paddingLeft: "1.5em" }}>{children}</ul>
    ),
    ol: ({ children }) => (
      <ol style={{ ...base, margin: "0 0 1em", paddingLeft: "1.5em" }}>{children}</ol>
    ),
    li: ({ children }) => (
      <li style={{ ...base, margin: "0.25em 0" }}>{children}</li>
    ),

    // Blockquote
    blockquote: ({ children }) => (
      <blockquote
        style={{
          borderLeft: "3px solid var(--color-accent)",
          margin: "1.5em 0",
          padding: "0.5em 0 0.5em 1.25em",
          color: "var(--color-text-secondary)",
          fontStyle: "italic",
        }}
      >
        {children}
      </blockquote>
    ),

    // Inline code
    code: ({ children, className }) => {
      const isBlock = className?.startsWith("language-");
      if (isBlock) return <code className={className}>{children}</code>;
      return (
        <code
          style={{
            fontFamily: "'Courier New', Courier, monospace",
            fontSize: "0.875em",
            backgroundColor: "var(--color-surface)",
            border: "1px solid var(--color-border)",
            borderRadius: 4,
            padding: "0.1em 0.35em",
            color: "var(--color-text-primary)",
          }}
        >
          {children}
        </code>
      );
    },

    // Code block
    pre: ({ children }) => (
      <pre
        style={{
          backgroundColor: "var(--color-surface)",
          border: "1px solid var(--color-border)",
          borderRadius: "var(--radius-md)",
          padding: "var(--spacing-md)",
          overflowX: "auto",
          margin: "1.5em 0",
          fontFamily: "'Courier New', Courier, monospace",
          fontSize: 14,
          lineHeight: 1.5,
          color: "var(--color-text-primary)",
        }}
      >
        {children}
      </pre>
    ),

    // Horizontal rule
    hr: () => (
      <hr
        style={{
          border: "none",
          borderTop: "1px solid var(--color-border)",
          margin: "2em 0",
        }}
      />
    ),

    // Images
    img: ({ src, alt }) => (
      <img
        src={src}
        alt={alt ?? ""}
        style={{
          maxWidth: "100%",
          height: "auto",
          borderRadius: "var(--radius-md)",
          display: "block",
          margin: "1.5em auto",
        }}
      />
    ),

    // Tables (GFM)
    table: ({ children }) => (
      <div style={{ overflowX: "auto", margin: "1.5em 0" }}>
        <table
          style={{
            width: "100%",
            borderCollapse: "collapse",
            fontSize,
            fontFamily: ff,
          }}
        >
          {children}
        </table>
      </div>
    ),
    thead: ({ children }) => (
      <thead style={{ borderBottom: "2px solid var(--color-border)" }}>{children}</thead>
    ),
    th: ({ children }) => (
      <th
        style={{
          padding: "var(--spacing-xs) var(--spacing-sm)",
          textAlign: "left",
          fontWeight: 600,
          color: "var(--color-text-secondary)",
          fontSize: "0.875em",
        }}
      >
        {children}
      </th>
    ),
    td: ({ children }) => (
      <td
        style={{
          padding: "var(--spacing-xs) var(--spacing-sm)",
          borderBottom: "1px solid var(--color-border)",
        }}
      >
        {children}
      </td>
    ),

    // Strikethrough (GFM)
    del: ({ children }) => (
      <del style={{ color: "var(--color-text-secondary)" }}>{children}</del>
    ),
  };

  return (
    <div>
      <ReactMarkdown remarkPlugins={[remarkGfm]} components={components}>
        {content}
      </ReactMarkdown>
    </div>
  );
}
