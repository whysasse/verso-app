"use client";

import { useEffect, useState, useCallback, useRef } from "react";
import { useLocale, useTranslations } from "next-intl";
import { useParams, useRouter } from "next/navigation";
import * as FS from "@/services/FileSystemService";
import type { Article } from "@/types/article";
import {
  MarkdownRenderer,
  type FontFamily,
  type FontSize,
  type LineHeight,
} from "@/app/components/MarkdownRenderer";
import { useTheme, type VersoTheme } from "@/app/providers/ThemeProvider";

// ── Constants ────────────────────────────────────────────────────────

const FONT_FAMILIES: FontFamily[] = ["georgia", "system", "mono", "dyslexic"];

const FONT_SIZES: FontSize[] = [14, 16, 18, 20, 22, 26];

// docs/copy/UI_COPY.md's readerSettings.fontSize.{xs..xxl} are point-based step labels
// (XS=14pt .. XXL=26pt) that line up exactly with this array -- reusing them as the chip
// labels here instead of raw pixel numbers keeps Web's stepper in sync with iOS's wording.
const FONT_SIZE_LABEL_KEYS: Record<FontSize, string> = {
  14: "xs",
  16: "s",
  18: "m",
  20: "l",
  22: "xl",
  26: "xxl",
};

const LINE_HEIGHTS: LineHeight[] = ["compact", "normal", "relaxed", "airy"];

const THEMES: VersoTheme[] = ["paper", "sepia", "night", "ink"];

const PREF_KEY = "verso-reader-prefs";
const HINT_KEY = "verso-reader-hint-seen";

const IDLE_HIDE_MS = 2000;   // hide chrome after 2s idle
const IDLE_RESHOW_MS = 3000; // keep chrome visible for 3s after interaction (when controls closed)

interface ReaderPrefs {
  fontFamily: FontFamily;
  fontSize: FontSize;
  lineHeight: LineHeight;
}

function loadPrefs(): ReaderPrefs {
  try {
    const raw = localStorage.getItem(PREF_KEY);
    if (raw) return { fontFamily: "georgia", fontSize: 18, lineHeight: "relaxed", ...JSON.parse(raw) };
  } catch {}
  return { fontFamily: "georgia", fontSize: 18, lineHeight: "relaxed" };
}

function savePrefs(prefs: ReaderPrefs) {
  try { localStorage.setItem(PREF_KEY, JSON.stringify(prefs)); } catch {}
}

// docs/copy/UI_COPY.md §3 requires a locale-aware *medium* date style (see the same
// fix in ArticleCard.tsx) -- this previously hard-coded "en-CA" regardless of UI locale.
function formatDate(iso: string, locale: string): string {
  return new Intl.DateTimeFormat(locale, { dateStyle: "medium" }).format(
    new Date(iso + "T00:00:00"),
  );
}

// ── useIdleChrome ─────────────────────────────────────────────────────
// Chrome is visible on mount. After IDLE_HIDE_MS of no interaction it fades
// out. Any mousemove / touch / click makes it visible again for IDLE_RESHOW_MS.
// When the controls panel is open, the idle timer is suspended.

function useIdleChrome(controlsOpen: boolean) {
  const [visible, setVisible] = useState(true);
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const show = useCallback(() => {
    setVisible(true);
    if (timerRef.current) clearTimeout(timerRef.current);
    if (!controlsOpen) {
      timerRef.current = setTimeout(() => setVisible(false), IDLE_RESHOW_MS);
    }
  }, [controlsOpen]);

  // When controls close, restart the idle timer from current visibility
  useEffect(() => {
    if (!controlsOpen) {
      if (timerRef.current) clearTimeout(timerRef.current);
      timerRef.current = setTimeout(() => setVisible(false), IDLE_RESHOW_MS);
    } else {
      // controls open → keep visible, cancel timer
      if (timerRef.current) clearTimeout(timerRef.current);
      setVisible(true);
    }
    return () => { if (timerRef.current) clearTimeout(timerRef.current); };
  }, [controlsOpen]);

  // Attach interaction listeners
  useEffect(() => {
    const opts = { passive: true };
    window.addEventListener("mousemove", show, opts);
    window.addEventListener("touchstart", show, opts);
    window.addEventListener("keydown", show);
    // Initial hide timer
    timerRef.current = setTimeout(() => setVisible(false), IDLE_HIDE_MS);
    return () => {
      window.removeEventListener("mousemove", show);
      window.removeEventListener("touchstart", show);
      window.removeEventListener("keydown", show);
      if (timerRef.current) clearTimeout(timerRef.current);
    };
  }, [show]);

  return { chromeVisible: visible, showChrome: show };
}

