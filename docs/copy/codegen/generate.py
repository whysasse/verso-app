#!/usr/bin/env python3
"""
Regenerates Verso/Resources/Localizable.xcstrings and Verso/Generated/L10n.swift
from docs/copy/UI_COPY.md (the single shared string source for iOS + Web).

Run whenever UI_COPY.md changes:
    python3 docs/copy/codegen/generate.py
"""

import re, json, sys, os

SRC = os.path.join(os.path.dirname(__file__), "..", "UI_COPY.md")

rows = []
with open(SRC, encoding="utf-8") as f:
    for line in f:
        line = line.rstrip("\n")
        if not line.startswith("|"):
            continue
        if re.match(r"^\|\s*-+", line):
            continue
        if line.strip().startswith("| Key "):
            continue
        m = re.match(r"^\|\s*`([a-zA-Z0-9_.]+)`\s*\|(.*)\|\s*$", line)
        if not m:
            continue
        key = m.group(1)
        rest = m.group(2)
        cols = [c.strip() for c in rest.split("|")]
        if len(cols) != 5:
            print("WARN: unexpected column count for key", key, len(cols), file=sys.stderr)
            continue
        location, en, fr, pt, notes = cols
        rows.append({"key": key, "location": location, "en": en, "fr": fr, "pt": pt, "notes": notes})


import json, re


by_key = {r["key"]: r for r in rows}

# Keys that are ⚠️-flagged in UI_COPY.md AND whose wording genuinely changes between
# singular/plural (so they need a real CLDR plural-variation block in the catalog).
# The other ⚠️-flagged keys (filter.all.accessibilityLabel, articleCard.estimatedReadTime)
# keep the same wording regardless of count ("min" doesn't pluralize, "All articles" is a
# fixed category label) so they're handled as plain %lld substitutions, no variation needed.
TRUE_PLURAL_KEYS = {
    "filter.unread.accessibilityLabel",
    "filter.reading.accessibilityLabel",
    "filter.read.accessibilityLabel",
    "filter.archived.accessibilityLabel",
    "dialog.bulkDelete.title",
    "import.done.summary",
    "import.done.skippedSuffix",
}

# Hand-written "one" (singular) forms for the true-plural keys, since UI_COPY.md only
# records the representative "other" form. French's CLDR "one" category already covers
# 0 and 1 natively, and Portuguese (pt-BR)'s "one" category covers only 1 -- so we only
# need to supply "one" and "other"; the system picks the right one per-locale at runtime.
PLURAL_ONE_FORMS = {
    "filter.unread.accessibilityLabel": {
        "en": "Unread, %lld article",
        "fr": "Non lus, %lld article",
        "pt": "Não lidos, %lld artigo",
    },
    "filter.reading.accessibilityLabel": {
        "en": "Reading, %lld article",
        "fr": "En cours, %lld article",
        "pt": "Lendo, %lld artigo",
    },
    "filter.read.accessibilityLabel": {
        "en": "Read, %lld article",
        "fr": "Lus, %lld article",
        "pt": "Lidos, %lld artigo",
    },
    "filter.archived.accessibilityLabel": {
        "en": "Archived, %lld article",
        "fr": "Archivés, %lld article",
        "pt": "Arquivados, %lld artigo",
    },
    "dialog.bulkDelete.title": {
        "en": "Delete %lld article?",
        "fr": "Supprimer %lld article?",
        "pt": "Excluir %lld artigo?",
    },
    "import.done.summary": {
        "en": "%lld article imported",
        "fr": "%lld article importé",
        "pt": "%lld artigo importado",
    },
    "import.done.skippedSuffix": {
        "en": ", %lld skipped",
        "fr": ", %lld ignoré",
        "pt": ", %lld ignorado",
    },
}

INTEGER_PLACEHOLDERS = {"N", "count", "points", "size"}

def placeholder_list(s):
    return re.findall(r"\{([^}]+)\}", s)

def param_name(ph):
    if ph == "N":
        return "count"
    if " " in ph:
        parts = ph.split(" ")
        return parts[0] + "".join(p.capitalize() for p in parts[1:])
    return ph

def to_format_template(s, placeholders):
    # Replace {placeholder} with %lld or %@ in left-to-right order.
    out = s
    for ph in placeholders:
        spec = "%lld" if ph in INTEGER_PLACEHOLDERS else "%@"
        out = out.replace("{" + ph + "}", spec, 1)
    return out

def swift_interp_template(s, placeholders):
    out = s
    for ph in placeholders:
        out = out.replace("{" + ph + "}", "\\(" + param_name(ph) + ")", 1)
    return out

def swift_escape(s):
    # Escape backslashes and double-quotes so the value is safe to drop into a
    # Swift string literal. (UI_COPY.md's share.duplicate.subheadline contains a
    # literal "{existingTitle}" -- without this, the generated source has an
    # unescaped " that prematurely closes the string literal and fails to compile.)
    return s.replace("\\", "\\\\").replace('"', '\\"')

def capitalize_first(s):
    return s[0].upper() + s[1:] if s else s

