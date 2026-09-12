#!/usr/bin/env python3
"""Check that docs/DESIGN_TOKENS.md and verso-web/app/globals.css agree.

Covers every token category DESIGN_TOKENS.md documents: theme-dependent
colors, theme-independent colors (status dots, the reading highlight),
spacing, corner radius, and typography (UI + reading, including the
shared-vs-overridden body line-heights). Mechanical only — it does not
judge whether a value is *right*, only whether the two files agree.
"""
import re
import sys
import pathlib

REPO = pathlib.Path(__file__).resolve().parents[2]
TOKENS_MD = REPO / "docs" / "DESIGN_TOKENS.md"
GLOBALS_CSS = REPO / "verso-web" / "app" / "globals.css"

failures = []


def fail(msg):
    failures.append(msg)


def camel_to_kebab(name):
    return re.sub(r"(?<!^)(?=[A-Z])", "-", name).lower()


def section(text, header_pattern, stop_pattern=r"\n#{2,3} |\Z"):
    m = re.search(header_pattern + r"\n(.*?)(?=" + stop_pattern + r")", text, re.S)
    return m.group(1) if m else None


def extract_css_vars(block):
    return dict(re.findall(r"--([\w-]+):\s*([^;]+);", block))


def hex_to_rgb(hexval):
    hexval = hexval.lstrip("#")
    return tuple(int(hexval[i : i + 2], 16) for i in (0, 2, 4))


def values_match(css_var, expected, actual):
    """String-equal, except line-height vars compare numerically — CSS authors
    write bare '1' where the doc writes '1.0×', and that's not real drift."""
    if css_var.endswith("-line-height"):
        try:
            return abs(float(expected) - float(actual)) < 1e-6
        except ValueError:
            return expected == actual
    return expected == actual


def css_color_matches(doc_hex, doc_opacity_pct, css_value):
    css_value = css_value.strip()
    if doc_opacity_pct is None:
        return css_value.lower() == doc_hex.lower()
    m = re.match(
        r"rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d.]+)\s*\)", css_value
    )
    if not m:
        return False
    r, g, b, a = int(m.group(1)), int(m.group(2)), int(m.group(3)), float(m.group(4))
    dr, dg, db = hex_to_rgb(doc_hex)
    return (r, g, b) == (dr, dg, db) and abs(a - doc_opacity_pct / 100) < 0.005


if not TOKENS_MD.exists():
    print(f"check-token-parity: {TOKENS_MD} not found")
    sys.exit(1)
if not GLOBALS_CSS.exists():
    print(f"check-token-parity: {GLOBALS_CSS} not found")
    sys.exit(1)

md = TOKENS_MD.read_text()
css = GLOBALS_CSS.read_text()

root_block = section(css, r":root\s*\{")
root_vars = extract_css_vars(root_block) if root_block else {}

theme_vars = {}
for theme in ["paper", "sepia", "night", "ink"]:
    block = section(css, rf'\[data-theme="{theme}"\]\s*\{{', stop_pattern=r"\n\}")
    theme_vars[theme] = extract_css_vars(block) if block else {}
    if not theme_vars[theme]:
        fail(f"[data-theme=\"{theme}\"] block not found (or empty) in globals.css")

# ---- Color tokens: theme-dependent ----
COLOR_TOKENS = [
    "background", "surface", "textPrimary", "textSecondary", "accent",
    "accentPressed", "accentSurface", "border", "placeholder", "error",
    "warning", "success", "warningSurface", "errorSurface",
]
THEMES = ["Paper", "Sepia", "Night", "Ink"]


def parse_color_table(text):
    rows = re.findall(
        r"\|\s*(Paper|Sepia|Night|Ink)\s*\|\s*`(#[0-9A-Fa-f]{6})`"
        r"(?:\s*@\s*(\d+)%\s*opacity)?\s*\|",
        text,
    )
    return {t: (h, int(p) if p else None) for t, h, p in rows}


for token in COLOR_TOKENS:
    body = section(md, rf"### `{token}`", stop_pattern=r"\n### |\Z")
    if body is None:
        fail(f"'{token}': section not found in DESIGN_TOKENS.md")
        continue
    table = parse_color_table(body)
    css_var = f"color-{camel_to_kebab(token)}"
    for theme_name in THEMES:
        theme_key = theme_name.lower()
        if theme_name not in table:
            fail(f"{token}/{theme_name}: no row found in DESIGN_TOKENS.md's table")
            continue
        doc_hex, doc_opacity = table[theme_name]
        css_val = theme_vars.get(theme_key, {}).get(css_var)
        if css_val is None:
            fail(f'{token}/{theme_name}: --{css_var} missing from [data-theme="{theme_key}"]')
        elif not css_color_matches(doc_hex, doc_opacity, css_val):
            suffix = f" @ {doc_opacity}% opacity" if doc_opacity else ""
            fail(
                f"{token}/{theme_name}: DESIGN_TOKENS.md says {doc_hex}{suffix}, "
                f"globals.css --{css_var} is `{css_val}`"
            )