// ── useScrollProgress ─────────────────────────────────────────────────

function useScrollProgress() {
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    function onScroll() {
      const el = document.documentElement;
      const scrollable = el.scrollHeight - el.clientHeight;
      setProgress(scrollable > 0 ? Math.min(el.scrollTop / scrollable, 1) : 0);
    }
    window.addEventListener("scroll", onScroll, { passive: true });
    onScroll();
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return progress;
}

// ── ScrollProgressBar ─────────────────────────────────────────────────

function ScrollProgressBar({ progress }: { progress: number }) {
  return (
    <div
      aria-hidden
      style={{
        position: "fixed",
        top: 0,
        left: 0,
        width: `${progress * 100}%`,
        height: 3,
        backgroundColor: "var(--color-accent)",
        zIndex: 30,
        transition: "width 0.1s linear",
        pointerEvents: "none",
      }}
    />
  );
}

// ── FirstUseHint ──────────────────────────────────────────────────────

function FirstUseHint({ onDismiss }: { onDismiss: () => void }) {
  const t = useTranslations("reading");
  const [fading, setFading] = useState(false);

  function dismiss() {
    setFading(true);
    setTimeout(onDismiss, 400);
  }

  return (
    <div
      onClick={dismiss}
      style={{
        position: "fixed",
        inset: 0,
        zIndex: 15,
        display: "flex",
        alignItems: "flex-end",
        justifyContent: "center",
        paddingBottom: "var(--spacing-3xl)",
        pointerEvents: "auto",
        opacity: fading ? 0 : 1,
        transition: "opacity 0.4s ease",
      }}
    >
      <div
        style={{
          backgroundColor: "var(--color-surface)",
          border: "1px solid var(--color-border)",
          borderRadius: "var(--radius-lg)",
          padding: "var(--spacing-sm) var(--spacing-lg)",
          fontSize: "var(--type-ui-caption-size)",
          color: "var(--color-text-secondary)",
          boxShadow: "0 4px 24px rgba(0,0,0,0.12)",
          pointerEvents: "none",
        }}
      >
        {t("immersiveHint")}
      </div>
    </div>
  );
}

// ── Chrome (nav + controls panel) ────────────────────────────────────

interface ChromeProps {
  visible: boolean;
  showControls: boolean;
  onToggleControls: () => void;
  prefs: ReaderPrefs;
  onPrefsChange: (p: ReaderPrefs) => void;
  article: Article;
  onMarkAsRead: () => void;
}

