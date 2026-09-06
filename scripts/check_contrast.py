#!/usr/bin/env python3
"""FAB-314: WCAG contrast check for Verso's design tokens.

Replaces the hand-maintained tables in docs/accessibility-specs.md §3.2-3.3,
whose §3.3 claimed "All color issues are resolved. No remaining failures" --
which was never true for every pair, only the ~6 it happened to audit. This
script computes ratios straight from the real hex values in
Verso/Shared/Colors.swift (nothing duplicated here to drift out of sync) and
asserts every pair that's actually live in the shipped app today.

Two tokens the original critique flagged (`accentPressed`, `warning`) are
deliberately NOT checked here: neither is used anywhere in shipped UI as of
this writing (accentPressed only appears in DesignSystemPreview.swift, a
dev-only screen; warning doesn't appear in any SwiftUI view at all). Add them
to PAIRS below the day something actually renders with them.

Usage: python3 scripts/check_contrast.py
Exit code 0 = every live pair passes (KNOWN_FAILURES notwithstanding), 1 = a
real regression was found.
"""
import re
import sys
from pathlib import Path

COLORS_SWIFT = Path(__file__).resolve().parent.parent / "Verso" / "Shared" / "Colors.swift"

THEMES = ["paper", "sepia", "night", "ink"]

# (foreground token, background token, minimum ratio, why) -- both tokens must
# name a key present in every theme's parsed dict for the struct(s) being
# checked. "white" is a synthetic token injected below for badge icon/text.
THEME_COLOR_PAIRS = [
    ("textPrimary", "background", 4.5, "body text"),
    ("textPrimary", "surface", 4.5, "body text"),
    ("textSecondary", "background", 4.5, "body text (list subtitles, captions)"),
    ("textSecondary", "surface", 4.5, "body text (list subtitles, captions)"),
    ("accent", "background", 4.5, "used as inline link text in articles"),
    ("accent", "surface", 4.5, "used as inline link text in articles"),
    ("border", "background", 3.0, "non-text: dividers, field outlines, progress track"),
    ("border", "surface", 3.0, "non-text: dividers, field outlines, progress track"),
    ("placeholder", "surface", 3.0, "non-text: SearchBar's clear (xmark.circle.fill) icon"),
]

# Live outside ThemeColors: SemanticColors.error is the inline field-error
# caption text (VersoTextField), rendered on `surface`. `warning` and
# `success` aren't checked -- see module docstring for warning; success has
# no live foreground/background pairing in the UI today either.
SEMANTIC_COLOR_PAIRS = [
    ("error", "surface", 4.5, "VersoTextField's inline error caption, 13pt"),
]

# ArticleStatusColors: white icon inside the 28x28 status badge (all 4
# statuses, 3:1 non-text) and the same colors reused as swipe-action tints
# behind a white *text* label for unread/read/archived (4.5:1) -- `reading`
# has no such reuse (see Colors.swift's own FAB-325 comment), so it only
# needs the icon floor.
BADGE_TEXT_STATUSES = ["unread", "read", "archived"]
BADGE_ICON_ONLY_STATUSES = ["reading"]

# Pairs that are real, live, and currently fail -- tracked as FAB-336 rather
# than silently passed or left to break the build on a Medium/Backlog ticket.
# (theme, foreground_token, background_token)
KNOWN_FAILURES = {
    ("paper", "placeholder", "surface"),
    ("sepia", "placeholder", "surface"),
    ("night", "placeholder", "surface"),
    ("ink", "placeholder", "surface"),
    ("paper", "error", "surface"),
    ("sepia", "error", "surface"),
}


def relative_luminance(hex_color: str) -> float:
    hex_color = hex_color.lstrip("#")
    r, g, b = (int(hex_color[i:i + 2], 16) / 255.0 for i in (0, 2, 4))

    def channel(c: float) -> float:
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4

    r, g, b = channel(r), channel(g), channel(b)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast_ratio(hex_a: str, hex_b: str) -> float:
    l1, l2 = relative_luminance(hex_a), relative_luminance(hex_b)
    lighter, darker = max(l1, l2), min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)


def extract_struct_body(source: str, struct_name: str) -> str:
    """Returns the brace-balanced body of `struct <struct_name> { ... }`."""
    m = re.search(rf"struct {struct_name}\b[^{{]*{{", source)
    if not m:
        raise ValueError(f"struct {struct_name} not found in {COLORS_SWIFT}")
    start = m.end()
    depth = 1
    i = start
    while depth > 0:
        if source[i] == "{":
            depth += 1
        elif source[i] == "}":
            depth -= 1
        i += 1
    return source[start:i - 1]