# ---- Color tokens: theme-independent, state-based ----
STATE_TOKENS = {"statusUnread": "Unread", "statusReading": "Reading", "statusRead": "Read"}
for token, state in STATE_TOKENS.items():
    body = section(md, rf"### `{token}`", stop_pattern=r"\n### |\Z")
    if body is None:
        fail(f"'{token}': section not found in DESIGN_TOKENS.md")
        continue
    row = re.search(rf"\|\s*{state}\s*\|\s*`(#[0-9A-Fa-f]{{6}})`\s*\|", body)
    if not row:
        fail(f"'{token}': row for state '{state}' not found")
        continue
    doc_hex = row.group(1)
    css_var = f"color-{camel_to_kebab(token)}"
    css_val = root_vars.get(css_var)
    if css_val is None:
        fail(f"{token}: --{css_var} missing from :root")
    elif css_val.strip().lower() != doc_hex.lower():
        fail(f"{token}: DESIGN_TOKENS.md says {doc_hex}, globals.css --{css_var} is `{css_val}`")

# ---- highlight (theme-independent, hex + opacity) ----
body = section(md, r"### `highlight`.*?", stop_pattern=r"\n---|\Z")
if body is None:
    fail("'highlight': section not found in DESIGN_TOKENS.md")
else:
    row = re.search(r"\|\s*`(#[0-9A-Fa-f]{6})`\s*@\s*(\d+)%\s*opacity\s*\|", body)
    if not row:
        fail("'highlight': value row not found")
    else:
        doc_hex, doc_pct = row.group(1), int(row.group(2))
        css_val = root_vars.get("color-highlight")
        if css_val is None:
            fail("--color-highlight missing from :root")
        elif not css_color_matches(doc_hex, doc_pct, css_val):
            fail(
                f"highlight: DESIGN_TOKENS.md says {doc_hex} @ {doc_pct}% opacity, "
                f"globals.css --color-highlight is `{css_val}`"
            )

# ---- Spacing ----
spacing_body = section(md, r"## 5\. Spacing Tokens")
if spacing_body is None:
    fail("Spacing Tokens section not found in DESIGN_TOKENS.md")
else:
    for key in ["xxs", "xs", "sm", "md", "lg", "xl", "2xl", "3xl"]:
        row = re.search(rf"\|\s*`spacing\.{re.escape(key)}`\s*\|\s*(\d+)pt\s*\|", spacing_body)
        css_var = f"spacing-{key}"
        if not row:
            fail(f"spacing.{key}: row not found in DESIGN_TOKENS.md")
            continue
        css_val = root_vars.get(css_var)
        if css_val is None:
            fail(f"spacing.{key}: --{css_var} missing from :root")
        elif css_val.strip() != f"{row.group(1)}px":
            fail(f"spacing.{key}: doc says {row.group(1)}pt, globals.css --{css_var} is `{css_val}`")

# ---- Corner radius ----
radius_body = section(md, r"## 6\. Corner Radius Tokens")
if radius_body is None:
    fail("Corner Radius Tokens section not found in DESIGN_TOKENS.md")
else:
    for key in ["sm", "md", "lg", "pill"]:
        row = re.search(rf"\|\s*`radius\.{re.escape(key)}`\s*\|\s*(\d+)pt\s*\|", radius_body)
        css_var = f"radius-{key}"
        if not row:
            fail(f"radius.{key}: row not found in DESIGN_TOKENS.md")
            continue
        css_val = root_vars.get(css_var)
        if css_val is None:
            fail(f"radius.{key}: --{css_var} missing from :root")
        elif css_val.strip() != f"{row.group(1)}px":
            fail(f"radius.{key}: doc says {row.group(1)}pt, globals.css --{css_var} is `{css_val}`")

# ---- Typography — UI ----
WEIGHT_MAP = {"Bold": "700", "Semibold": "600", "Regular": "400"}
ui_body = section(md, r"### UI Typography.*?", stop_pattern=r"\n---|\Z")
if ui_body is None:
    fail("UI Typography section not found in DESIGN_TOKENS.md")
