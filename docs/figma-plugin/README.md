# Verso Design System — Figma Plugin

This plugin creates all design tokens (colors, typography, spacing) in Figma based on `docs/DESIGN_SYSTEM_FOUNDATIONS.md` v1.4.

## What it creates

### Color Tokens (36 total)
- **Paper** theme: 9 tokens (background, text-primary, text-secondary, surface, accent, divider, error, warning, success)
- **Sepia** theme: 9 tokens
- **Night** theme: 9 tokens
- **Ink** theme: 9 tokens

Naming: `color/{theme}/{role}` (e.g., `color/paper/background`)

### Typography Text Styles (15 total)
- **Body text** (New York): 6 styles (xs, s, m, l, xl, xxl)
- **Headings** (New York): 4 styles (h1, h2, h3, h4)
- **UI** (San Francisco): 5 styles (title, list-title, list-subtitle, button, caption)

Naming: `type/{context}/{size}` (e.g., `type/body/m`)

### Spacing Tokens
- Reference frame with 8 spacing values (xxs → 3xl)

## How to use

1. Open the Figma file: https://www.figma.com/design/WCPHZNg1my8VSSMbLO5bvX/Reader-UI
2. Go to **Plugins** → **Development** → **Import plugin from file...**
3. Select `manifest.json` from this folder
4. Click **Run** to create all tokens

## Notes

- The plugin will remove any existing Verso styles before creating new ones (clean install)
- If fonts are not available (e.g., New York on non-Apple devices), those styles will be skipped
- After running, refresh the Styles panel to see the new tokens