def swift_namespace_and_member(key):
    segs = key.split(".")
    namespace = capitalize_first(segs[0])
    remainder = segs[1:] if len(segs) > 1 else segs
    if len(segs) == 1:
        member = segs[0]
    else:
        member = remainder[0] + "".join(capitalize_first(s) for s in remainder[1:])
    return namespace, member

is_invariant = lambda r: "invariant" in r["notes"].lower()

# ---------- Build .xcstrings ----------
strings_obj = {}
for r in rows:
    key = r["key"]
    en, fr, pt = r["en"], r["fr"], r["pt"]
    notes = r["notes"]
    placeholders = placeholder_list(en)
    invariant = is_invariant(r)
    fr_state = "translated" if invariant else "needs_review"
    pt_state = "translated" if invariant else "needs_review"

    if key in TRUE_PLURAL_KEYS:
        other_en = to_format_template(en, placeholders)
        other_fr = to_format_template(fr, placeholders)
        other_pt = to_format_template(pt, placeholders)
        one = PLURAL_ONE_FORMS[key]
        localizations = {
            "en": {"variations": {"plural": {
                "one":   {"stringUnit": {"state": "translated", "value": one["en"]}},
                "other": {"stringUnit": {"state": "translated", "value": other_en}},
            }}},
            "fr-CA": {"variations": {"plural": {
                "one":   {"stringUnit": {"state": fr_state, "value": one["fr"]}},
                "other": {"stringUnit": {"state": fr_state, "value": other_fr}},
            }}},
            "pt-BR": {"variations": {"plural": {
                "one":   {"stringUnit": {"state": pt_state, "value": one["pt"]}},
                "other": {"stringUnit": {"state": pt_state, "value": other_pt}},
            }}},
        }
    else:
        en_t = to_format_template(en, placeholders)
        fr_t = to_format_template(fr, placeholders)
        pt_t = to_format_template(pt, placeholders)
        localizations = {
            "en":    {"stringUnit": {"state": "translated", "value": en_t}},
            "fr-CA": {"stringUnit": {"state": fr_state, "value": fr_t}},
            "pt-BR": {"stringUnit": {"state": pt_state, "value": pt_t}},
        }

    comment = notes if notes and notes != "—" else r["location"]
    strings_obj[key] = {
        "extractionState": "manual",
        "comment": comment,
        "localizations": localizations,
    }

catalog = {
    "sourceLanguage": "en",
    "strings": strings_obj,
    "version": "1.0",
}
IOS_OUT = os.path.join(os.path.dirname(__file__), "..", "..", "..", "Verso", "Resources", "Localizable.xcstrings")
with open(IOS_OUT, "w", encoding="utf-8") as f:
    json.dump(catalog, f, ensure_ascii=False, indent=2, sort_keys=False)
    f.write("\n")

# ---------- Build L10n.swift ----------
namespaces = {}
for r in rows:
    key = r["key"]
    en = r["en"]
    placeholders = placeholder_list(en)
    namespace, member = swift_namespace_and_member(key)
    namespaces.setdefault(namespace, []).append((member, key, en, placeholders, r["notes"], r["location"]))

lines = []
lines.append("// GENERATED FILE -- do not edit by hand.")
lines.append("// Source of truth: docs/copy/UI_COPY.md")
lines.append("// Regenerate with: python3 docs/copy/codegen/generate.py")
lines.append("// (keys, English strings, and fr-CA/pt-BR translations all come from that file)")
lines.append("")
lines.append("import Foundation")
lines.append("")
lines.append("/// Typed accessors for every localized string key in `docs/copy/UI_COPY.md`.")
lines.append("/// Each accessor reads from `Localizable.xcstrings` via the key, falling back to")
lines.append("/// the English text below if a translation is missing.")
lines.append("enum L10n {")
for namespace in sorted(namespaces.keys()):
    lines.append(f"    enum {namespace} {{")
    for member, key, en, placeholders, notes, location in sorted(namespaces[namespace], key=lambda x: x[0]):
        comment_text = notes if notes and notes != "—" else location
        comment_text = comment_text.replace('"', "'")
        if placeholders:
            params = [(param_name(p), "Int" if p in INTEGER_PLACEHOLDERS else "String") for p in placeholders]
            seen = set()
            uniq_params = []
            for p in params:
                if p[0] not in seen:
                    uniq_params.append(p)
                    seen.add(p[0])
            sig = ", ".join(f"{n}: {t}" for n, t in uniq_params)
            # Escape quotes/backslashes in the literal text *before* inserting the
            # \(param) interpolation syntax -- escaping after would also mangle the
            # backslash we just inserted for interpolation.
            interp = swift_interp_template(swift_escape(en), placeholders)
            lines.append(f"        /// \"{en}\" -- {comment_text}")
            lines.append(f"        static func {member}({sig}) -> String {{")
            lines.append(f"            String(localized: \"{key}\", defaultValue: \"{interp}\", comment: \"{comment_text}\")")
            lines.append("        }")
        else:
            en_escaped = swift_escape(en)
            lines.append(f"        /// \"{en}\" -- {comment_text}")
            lines.append(f"        static var {member}: String {{")
            lines.append(f"            String(localized: \"{key}\", defaultValue: \"{en_escaped}\", comment: \"{comment_text}\")")
            lines.append("        }")
    lines.append("    }")
