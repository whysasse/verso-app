# Figma Design System Reference — Verso

**Version:** 1.4
**Date:** 2026-05-01
**Source:** `docs/DESIGN_SYSTEM_FOUNDATIONS.md` v1.6

---

## 1. Color Variables

### 1.1 Structure in Figma

Colors are implemented as a **multi-mode variable collection** named `Verso/Colors` in the Figma Variables panel. The collection has four modes — one per theme — and each variable holds the correct value for each mode. This allows a single variable reference to automatically resolve to the right color when the mode is switched.

**Collection name:** `Verso/Colors`
**Modes:** `paper` (default) · `sepia` · `night` · `ink`

### 1.2 Variable naming convention

Format: `color/{role}` (e.g., `color/background`, `color/text-primary`)

Each variable carries values for all four modes. Figma resolves the correct value at design time based on the active mode set on the frame or page.

---

### Variable definitions

| Variable name | Paper | Sepia | Night | Ink |
|--------------|-------|-------|-------|-----|
| `color/background` | `#F5F0E8` | `#F2E8D5` | `#1C1A16` | `#111418` |
| `color/text-primary` | `#2C2924` | `#2E2013` | `#E8E0D0` | `#E4E6EB` |
| `color/text-secondary` | `#6E675F` | `#755E40` | `#8F897F` | `#7E8492` |
| `color/surface` | `#EDE8DF` | `#E8DEC7` | `#252320` | `#181C22` |
| `color/accent` | `#766655` | `#825A37` | `#C4A97D` | `#7B9FD4` |
| `color/accent-pressed` | `#584D40` | `#614429` | `#937F5E` | `#5C779F` |
| `color/accent-surface` | `rgba(#766655, 15%)` | `rgba(#825A37, 15%)` | `rgba(#C4A97D, 15%)` | `rgba(#7B9FD4, 15%)` |
| `color/placeholder` | `#CEC8BC` | `#C8BCA0` | `#302E2A` | `#202630` |
| `color/border` | `#DDD8CE` | `#D9CAAC` | `#2E2B26` | `#1E2228` |
| `color/error` | `#C0392B` | `#C0392B` | `#F87171` | `#FC8181` |
| `color/warning` | `#B45309` | `#B45309` | `#FCD34D` | `#F6E05E` |
| `color/success` | `#166534` | `#166534` | `#4ADE80` | `#68D391` |

**Total: 12 color variables × 4 modes = 48 values.**

### 1.4 accent-surface: usage and Figma implementation

`color/accent-surface` is a 15%-opacity tint of the theme's accent color. Use it as the **background** for any element whose **text or icon is `color/accent`** — so the combination reads as a coherent selected/active state without using a fully saturated fill.

**When to use:**
- `FilterChip` selected state — accent-surface background + accent label text
- Any chip, tag, or badge where the label uses `color/accent` and needs a background hint
- Inline selection indicators or highlight bars

**When NOT to use:**
- As a standalone background without accent-colored text (too subtle to carry meaning on its own)
- As a text color (it is always a fill, never a foreground color)
- As a replacement for `color/accent` on interactive controls (buttons, links)

**Figma implementation note:**

Because Figma encodes a color variable's alpha channel through the paint's `opacity` property (not through `color.a`), apply `accent-surface` as follows:

```
Fill type:    SOLID
Color:        bound to color/accent-surface  ← variable binding
Paint opacity: 0.15                          ← matches the variable's a=0.15
```

Do **not** set `paint.opacity = 1` — that will render the fill as a fully opaque accent color. The 0.15 opacity on the paint object is load-bearing; it is not a duplicate of the variable's alpha.

### 1.3 Fixed colors (not variables)

Some values are intentionally fixed — they do not change across themes:

| Use | Value | Reason |
|-----|-------|--------|
| Button label (PrimaryButton) | `#FFFFFF` | White text must be legible on all accent backgrounds. Not theme-dependent. |
| ImmersiveHintPill background | `rgba(0,0,0,0.70)` | Must be legible on all four themes simultaneously. |

---

## 2. Typography

### 2.1 Font family

UI elements (everything outside the Reading View) use **SF Pro**. Reading View uses the user's selected font (New York by default).

| Context | Font family | Notes |
|---------|------------|-------|
| All UI screens | `SF Pro` | Available in Figma if SF Pro is installed on macOS |
| Reading body text | `New York` | System serif — only in Reading View |
| Dyslexia option | `OpenDyslexic` | Bundled in app — not a system font |

### 2.2 UI text styles (SF Pro)

Create these as named **Text Styles** in Figma.

| Style name | Family | Size | Weight | Line height |
|-----------|--------|------|--------|------------|
| `type/ui/screen-title` | SF Pro | 34pt | Bold | 1.2× |
| `type/ui/list-title` | SF Pro | 17pt | Semibold | 1.3× |
| `type/ui/list-subtitle` | SF Pro | 15pt | Regular | 1.4× |
| `type/ui/button` | SF Pro | 17pt | Semibold | 1.0× |
| `type/ui/input` | SF Pro | 17pt | Regular | 1.3× |
| `type/ui/caption` | SF Pro | 13pt | Regular | 1.3× |

