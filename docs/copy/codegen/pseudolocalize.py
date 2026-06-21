#!/usr/bin/env python3
"""
Generate a pseudo-locale JSON for layout-flex QA, from the English message file.

Transforms every leaf string:
  1. Preserves ICU MessageFormat ({...}, {..., plural, ...}) verbatim
  2. Substitutes ASCII chars with accented equivalents in surrounding text
  3. Lengthens by ~30 % (repeats vowels internally)
  4. Wraps in brackets for visual truncation detection

Usage:
    python3 docs/copy/codegen/pseudolocalize.py

Writes:
    verso-web/messages/pseudo.json
"""

import json
import os
import re

EN_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "..",
                       "verso-web", "messages", "en.json")
OUT_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "..",
                        "verso-web", "messages", "pseudo.json")


_CHAR_MAP = {
    "a": "ä", "A": "Ä",
    "e": "ë", "E": "Ë",
    "i": "ï", "I": "Ï",
    "o": "ö", "O": "Ö",
    "u": "ü", "U": "Ü",
    "c": "ç", "C": "Ç",
    "n": "ñ", "N": "Ñ",
}


def _accent(s: str) -> str:
    return "".join(_CHAR_MAP.get(c, c) for c in s)


def _split_icu(text: str):
    """
    Split text into segments alternating between plain text and ICU tokens.

    Handles nested braces in {x, plural, ...} and {x, select, ...} forms.
    Yields (is_icu: bool, segment: str).
    """
    i = 0
    while i < len(text):
        if text[i] == "{":
            # Find matching closing brace, respecting nesting
            depth = 1
            j = i + 1
            while j < len(text) and depth > 0:
                if text[j] == "{":
                    depth += 1
                elif text[j] == "}":
                    depth -= 1
                j += 1
            if depth == 0:
                yield True, text[i:j]
                i = j
            else:
                # Unmatched brace - treat as plain text
                yield False, text[i]
                i += 1
        else:
            j = i
            while j < len(text) and text[j] != "{":
                j += 1
            yield False, text[i:j]
            i = j


def _pseudo_value(original: str) -> str:
    """Return pseudo-localized version preserving ICU tokens."""

    parts = list(_split_icu(original))
    result_parts = []

    for is_icu, segment in parts:
        if is_icu:
            # Preserve ICU token as-is
            result_parts.append(segment)
        else:
            # Accent and lengthen plain text
            accented = _accent(segment)
            # Lengthen by ~30 %: double the first vowel of each word
            lengthened = re.sub(
                r"([äëïöüçñÄËÏÖÜÇÑ])(?=[a-zäëïöüçñ])",
                lambda m: m.group(1) + m.group(1).lower(),
                accented,
            )
            result_parts.append(lengthened)

    result = "".join(result_parts)

    # Only wrap in brackets if there's visible text (not just ICU tokens)
    plain_chars = sum(len(s) for is_icu, s in parts if not is_icu)
    if plain_chars > 0:
        result = f"[{result}]"

    return result


def _walk(obj):
    """Recursively walk JSON, pseudo-localizing leaf strings."""
    if isinstance(obj, str):
        return _pseudo_value(obj)
    elif isinstance(obj, dict):
        return {k: _walk(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [_walk(item) for item in obj]
    return obj


def main():
    with open(EN_PATH, encoding="utf-8") as f:
        en_data = json.load(f)

    pseudo_data = _walk(en_data)

    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(pseudo_data, f, ensure_ascii=False, indent=2)

    def count_leaves(d):
        if isinstance(d, str):
            return 1
        if isinstance(d, dict):
            return sum(count_leaves(v) for v in d.values())
        return 0

    print(f"Generated {OUT_PATH}")
    print(f"  {count_leaves(pseudo_data)} strings pseudo-localized")


if __name__ == "__main__":
    main()
