# FAB-170 — Scroll position persistence + auto-status progression (Web)

**Issue:** Mirror the iOS reading progress tracking — save `scroll_position` to YAML frontmatter on scroll and auto-update article status.  
**File:** `verso-web/app/article/[id]/page.tsx` (all changes here — `FileSystemService` is already ready)

---

## What's already in place

Before touching anything, note what the codebase already has:

- `Article.scroll_position?: number` (0–1) in `types/article.ts`
- `parseArticle()` reads `scroll_position` from frontmatter
- `serialiseFrontmatter()` writes `scroll_position` with 4 decimal places
- `writeArticle()` persists a full article back to the `.md` file
- `useScrollProgress()` in `page.tsx` already computes the 0–1 ratio and feeds the visual progress bar
- `handleMarkAsRead()` already calls `writeArticle()` — the pattern for status writes

The four tasks below are purely additive changes to `page.tsx`.

---

## Tasks

### 1. Restore scroll position on article open

**Where:** in the `useEffect([article])` that loads the article, after `setArticle(loaded)`, or as a separate `useEffect([article])`.

**How:**

After `article` is set, if `article.scroll_position` is defined and > 0, scroll the window to the matching position. The DOM isn't laid out yet when React sets state, so wait two animation frames before measuring:

```ts
useEffect(() => {
  if (!article?.scroll_position) return;
  const target = article.scroll_position;
  // Two rAFs: first lets React paint, second lets browser reflow
  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      const el = document.documentElement;
      const scrollable = el.scrollHeight - el.clientHeight;
      if (scrollable > 0) {
        window.scrollTo({ top: scrollable * target, behavior: "instant" });
      }
    });
  });
}, [article?.filename]); // key on filename, not the whole article object
```

Use `behavior: "instant"` — animated scroll on open looks like a bug.  
Key the effect on `article?.filename` so it only fires when a *new* article loads, not on every status/position update.

---

### 2. Persist scroll position on scroll (debounced 500ms)

**Where:** new `useEffect` in the main page component watching `scrollProgress`.

`scrollProgress` already updates on every scroll event via the existing `useScrollProgress()` hook. Watch it and debounce writes:

```ts
const scrollSaveTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

useEffect(() => {
  if (!article || !fsHandle) return;
  if (scrollSaveTimerRef.current) clearTimeout(scrollSaveTimerRef.current);
  scrollSaveTimerRef.current = setTimeout(async () => {
    const updated = { ...article, scroll_position: scrollProgress };
    try {
      await FS.writeArticle(fsHandle, updated);
      setArticle(updated); // keep local state in sync
    } catch {}
  }, 500);
  return () => {
    if (scrollSaveTimerRef.current) clearTimeout(scrollSaveTimerRef.current);
  };
}, [scrollProgress]); // eslint-disable-line react-hooks/exhaustive-deps
  // article and fsHandle are stable refs once loaded; listing them would
  // cause spurious saves on status changes
```

**Why this approach:** `scrollProgress` is already computed — no new scroll listener needed. The 500ms debounce matches iOS. Writing the full article object (not a partial patch) is consistent with how `handleMarkAsRead` works and avoids a separate partial-write API.

**Note on the exhaustive-deps lint rule:** `article` and `fsHandle` deliberately omitted from deps — they're stable after load and including them would fire the effect on every status write, creating a write loop. Add an `// eslint-disable-line` comment.

---

### 3. Auto-status: `unread → reading` on open

**Where:** new `useEffect([article?.filename, fsHandle])`.

Fire once per article load. Use a `useRef` flag so it only runs once even if the effect re-runs:

```ts
const didMarkReadingRef = useRef(false);

useEffect(() => {
  didMarkReadingRef.current = false; // reset on new article
}, [article?.filename]);

useEffect(() => {
  if (!article || !fsHandle) return;
  if (article.status !== 'unread') return;
  if (didMarkReadingRef.current) return;
  didMarkReadingRef.current = true;

  const updated = { ...article, status: 'reading' as const };
  FS.writeArticle(fsHandle, updated).then(() => setArticle(updated)).catch(() => {});
}, [article?.filename, fsHandle]);
```

**Why immediately on open (not on first scroll):** Matches iOS behavior (`ArticleReaderView.onAppear`). An article you open but don't scroll has still been "started."

---

### 4. Auto-status: `reading → read` at 90% scroll

**Where:** new `useEffect([scrollProgress, article?.status, fsHandle])`.

Use a second `useRef` flag to fire the transition exactly once:

```ts
const didMarkReadRef = useRef(false);

useEffect(() => {
  didMarkReadRef.current = false;
}, [article?.filename]);

useEffect(() => {
  if (!article || !fsHandle) return;
  if (article.status === 'read' || article.status === 'archived') return;
  if (scrollProgress < 0.9) return;
  if (didMarkReadRef.current) return;
  didMarkReadRef.current = true;

  const updated = { ...article, status: 'read' as const };
  FS.writeArticle(fsHandle, updated).then(() => setArticle(updated)).catch(() => {});
}, [scrollProgress, article?.status, fsHandle]);
```

**Why 0.9, not 1.0:** Reaching true 1.0 requires pixel-perfect scroll to the very bottom, which many articles never reach due to padding. 90% is the iOS threshold and is reliable in practice.

**Why guard `archived`:** An archived article reopened shouldn't be bumped back to `read`.

---

## Write order on a typical session

When a user opens and reads an article to completion, writes happen in this order:

1. Article opens → `unread → reading` write (task 3)
2. User scrolls → debounced `scroll_position` writes every 500ms idle (task 2)
3. User reaches 90% → `reading → read` write (task 4); scroll_position continues saving
4. User re-opens article → scroll restored to saved position (task 1), status already `read` so no status write fires

---

## Verification checklist (from backlog)

- [ ] Open article → scroll halfway → close tab → re-open → scrolled to same position
- [ ] Article status in list view shows "Reading" after opening a previously unread article
- [ ] Article status auto-advances to "Read" after scrolling past 90%
- [ ] Open a `.md` file in a text editor after the session — `scroll_position` and `status` are updated in YAML frontmatter
- [ ] Open the same file on iOS (after iCloud sync) — status and position reflected correctly

---

## Non-goals for this issue

- No scroll restoration for articles at `scroll_position: 0` or `undefined` (correct — open from the top)
- No new dependencies — all primitives exist
- No changes to `FileSystemService.ts` or `types/article.ts`