function Chrome({
  visible,
  showControls,
  onToggleControls,
  prefs,
  onPrefsChange,
  article,
  onMarkAsRead,
}: ChromeProps) {
  const { theme, setTheme } = useTheme();
  const t = useTranslations();

  const chromeStyle: React.CSSProperties = {
    opacity: visible ? 1 : 0,
    pointerEvents: visible ? "auto" : "none",
    transition: "opacity 0.3s ease",
  };

  return (
    <>
      {/* Top nav */}
      <header
        style={{
          ...chromeStyle,
          position: "fixed",
          top: 0,
          left: 0,
          right: 0,
          zIndex: 20,
          backgroundColor: "var(--color-background)",
          borderBottom: "1px solid var(--color-border)",
          padding: "var(--spacing-md) var(--spacing-lg)",
          display: "flex",
          alignItems: "center",
          gap: "var(--spacing-md)",
        }}
      >
        <BackButton />
        <div style={{ flex: 1 }} />
        <button
          onClick={onToggleControls}
          title={
            showControls
              ? t("web.reader.toggleControls.hide")
              : t("web.reader.toggleControls.show")
          }
          style={{
            ...iconButtonStyle,
            backgroundColor: showControls ? "var(--color-accent-surface)" : undefined,
            color: showControls ? "var(--color-accent)" : "var(--color-text-secondary)",
            borderColor: showControls ? "transparent" : undefined,
          }}
        >
          Aa
        </button>
      </header>

      {/* Bottom controls panel */}
      <div
        style={{
          ...chromeStyle,
          position: "fixed",
          bottom: 0,
          left: 0,
          right: 0,
          zIndex: 20,
          backgroundColor: "var(--color-background)",
          borderTop: "1px solid var(--color-border)",
          // Height collapses to 0 when closed; content fades with chrome
          maxHeight: showControls ? 260 : 0,
          overflow: "hidden",
          transition: "opacity 0.3s ease, max-height 0.25s ease",
        }}
      >
        <div
          style={{
            maxWidth: 680,
            margin: "0 auto",
            padding: "var(--spacing-md) var(--spacing-lg)",
            display: "flex",
            flexDirection: "column",
            gap: "var(--spacing-sm)",
          }}
        >
          {/* Font family */}
          <ControlRow label={t("settings.font.sectionLabel")}>
            {FONT_FAMILIES.map((value) => (
              <ChipButton
                key={value}
                active={prefs.fontFamily === value}
                onClick={() => onPrefsChange({ ...prefs, fontFamily: value })}
              >
                {t(`web.fontFamily.${value}`)}
              </ChipButton>
            ))}
          </ControlRow>

          {/* Font size */}
          <ControlRow label={t("readerSettings.fontSize.sectionLabel")}>
            {FONT_SIZES.map((size) => (
              <ChipButton
                key={size}
                active={prefs.fontSize === size}
                onClick={() => onPrefsChange({ ...prefs, fontSize: size })}
              >
                {t(`readerSettings.fontSize.${FONT_SIZE_LABEL_KEYS[size]}`)}
              </ChipButton>
            ))}
          </ControlRow>

          {/* Line height */}
          <ControlRow label={t("readerSettings.lineSpacing.sectionLabel")}>
            {LINE_HEIGHTS.map((value) => (
              <ChipButton
                key={value}
                active={prefs.lineHeight === value}
                onClick={() => onPrefsChange({ ...prefs, lineHeight: value })}
              >
                {t(`readerSettings.lineSpacing.${value}`)}
              </ChipButton>
            ))}
          </ControlRow>

          {/* Theme */}
          <ControlRow label={t("readerSettings.theme.sectionLabel")}>
            {THEMES.map((themeValue) => (
              <button
                key={themeValue}
                onClick={() => setTheme(themeValue)}
                title={t(`theme.${themeValue}`)}
                aria-label={t(`theme.${themeValue}`)}
                style={{
                  width: 24,
                  height: 24,
                  borderRadius: "50%",
                  border: theme === themeValue
                    ? "2px solid var(--color-accent)"
                    : "2px solid var(--color-border)",
                  cursor: "pointer",
                  padding: 0,
                  backgroundColor:
                    themeValue === "paper" ? "#F5F0E8"
                    : themeValue === "sepia" ? "#F2E8D5"
                    : themeValue === "night" ? "#1C1A16"
                    : "#111418",
                }}
              />
            ))}
          </ControlRow>

          {/* Mark as read */}
          {article.status !== "read" && (
            <div style={{ paddingTop: "var(--spacing-xxs)" }}>
              <button
                onClick={onMarkAsRead}
                style={{
                  padding: "var(--spacing-xs) var(--spacing-md)",
                  borderRadius: "var(--radius-pill)",
                  border: "none",
                  backgroundColor: "var(--color-accent)",
                  color: "var(--color-background)",
                  fontSize: "var(--type-ui-caption-size)",
                  fontWeight: 600,
                  cursor: "pointer",
                }}
              >
                {t("reading.controls.markAsRead")}
              </button>
            </div>
          )}
        </div>
      </div>
    </>
  );
}

