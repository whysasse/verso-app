# Decisions — Verso

**Version:** 1.0 · **Date:** 2026-09-11 · **Status:** Active

ADR-lite. One entry per settled call. The rule that keeps this useful: when
a session stops to ask about something that isn't written down anywhere,
the answer gets committed here in the same session — not just spoken and
lost to the next one.

---

## 2026-09-11 — CLAUDE.md becomes the real contract, not an `@AGENTS.md` include

**Context:** The portable `work-on-issue` skill (and `project-setup`,
`verifier`) read a project's `CLAUDE.md` looking for literal `## Commands`
/ `## Workflow` / `## Conventions` / `## Things Claude gets wrong`
sections. Verso's root `CLAUDE.md` was a single line, `@AGENTS.md`, and
`AGENTS.md` doesn't have that shape — it's a narrative doc (project
overview, architecture, SwiftUI gotchas, documentation rules).

**Decision:** Replace the `@AGENTS.md` include with the actual five-section
contract, filled with Verso's specifics. Where the contract would just
restate AGENTS.md's own content (SwiftUI gotchas, design-system Swift
identifiers, architecture), `CLAUDE.md` points to `AGENTS.md` instead of
duplicating it. `AGENTS.md` is otherwise untouched.

**Consequences:** Two files now carry project guidance instead of one, but
each has one job: `CLAUDE.md` is the mechanical contract global tooling
reads; `AGENTS.md` is the narrative reference a person (or a session) reads
for depth. Whoever edits SwiftUI gotchas, architecture notes, or the
documentation rules going forward does it in `AGENTS.md` only — adding a
second copy in `CLAUDE.md` would just drift.