else:
    for key in ["screenTitle", "listTitle", "listSubtitle", "button", "caption", "input"]:
        row = re.search(
            rf"\|\s*`type\.ui\.{key}`\s*\|\s*(\d+)pt\s*\|\s*(\w+)\s*\|\s*([\d.]+)×\s*\|",
            ui_body,
        )
        base = f"type-ui-{camel_to_kebab(key)}"
        if not row:
            fail(f"type.ui.{key}: row not found or didn't match the expected format")
            continue
        size, weight_word, lh = row.groups()
        expected_weight = WEIGHT_MAP.get(weight_word)
        for css_var, expected in [
            (f"{base}-size", f"{size}px"),
            (f"{base}-weight", expected_weight),
            (f"{base}-line-height", lh),
        ]:
            css_val = root_vars.get(css_var)
            if css_val is None:
                fail(f"type.ui.{key}: --{css_var} missing from :root")
            elif expected and not values_match(css_var, expected, css_val.strip()):
                fail(f"type.ui.{key}: doc implies --{css_var} = {expected}, css is `{css_val}`")

# ---- Typography — Reading headings ----
reading_body = section(md, r"### Reading Typography.*?", stop_pattern=r"\n\*\*Why|\Z")
if reading_body is None:
    fail("Reading Typography section not found in DESIGN_TOKENS.md")
else:
    for key in ["h1", "h2", "h3", "h4"]:
        row = re.search(
            rf"\|\s*`type\.reading\.{key}`\s*\|\s*(\d+)pt\s*\|\s*\w+\s*\((\d+)\)\s*\|\s*([\d.]+)×\s*\|",
            reading_body,
        )
        base = f"type-reading-{key}"
        if not row:
            fail(f"type.reading.{key}: row not found or didn't match the expected format")
            continue
        size, weight, lh = row.groups()
        for css_var, expected in [
            (f"{base}-size", f"{size}px"), (f"{base}-weight", weight), (f"{base}-line-height", lh),
        ]:
            css_val = root_vars.get(css_var)
            if css_val is None:
                fail(f"type.reading.{key}: --{css_var} missing from :root")
            elif not values_match(css_var, expected, css_val.strip()):
                fail(f"type.reading.{key}: doc implies --{css_var} = {expected}, css is `{css_val}`")

    # ---- Typography — Reading body sizes (xs-lg share weight/line-height; xl/xxl override line-height) ----
    for key in ["xs", "sm", "md", "lg", "xl", "xxl"]:
        row = re.search(
            rf"\|\s*`type\.reading\.body\.{key}`\s*\|\s*(\d+)pt\s*\|\s*\w+\s*\((\d+)\)\s*\|\s*([\d.]+)×\s*\|",
            reading_body,
        )
        if not row:
            fail(f"type.reading.body.{key}: row not found or didn't match the expected format")
            continue
        size, weight, lh = row.groups()

        size_var = f"type-reading-body-{key}-size"
        css_size = root_vars.get(size_var)
        if css_size is None:
            fail(f"type.reading.body.{key}: --{size_var} missing")
        elif css_size.strip() != f"{size}px":
            fail(f"type.reading.body.{key}: doc says {size}pt, css --{size_var} is `{css_size}`")

        css_weight = root_vars.get("type-reading-body-weight")
        if css_weight is None:
            fail("type.reading.body: shared --type-reading-body-weight missing")
        elif css_weight.strip() != weight:
            fail(
                f"type.reading.body.{key}: doc weight {weight}, "
                f"shared css --type-reading-body-weight is `{css_weight}`"
            )

        lh_var = f"type-reading-body-{key}-line-height" if key in ("xl", "xxl") else "type-reading-body-line-height"
        css_lh = root_vars.get(lh_var)
        if css_lh is None:
            fail(f"type.reading.body.{key}: --{lh_var} missing")
        elif not values_match(lh_var, lh, css_lh.strip()):
            fail(f"type.reading.body.{key}: doc line-height {lh}, css --{lh_var} is `{css_lh}`")

if failures:
    print(f"check-token-parity: {len(failures)} mismatch(es) between DESIGN_TOKENS.md and globals.css\n")
    for f in failures:
        print(f"  - {f}")
    sys.exit(1)

print("check-token-parity: DESIGN_TOKENS.md and verso-web/app/globals.css agree on every token checked")
sys.exit(0)