// ── Small shared UI pieces ────────────────────────────────────────────

function BackButton() {
  const router = useRouter();
  const t = useTranslations("web.reader.backButton");
  return (
    <button
      onClick={() => router.back()}
      style={{
        background: "none",
        border: "none",
        color: "var(--color-accent)",
        fontSize: "var(--type-ui-button-size)",
        fontWeight: "var(--type-ui-button-weight)",
        cursor: "pointer",
        padding: 0,
        display: "flex",
        alignItems: "center",
        gap: "var(--spacing-xxs)",
      }}
    >
      ← {t("label")}
    </button>
  );
}

function ControlRow({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: "var(--spacing-xs)" }}>
      <span style={{
        fontSize: "var(--type-ui-caption-size)",
        color: "var(--color-text-secondary)",
        minWidth: 52,
        whiteSpace: "nowrap",
        flexShrink: 0,
      }}>
        {label}
      </span>
      <div style={{ display: "flex", gap: "var(--spacing-xxs)", flexWrap: "wrap" }}>
        {children}
      </div>
    </div>
  );
}

function ChipButton({
  active, onClick, children,
}: {
  active: boolean; onClick: () => void; children: React.ReactNode;
}) {
  return (
    <button
      onClick={onClick}
      style={{
        padding: "4px var(--spacing-xs)",
        borderRadius: "var(--radius-pill)",
        border: `1px solid ${active ? "transparent" : "var(--color-border)"}`,
        backgroundColor: active ? "var(--color-accent-surface)" : "var(--color-surface)",
        color: active ? "var(--color-accent)" : "var(--color-text-secondary)",
        fontSize: "var(--type-ui-caption-size)",
        fontWeight: active ? 600 : 400,
        cursor: "pointer",
        whiteSpace: "nowrap",
      }}
    >
      {children}
    </button>
  );
}

const iconButtonStyle: React.CSSProperties = {
  background: "none",
  border: "1px solid var(--color-border)",
  borderRadius: "var(--radius-sm)",
  color: "var(--color-text-secondary)",
  fontSize: "var(--type-ui-button-size)",
  fontWeight: 600,
  padding: "4px var(--spacing-xs)",
  cursor: "pointer",
  lineHeight: 1,
  transition: "background-color 0.15s ease, color 0.15s ease",
};

// ── Main page ─────────────────────────────────────────────────────────