def parse_theme_blocks(body: str) -> dict[str, dict[str, str]]:
    """Parses `static let <theme> = <Struct>( key: Color(hex: "XXXXXX"), ... )`
    blocks (closing paren alone on its own line) plus simple aliases like
    `static let sepia = paper`."""
    themes: dict[str, dict[str, str]] = {}

    block_re = re.compile(
        r"static let (\w+) = \w+\(\n(.*?)\n\s*\)", re.DOTALL
    )
    pair_re = re.compile(r'(\w+):\s*Color\(hex:\s*"([0-9A-Fa-f]{3,8})"\)')

    for match in block_re.finditer(body):
        theme_name, block_body = match.group(1), match.group(2)
        themes[theme_name] = {
            key: f"#{hexval[:6]}" if len(hexval) >= 6 else f"#{hexval}"
            for key, hexval in pair_re.findall(block_body)
        }

    alias_re = re.compile(r"^\s*static let (\w+) = (\w+)\s*$", re.MULTILINE)
    for theme_name, alias_of in alias_re.findall(body):
        if theme_name not in themes and alias_of in themes:
            themes[theme_name] = themes[alias_of]

    return themes


def main() -> int:
    source = COLORS_SWIFT.read_text()

    theme_colors = parse_theme_blocks(extract_struct_body(source, "ThemeColors"))
    semantic_colors = parse_theme_blocks(extract_struct_body(source, "SemanticColors"))
    status_colors = parse_theme_blocks(extract_struct_body(source, "ArticleStatusColors"))

    for name, parsed in (
        ("ThemeColors", theme_colors),
        ("SemanticColors", semantic_colors),
        ("ArticleStatusColors", status_colors),
    ):
        missing = [t for t in THEMES if t not in parsed]
        if missing:
            print(f"ERROR: {name} is missing theme(s) {missing} -- parser or Colors.swift changed shape", file=sys.stderr)
            return 1

    failures = []
    known_failures_seen = set()

    def check(theme: str, fg_name: str, fg_hex: str, bg_name: str, bg_hex: str, minimum: float, why: str):
        ratio = contrast_ratio(fg_hex, bg_hex)
        key = (theme, fg_name, bg_name)
        if ratio + 1e-9 >= minimum:
            return
        if key in KNOWN_FAILURES:
            known_failures_seen.add(key)
            print(f"KNOWN FAILURE (see FAB-336): {theme}/{fg_name} on {bg_name} = {ratio:.2f}:1, needs {minimum}:1 ({why})")
        else:
            failures.append(f"{theme}/{fg_name} on {bg_name} = {ratio:.2f}:1, needs {minimum}:1 ({why})")

    for theme in THEMES:
        colors = theme_colors[theme]
        for fg, bg, minimum, why in THEME_COLOR_PAIRS:
            check(theme, fg, colors[fg], bg, colors[bg], minimum, why)

        semantic = semantic_colors[theme]
        for fg, bg, minimum, why in SEMANTIC_COLOR_PAIRS:
            bg_hex = colors[bg] if bg in colors else semantic[bg]
            check(theme, fg, semantic[fg], bg, bg_hex, minimum, why)

        statuses = status_colors[theme]
        white = "#FFFFFF"
        for status in BADGE_TEXT_STATUSES:
            check(theme, "white", white, f"status.{status}", statuses[status], 4.5,
                  f"badge icon + swipe-action tint text for .{status}")
        for status in BADGE_ICON_ONLY_STATUSES:
            check(theme, "white", white, f"status.{status}", statuses[status], 3.0,
                  f"badge icon for .{status} (no swipe-tint reuse)")

    stale_known_failures = KNOWN_FAILURES - known_failures_seen
    if stale_known_failures:
        print(f"NOTE: these KNOWN_FAILURES entries now pass -- remove them and close out FAB-336 for: {sorted(stale_known_failures)}")

    if failures:
        print(f"\n{len(failures)} contrast regression(s) found:", file=sys.stderr)
        for f in failures:
            print(f"  FAIL: {f}", file=sys.stderr)
        return 1

    print(f"\nAll live pairs pass (or are documented KNOWN_FAILURES tracked as FAB-336: {len(known_failures_seen)} of them).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