### 2.3 Reading body text styles (New York)

| Style name | Family | Size | Weight | Line height |
|-----------|--------|------|--------|------------|
| `type/body/xs` | New York | 14pt | Regular | 1.75× |
| `type/body/s` | New York | 16pt | Regular | 1.75× |
| `type/body/m` | New York | 18pt | Regular | 1.75× |
| `type/body/l` | New York | 20pt | Regular | 1.75× |
| `type/body/xl` | New York | 22pt | Regular | 1.6× |
| `type/body/xxl` | New York | 26pt | Regular | 1.5× |

### 2.4 Article heading styles (New York)

| Style name | Family | Size | Weight | Line height |
|-----------|--------|------|--------|------------|
| `type/heading/h1` | New York | 28pt | Bold | 1.2× |
| `type/heading/h2` | New York | 24pt | Semibold | 1.25× |
| `type/heading/h3` | New York | 20pt | Semibold | 1.3× |
| `type/heading/h4` | New York | 18pt | Semibold | 1.35× |

---

## 3. Spacing Tokens

**Collection:** `Verso/Spacing` (single-mode)

| Variable name | Value | Usage |
|--------------|-------|-------|
| `spacing/xxs` | 4px | Minimal inline gaps |
| `spacing/xs` | 8px | Tight component spacing |
| `spacing/sm` | 12px | Filter chip interior |
| `spacing/md` | 16px | Standard content padding |
| `spacing/lg` | 24px | Section spacing |
| `spacing/xl` | 32px | Major section divisions |
| `spacing/2xl` | 48px | Screen-level rhythm |
| `spacing/3xl` | 64px | Extra breathing room |

---

## 3b. Corner Radius Tokens

**Collection:** `Verso/Radius` (single-mode)

| Variable name | Value | Usage |
|--------------|-------|-------|
| `radius/sm` | 10pt | Inputs, search bars |
| `radius/md` | 12pt | Cards, buttons, sheets |
| `radius/lg` | 18pt | Chips (fully rounded at 36pt height) |
| `radius/pill` | 20pt | Pill elements (fully rounded at 40pt height) |

---

## 4. Component Library

Components live on the **🧩 Components** page in the Figma file. All components use `color/*` variables from the `Verso/Colors` collection and resolve correctly when the active mode is changed.

**Navigation model:** Verso uses a NavigationStack (push/pop). There is no tab bar component. See `docs/component-inventory.md` and `docs/navigation-patterns.md`.

---

### 4.1 Button / Primary

| Property | Value |
|----------|-------|
| Figma name | `Button/Primary` |
| Variants | `State=Default`, `State=Pressed`, `State=Disabled` |
| Height | 50pt (fixed) |
| Corner radius | 12pt |
| Font | SF Pro Semibold, 17pt |
| Text color | `#FFFFFF` (fixed white — not a variable) |
| Background (Default) | `color/accent` |
| Background (Pressed) | `color/accent-pressed` |
| Background (Disabled) | `color/accent` at 40% opacity (component-level opacity) |

---

### 4.2 Input / Text

| Property | Value |
|----------|-------|
| Figma name | `Input/Text` |
| Variants | `State=Default`, `State=Focused`, `State=Error`, `State=Disabled` |
| Width | 320pt (fixed) |
| Height | Auto (padding-driven, ~48pt) |
| Corner radius | 10pt |
| Font | SF Pro Regular, 17pt |
| Background | `color/surface` |
| Border (Default) | 1pt `color/divider` |
| Border (Focused) | 2pt `color/accent` |
| Border (Error) | 2pt `color/error` |
| Disabled | 40% component-level opacity |
| Placeholder text color | `color/text-secondary` |
| Active text color | `color/text-primary` |
| Error text color | `color/error` |

---

### 4.3 Card

| Property | Value |
|----------|-------|
| Figma name | `Card` |
| Variants | `Type=Book`, `Type=Article` |
| Width | 200pt (fixed) |
| Corner radius | 12pt |
| Background | `color/surface` |
| Cover image placeholder | `color/placeholder` |

**Typography (content area):**

| Element | Font | Size | Weight | Color |
|---------|------|------|--------|-------|
| Title | SF Pro | 17pt | Semibold | `color/text-primary` |
| Source / subtitle | SF Pro | 15pt | Regular | `color/text-secondary` |
| Date | SF Pro | 13pt | Regular | `color/text-secondary` |

---

### 4.4 FilterChip / FilterChipBar

| Property | Value |
|----------|-------|
| Figma name | `FilterChip` (Component Set) · `FilterChipBar` (Component) |
| Variants | `State=Selected`, `State=Unselected` |
| Height | 36pt (fixed) |
| Corner radius | `radius/lg` (18pt) — fully rounds the 36pt height |
| Font | SF Pro Regular, 15pt |