export default function ArticleReaderPage() {
  const params = useParams();
  const filename = decodeURIComponent(params.id as string);
  const locale = useLocale();
  const t = useTranslations("web.reader.error");
  const tBackToLibrary = useTranslations("web.reader.backToLibrary");

  const [article, setArticle] = useState<Article | null>(null);
  const [fsHandle, setFsHandle] = useState<FileSystemDirectoryHandle | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [prefs, setPrefs] = useState<ReaderPrefs>({ fontFamily: "georgia", fontSize: 18, lineHeight: "relaxed" });
  const [showControls, setShowControls] = useState(false);
  const [showHint, setShowHint] = useState(false);

  // Refs for one-shot status transitions and debounced scroll save
  const scrollSaveTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const didMarkReadingRef = useRef(false);
  const didMarkReadRef = useRef(false);

  const { chromeVisible, showChrome } = useIdleChrome(showControls);
  const scrollProgress = useScrollProgress();

  // Load prefs
  useEffect(() => { setPrefs(loadPrefs()); }, []);

  // First-use hint: show once per device
  useEffect(() => {
    const seen = localStorage.getItem(HINT_KEY);
    if (!seen) setShowHint(true);
  }, []);

  function dismissHint() {
    setShowHint(false);
    localStorage.setItem(HINT_KEY, "1");
  }

  // Load article
  useEffect(() => {
    async function load() {
      setLoading(true);
      setError(null);
      try {
        let handle = await FS.getSavedFolder();
        if (!handle) {
          setError(t("noFolder"));
          return;
        }
        const perm = await handle.queryPermission({ mode: "readwrite" });
        if (perm !== "granted") {
          const granted = await FS.requestFolderPermission(handle);
          if (!granted) {
            setError(t("permissionDenied"));
            return;
          }
          handle = (await FS.getSavedFolder())!;
        }
        setFsHandle(handle);
        const loaded = await FS.readArticle(handle, filename);
        if (!loaded) {
          setError(t("articleNotFound", { filename }));
        } else {
          setArticle(loaded);
        }
      } catch (e) {
        setError(e instanceof Error ? e.message : t("loadFailed"));
      } finally {
        setLoading(false);
      }
    }
    load();
  }, [filename, t]);

  const handlePrefsChange = useCallback((next: ReaderPrefs) => {
    setPrefs(next);
    savePrefs(next);
  }, []);

  const handleMarkAsRead = useCallback(async () => {
    if (!article || !fsHandle) return;
    const updated: Article = { ...article, status: "read" };
    try {
      await FS.writeArticle(fsHandle, updated);
      setArticle(updated);
    } catch {}
  }, [article, fsHandle]);

  // Reset one-shot flags when a new article loads
  useEffect(() => {
    didMarkReadingRef.current = false;
    didMarkReadRef.current = false;
  }, [article?.filename]);

  // Restore scroll position after content renders (two rAFs to let browser reflow)
  useEffect(() => {
    if (!article?.scroll_position) return;
    const target = article.scroll_position;
    let rafId1: number;
    let rafId2: number;
    rafId1 = requestAnimationFrame(() => {
      rafId2 = requestAnimationFrame(() => {
        const el = document.documentElement;
        const scrollable = el.scrollHeight - el.clientHeight;
        if (scrollable > 0) {
          window.scrollTo({ top: scrollable * target, behavior: "instant" });
        }
      });
    });
    return () => {
      cancelAnimationFrame(rafId1);
      cancelAnimationFrame(rafId2);
    };
  }, [article?.filename]); // only on new article, not on every position update

  // Auto-status: unread → reading on open
  useEffect(() => {
    if (!article || !fsHandle) return;
    if (article.status !== "unread") return;
    if (didMarkReadingRef.current) return;
    didMarkReadingRef.current = true;
    const updated: Article = { ...article, status: "reading" };
    FS.writeArticle(fsHandle, updated).then(() => setArticle(updated)).catch(() => {});
  }, [article?.filename, fsHandle]); // eslint-disable-line react-hooks/exhaustive-deps

  // Auto-status: reading → read at 90% scroll
  useEffect(() => {
    if (!article || !fsHandle) return;
    if (article.status === "read" || article.status === "archived") return;
    if (scrollProgress < 0.9) return;
    if (didMarkReadRef.current) return;
    didMarkReadRef.current = true;
    const updated: Article = { ...article, status: "read" };
    FS.writeArticle(fsHandle, updated).then(() => setArticle(updated)).catch(() => {});
  }, [scrollProgress, article?.status, fsHandle]); // eslint-disable-line react-hooks/exhaustive-deps

  // Persist scroll position to frontmatter (debounced 500ms)
  useEffect(() => {
    if (!article || !fsHandle) return;
    if (scrollSaveTimerRef.current) clearTimeout(scrollSaveTimerRef.current);
    scrollSaveTimerRef.current = setTimeout(async () => {
      const updated: Article = { ...article, scroll_position: scrollProgress };
      try {
        await FS.writeArticle(fsHandle, updated);
        setArticle(updated);
      } catch {}
    }, 500);
    return () => {
      if (scrollSaveTimerRef.current) clearTimeout(scrollSaveTimerRef.current);
    };
  }, [scrollProgress]); // eslint-disable-line react-hooks/exhaustive-deps

  // Click on reading area: show chrome (and dismiss hint)
  function handleReadingAreaClick() {
    showChrome();
    if (showHint) dismissHint();
  }

  // Controls panel bottom padding
  const controlsPanelHeight = showControls ? 220 : 0;
  const contentPaddingBottom = 64 + controlsPanelHeight;

  // ── Loading / error states ──────────────────────────────────────────

  if (loading) {
    return (
      <div style={centeredStyle}>
        <div style={spinnerStyle} />
        <style>{spinnerCSS}</style>
      </div>
    );
  }

  if (error || !article) {
    return (
      <div style={{ ...centeredStyle, flexDirection: "column", gap: "var(--spacing-sm)" }}>
        <p style={{
          color: "var(--color-error)",
          fontSize: "var(--type-ui-list-subtitle-size)",
          textAlign: "center",
          maxWidth: 320,
        }}>
          {error ?? t("fallback")}
        </p>
        <a href="/" style={{ color: "var(--color-accent)", fontSize: "var(--type-ui-caption-size)" }}>
          ← {tBackToLibrary("label")}
        </a>
      </div>
    );
  }

  return (
    <div
      style={{ minHeight: "100dvh", backgroundColor: "var(--color-background)" }}
      onClick={handleReadingAreaClick}
    >
      {/* Scroll progress bar — always visible */}
      <ScrollProgressBar progress={scrollProgress} />

      {/* Auto-hiding chrome */}
      <Chrome
        visible={chromeVisible}
        showControls={showControls}
        onToggleControls={() => setShowControls((v) => !v)}
        prefs={prefs}
        onPrefsChange={handlePrefsChange}
        article={article}
        onMarkAsRead={handleMarkAsRead}
      />

      {/* First-use hint */}
      {showHint && <FirstUseHint onDismiss={dismissHint} />}

      {/* Reading area */}
      <article
        style={{
          maxWidth: 680,
          margin: "0 auto",
          padding: `calc(var(--spacing-3xl) + 56px) var(--spacing-lg) ${contentPaddingBottom}px`,
          boxSizing: "border-box",
        }}
      >
        {/* Article header */}
        <header style={{ marginBottom: "var(--spacing-xl)" }}>
          <h1
            style={{
              fontSize: "var(--type-reading-h1-size)",
              fontWeight: "var(--type-reading-h1-weight)",
              lineHeight: "var(--type-reading-h1-line-height)",
              color: "var(--color-text-primary)",
              margin: "0 0 var(--spacing-sm)",
            }}
          >
            {article.title}
          </h1>
          <p style={{
            fontSize: "var(--type-ui-caption-size)",
            color: "var(--color-text-secondary)",
            margin: 0,
            display: "flex",
            gap: "var(--spacing-xs)",
            flexWrap: "wrap",
          }}>
            {article.site_name && <span>{article.site_name}</span>}
            {article.site_name && article.added && <span>·</span>}
            {article.added && <span>{formatDate(article.added, locale)}</span>}
            {article.author && <><span>·</span><span>{article.author}</span></>}
          </p>
          {article.url && (
            <a
              href={article.url}
              target="_blank"
              rel="noopener noreferrer"
              onClick={(e) => e.stopPropagation()} // don't toggle chrome on link click
              style={{
                display: "inline-block",
                marginTop: "var(--spacing-xs)",
                fontSize: "var(--type-ui-caption-size)",
                color: "var(--color-accent)",
                textDecoration: "none",
                overflow: "hidden",
                textOverflow: "ellipsis",
                whiteSpace: "nowrap",
                maxWidth: "100%",
              }}
            >
              {article.url}
            </a>
          )}
          <hr style={{
            border: "none",
            borderTop: "1px solid var(--color-border)",
            marginTop: "var(--spacing-lg)",
            marginBottom: 0,
          }} />
        </header>

        {/* Body */}
        <MarkdownRenderer
          content={article.body}
          fontFamily={prefs.fontFamily}
          fontSize={prefs.fontSize}
          lineHeight={prefs.lineHeight}
        />
      </article>
    </div>
  );
}

// ── Inline styles ─────────────────────────────────────────────────────

const centeredStyle: React.CSSProperties = {
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
  minHeight: "100dvh",
};

const spinnerStyle: React.CSSProperties = {
  width: 24,
  height: 24,
  border: "2px solid var(--color-border)",
  borderTopColor: "var(--color-accent)",
  borderRadius: "50%",
  animation: "verso-spin 0.7s linear infinite",
};

const spinnerCSS = `@keyframes verso-spin { to { transform: rotate(360deg); } }`;
