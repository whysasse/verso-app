> 🗄️ **ARCHIVED 2026-06-12.** Superseded by `DESIGN_TOKENS.md` and `Colors.swift`. Kept for history; do not implement from this document.

# Themes — Verso

**Version:** 1.0  
**Date:** 2026-04-22  
**Status:** Draft

This file captures the intent, personality, and design rationale behind Verso's four reading themes. Token values are not listed here — those live in `DESIGN_TOKENS.md`. This file explains *why* each theme exists, what experience it's designed for, and how they work together as a system.

---

## The system

Verso offers four themes because reading is personal and time-of-day matters. No single palette is right for a sunlit breakfast table and a 1am bedroom. The four themes cover the two meaningful axes of a reading environment: warmth (warm/neutral) and luminance (light/dark).

All four themes share the same eight semantic token roles. Only the values change. This structural consistency is intentional: any component built against the tokens works correctly in all four themes without modification.

**The design philosophy behind all four themes:** colors should reference physical materials — paper, ink, candlelight, shadow — not screens. Every palette choice asks "what would this surface look like in the real world?" before asking "does this look good on a display."

---

## `VersoTheme.paper` — Paper *(default)*

**Personality:** Warm, familiar, unhurried. The theme that feels least like an app.

**The reference material:** Aged, quality paper stock — slightly cream rather than pure white, slightly warm rather than neutral. Think of a well-made paperback that's been carried around for a few weeks.

**Optimized for:** Daytime reading in natural or warm artificial light. This is the workhorse theme — comfortable for extended sessions, gentle on the eyes even in direct sunlight, and familiar enough that it doesn't ask the user to adjust.

**Who chooses it:** Most users. Paper is the default for a reason — it requires the least visual adjustment when picking up the app and works well across the widest range of lighting conditions.

**The accent in context:** A muted, warm terracotta-brown (`#766655`). Not a bright CTA color — closer to a well-worn leather or dried ink. It signals interactivity without shouting, which is right for an app that wants the interface to recede.

**`isDark`:** `false` — sets `preferredColorScheme(.light)`.

**Onboarding preview copy:** "The verso is the second page you encounter when you open a book — the quiet one, before the story begins."

---

## `VersoTheme.sepia` — Sepia

**Personality:** Nostalgic, warm, slightly amber. The most opinionated theme.

**The reference material:** Vintage books and warm lamp light. Where Paper is a fresh notebook, Sepia is a book pulled from a shelf — slightly yellowed, ink that's settled into the page. Think late-night reading under a tungsten bulb.

**Optimized for:** Evening reading in warm indoor lighting. The increased warmth relative to Paper reduces blue-channel stimulation, which makes it well-suited to pre-sleep reading sessions. It's also the theme users most associate with "reading mode" in traditional e-readers.

**Who chooses it:** Readers who want the most book-like experience, or who find Paper slightly too cool. Also users who simply prefer the aesthetic of aged materials over clean modern paper.

**The accent in context:** A warm amber-brown (`#825A37`) — closer to caramel than leather. Still muted and natural, but slightly richer than Paper's accent to maintain contrast against the more saturated background.

**`isDark`:** `false` — sets `preferredColorScheme(.light)`.

**Onboarding preview copy:** "The verso is the second page you encounter when you open a book — the quiet one, before the story begins."

**Note:** Paper and Sepia share the same onboarding preview copy intentionally — the text is the constant, and the comparison between the two themes' rendering of it is the point. The user's decision is about warmth, not substance.

---

## `VersoTheme.night` — Night

**Personality:** Warm dark. A dark room lit by a single lamp — not cold, not harsh.

**The reference material:** A lamp-lit room at night, or a late-evening session before sleep. The background is a very dark warm brown-black (`#1C1A16`) rather than a neutral charcoal or blue-black. This warmth is deliberate.

**Optimized for:** Low-light reading when screen brightness is reduced. The warm dark background reduces the jarring contrast that cool dark themes create when transitioning from a lit room. It's easier to sustain for longer sessions than cold dark modes.

**Who chooses it:** Users who want dark mode but find pure black or cool dark themes too harsh or clinical. Night is the dark-mode choice for readers who prefer warmth over precision. It's also the better choice for users in transitional lighting (e.g., in bed with a lamp still on across the room).

**The accent in context:** A warm amber-gold (`#C4A97D`). In dark themes, accent colors lighten to maintain contrast — but rather than going blue or neutral, Night's accent leans amber to stay coherent with the warm palette. It reads as lamplight.

**`isDark`:** `true` — sets `preferredColorScheme(.dark)`.

**Relationship to Ink:** Night and Ink cover the same luminance range (dark backgrounds) but different temperatures. Night is the choice for warmth; Ink is the choice for neutrality. A user who finds Night too yellow should be directed to Ink, not told Night is incorrect.

---

## `VersoTheme.ink` — Ink

**Personality:** Cool, precise, modern. The dark theme for users who want dark mode to feel like dark mode.

**The reference material:** A high-contrast OLED screen in a pitch-dark room — or, less literally, the idea of ink on a very dark surface. Where Night references a physical environment, Ink references the medium itself.

**Optimized for:** OLED displays and completely dark environments. The near-black background (`#111418`) maximizes OLED power savings and creates the deepest possible contrast, which some users find easier to sustain in total darkness (no competing ambient warmth).

**Who chooses it:** Users who use dark mode primarily for OLED efficiency or for reduced eye fatigue in dark environments, and who find warm dark themes distracting or "yellowed." Also users who simply prefer the aesthetic of a clean, modern dark mode over a warm one.

**The accent in context:** A muted periwinkle-blue (`#7B9FD4`). This is the only theme where the accent has a cool hue — which fits Ink's neutral personality. It reads as a standard "dark mode blue" link color, which is intentional: Ink users are comfortable with conventional dark mode conventions.

**`isDark`:** `true` — sets `preferredColorScheme(.dark)`.

---

## How themes work together as a system

**The user's choice is permanent until they change it.** Verso does not follow system appearance automatically (no automatic light/dark switching). The user's selected theme is the reading environment — switching it requires an intentional act. This is a deliberate design decision: reading sessions benefit from environmental consistency, and automatic theme switching can be disorienting mid-article.

**Theme switching happens in real-time.** When the user changes themes in `ReadingControls` or Settings, the transition is instant — no fade, no animation. The colors update simultaneously across all elements. This immediacy makes the effect feel like switching a physical reading light rather than navigating a settings hierarchy.

**Theme selection is the first personal moment in onboarding.** The theme picker appears as Screen 2 in onboarding — before folder setup, which is functional rather than expressive. This sequencing is intentional: the first delightful, personal interaction should happen before the mandatory configuration step. The user arrives at folder setup already inside their chosen aesthetic.

**The same token roles, different values.** No component should ever branch on `currentTheme` to change layout or behavior — only values should change. If a component needs to know whether it's in a dark theme (e.g., to adjust a non-tokenized element), use `VersoTheme.isDark` rather than checking the theme name.

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-04-22 | Initial theme intent and rationale document. |