lines.append("}")

SWIFT_OUT = os.path.join(os.path.dirname(__file__), "..", "..", "..", "Verso", "Generated", "L10n.swift")
os.makedirs(os.path.dirname(SWIFT_OUT), exist_ok=True)
with open(SWIFT_OUT, "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")

print("Generated Localizable.xcstrings with", len(strings_obj), "keys")
print("Generated L10n.swift with", len(namespaces), "namespaces")

# ---------- Build verso-web/messages/<locale>.json (next-intl, ICU MessageFormat) ----------
# Same source, same keys as iOS -- reusing UI_COPY.md's dotted keys verbatim (instead of a
# separate Web naming convention) is what keeps the two platforms from drifting apart.
# Maps the next-intl locale slug (the JSON filename) to the UI_COPY.md column it reads from.
# No en-CA.json: LOCALIZATION.md says en-CA aliases en with no separate bundle -- that's
# resolved at lookup time in verso-web/i18n/request.ts, not by duplicating a file here.
MESSAGE_LOCALES = {"en": "en", "fr-CA": "fr", "pt-BR": "pt"}

def to_icu_template(s, placeholders):
    # UI_COPY.md placeholders ({N}, {count}, {existingTitle}) are already valid ICU
    # MessageFormat argument syntax -- unlike the Swift output, no %lld/%@ substitution is
    # needed. We still run param_name() so multi-word placeholders become valid ICU
    # identifiers (alphanumeric + underscore only) and {N} becomes the more readable {count}.
    out = s
    for ph in placeholders:
        out = out.replace("{" + ph + "}", "{" + param_name(ph) + "}", 1)
    return out

def build_icu_plural(key, lang, other_text, placeholders):
    # Combines the representative "other" row from UI_COPY.md with the hand-written "one"
    # form from PLURAL_ONE_FORMS into a single ICU plural message. Only "one"/"other" are
    # emitted: fr-CA's CLDR "one" category already covers 0 and 1, and pt-BR's "one" covers
    # only 1, so no =0 special case is needed on either locale (see LOCALIZATION.md §2).
    int_phs = [p for p in placeholders if p in INTEGER_PLACEHOLDERS]
    var = param_name(int_phs[0]) if int_phs else "count"
    other_icu = to_icu_template(other_text, placeholders).replace("{" + var + "}", "#")
    one_icu = PLURAL_ONE_FORMS[key][lang].replace("%lld", "#")
    return f"{{{var}, plural, one {{{one_icu}}} other {{{other_icu}}}}}"

# A handful of UI_COPY.md keys are themselves a leaf value *and* a prefix of other keys
# (e.g. `filter.unread` = "Unread" the chip label, `filter.unread.accessibilityLabel` =
# the VoiceOver text for that same chip; same shape for `reading.controls.{lineSpacing,
# margins,theme}` + their `.hint` siblings). That's fine for the flat iOS string-catalog
# lookup (the whole dotted string is one opaque key there), but it can't be represented in
# nested JSON -- a node can't be both a string and an object at once. We don't rename
# anything in UI_COPY.md for this; we only add a reserved "_label" child, web-side, for the
# small set of keys where the collision actually occurs. Wiring code must use
# `t("filter.unread._label")` for the chip text and `t("filter.unread.accessibilityLabel")`
# for the a11y label -- see docs/plans/FAB-275-step5-web-i18n-infra.md step 4.
LEAF_VALUE_SUFFIX = "_label"
ALL_KEYS = {r["key"] for r in rows}
KEYS_WITH_CHILDREN = {
    k for k in ALL_KEYS if any(other.startswith(k + ".") for other in ALL_KEYS if other != k)
}

def set_nested(d, dotted_key, value):
    parts = dotted_key.split(".")
    cur = d
    for p in parts[:-1]:
        cur = cur.setdefault(p, {})
    cur[parts[-1]] = value

messages = {locale: {} for locale in MESSAGE_LOCALES}
for r in rows:
    key = r["key"]
    placeholders = placeholder_list(r["en"])
    json_path = f"{key}.{LEAF_VALUE_SUFFIX}" if key in KEYS_WITH_CHILDREN else key
    for locale, lang in MESSAGE_LOCALES.items():
        text = r[lang]
        if key in TRUE_PLURAL_KEYS:
            value = build_icu_plural(key, lang, text, placeholders)
        else:
            value = to_icu_template(text, placeholders)
        set_nested(messages[locale], json_path, value)

MESSAGES_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "..", "verso-web", "messages")
os.makedirs(MESSAGES_DIR, exist_ok=True)
for locale, msgs in messages.items():
    with open(os.path.join(MESSAGES_DIR, f"{locale}.json"), "w", encoding="utf-8") as f:
        json.dump(msgs, f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write("\n")

print("Generated verso-web/messages/{en,fr-CA,pt-BR}.json with", len(rows), "keys")
