export function LoadingState() {
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: "var(--spacing-sm)",
        padding: "var(--spacing-3xl)",
        color: "var(--color-text-secondary)",
      }}
    >
      <div
        style={{
          width: 24,
          height: 24,
          border: "2px solid var(--color-border)",
          borderTopColor: "var(--color-accent)",
          borderRadius: "50%",
          animation: "verso-spin 0.7s linear infinite",
        }}
      />
      <span style={{ fontSize: "var(--type-ui-caption-size)" }}>Loading articles…</span>
      <style>{`
        @keyframes verso-spin {
          to { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
}