**State=Selected:**

| Layer | Token | Notes |
|-------|-------|-------|
| Background | `color/accent-surface` at `opacity: 0.15` | See §1.4 — paint opacity encodes the variable's alpha |
| Label text | `color/accent` | Accent text over accent-surface background |
| Count text | `color/accent` | Same as label |

**State=Unselected:**

| Layer | Token | Notes |
|-------|-------|-------|
| Background | None (transparent) | — |
| Label text | `color/text-secondary` | Muted, visually subordinate |
| Count text | `color/text-secondary` | Same as label |

**Rationale:** The selected state pairs `accent-surface` (background) with `color/accent` (text) to create a clear, coherent active indicator without a heavy filled button. The 15% tint is subtle enough that it doesn't visually compete with the article content below the bar.

---

### 4.5 Navigation Bar

| Property | Value |
|----------|-------|
| Figma name | `Navigation Bar` |
| Width | 375pt (fixed) |
| Height | 44pt (fixed) |
| Font | SF Pro Semibold, 17pt |
| Title color | `color/text-primary` |
| Background | `color/background` |
| Divider (bottom) | 0.5pt `color/divider` |
| Back / Action touch areas | 44×44pt (per DS §6.1 minimum touch target) |
| Icon color | `color/accent` |

---

## 5. Figma File Pages

**File key:** `WCPHZNg1my8VSSMbLO5bvX`  
**File URL:** `https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI`

| Page | Node ID | URL |
|------|---------|-----|
| 🧩 Components | `13-201` | [Open](https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI?node-id=13-201) |
| 📱 Home — Reading List | `30-41` | [Open](https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI?node-id=30-41) |

### Components Page Sections

The 🧩 Components page is organized into 7 labeled sections:

| Section | Components |
|---------|-----------|
| **Buttons** | `Button/Primary`, `Button/Secondary`, `Button/Text`, `Button/Icon` — each as a Component Set with Default / Pressed / Disabled states |
| **Forms & Inputs** | `Input/Text` (Default / Focused / Error / Disabled), `SearchBar` (Default / Focused / Disabled), `FilterChip` (Selected / Unselected), `FilterChipBar` |
| **Indicators** | `StatusBadge` (Unread / Reading / Read) |
| **Navigation** | `NavigationBar` (HasBackButton=True / False) |
| **Cards & Lists** | `Card` (Book / Article), `ArticleCard` (Unread / Reading / Read), `EmptyState` (All / Unread / Reading / Read filters) |
| **Reading** | `ReadingChrome/TopBar`, `ReadingChrome/BottomBar`, `ImmersiveHintPill`, `ReadingControls` |
| **Settings** | `SettingsRow` (Theme / Font / Folder / Default types), `ThemeSelector` |

All component fills and strokes are bound to `Verso/Colors` variables — switching the variable mode to `sepia`, `night`, or `ink` propagates theme colors throughout all components automatically.

**Note:** `ImmersiveHintPill` uses a fixed semi-transparent dark fill (not a theme variable) per the design spec — it must remain legible against any reading theme.

**Note:** `ThemeSelector` chip backgrounds are hard-coded raw hex values (`#F5F0E8`, `#F2E8D5`, `#1C1A16`, `#111418`) rather than `color/background` variable bindings. This is intentional: the component displays all four theme swatches simultaneously, so it cannot rely on a single active variable mode to resolve the correct color per chip. Do not rebind these fills to `color/background` in lint or variable audits.

---

## 6. Verify Against Source

All values must match `docs/DESIGN_SYSTEM_FOUNDATIONS.md` exactly. Do not round, approximate, or substitute iOS system defaults.

---

## 6. Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.5 | 2026-05-01 | Documented `ThemeSelector` hard-coded chip background exception (§4). |
| 1.4 | 2026-05-01 | Added `color/accent-surface` variable (12th token, 48 total values). Added §1.4 documenting accent-surface usage rules and Figma's paint-opacity encoding of variable alpha. Added FilterChip / FilterChipBar component spec (§4.4) documenting selected vs. unselected token usage. |
| 1.3 | 2026-04-20 | Added `Verso/Radius` collection (§3b) with 4 tokens. Added `type/ui/input` text style (SF Pro Regular 17pt). Updated source to DS v1.6. |
| 1.2 | 2026-04-20 | Added `color/placeholder` variable (11th token, 44 total values). Updated Card spec: cover image fill now uses `color/placeholder` instead of `color/divider`. |
| 1.1 | 2026-04-20 | Updated color variable structure to multi-mode collection (`Verso/Colors` with modes paper/sepia/night/ink). Added Component Library section (§4) documenting Button/Primary, Input/Text, Card, Navigation Bar. Added fixed color values table (§1.3). Updated typography to SF Pro for all UI. Clarified no tab bar component exists. |
| 1.0 | 2026-04-19 | Initial document. Color variables, typography text styles, spacing tokens, and setup instructions. |
