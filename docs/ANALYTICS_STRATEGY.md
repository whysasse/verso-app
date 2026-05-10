# Verso Analytics Strategy

**Version:** 1.0 | **Date:** 2026-05-10 | **Status:** Approved for development reference

This document defines what Verso should measure, why, and how — before implementation begins. The goal is to lock in the questions we want to answer so that instrumentation can be wired in during feature development, not bolted on afterward.

---

## Privacy Stance

Verso is a local-first app with no user accounts and no backend. Any analytics must be consistent with that ethos.

**Decision: opt-in, on-device signal only.**

- Analytics are **off by default**.
- During onboarding, users are offered a single consent prompt: *"Help improve Verso anonymously — no personal data, ever. You can change this in Settings."*
- If declined, no events are sent. If accepted, only the events listed below are sent.
- The preference is stored in `UserDefaults` and exposed in Settings as a toggle.
- No personal data, IP addresses, or device fingerprints are collected at any point.

**Tooling:**
- **Apple App Store Connect** — free baseline (downloads, active devices, sessions, crash rate, retention). No SDK needed.
- **TelemetryDeck** — privacy-first analytics SDK. All signals are hashed and aggregated. GDPR-compliant. Free up to ~100k signals/month. Best fit for Verso's ethos.

---

## UX Questions to Answer

These are the questions that justify collecting any signal at all:

| # | Question | Why it matters |
|---|----------|----------------|
| 1 | Are people returning to read, or is this a save-and-forget app? | Determines whether the core loop is working |
| 2 | Are articles being read or just saved? | Save-vs-read ratio reveals whether reading intent converts to completion |
| 3 | Is the iCloud/Obsidian vault integration being adopted? | High abandonment in onboarding folder setup = friction to fix |
| 4 | Are articles failing to parse at a meaningful rate? | Silent parse failures erode trust; need to know scope |
| 5 | Which themes and fonts are actually used? | Informs future simplification — if 90% use Paper+Literata, the other 3 themes may be cut |
| 6 | Is immersive reading mode being discovered and used? | Feature discoverability signal — if unused, consider making it more prominent |

---

## Event Catalog

All event names use dot-separated namespace convention. Parameters are passed as a string dictionary.

| Event | Parameters | Answers question |
|-------|------------|-----------------|
| `article.saved` | `source: "share_extension" \| "in_app"` | #2 — core loop start |
| `article.opened` | — | #2 — intent to read |
| `article.readCompleted` | — | #2 — core loop fulfilled |
| `article.parseFailed` | `errorType: String` | #4 — error detection |
| `onboarding.stepCompleted` | `step: "welcome" \| "folder_picker" \| "done"` | #3 — drop-off analysis |
| `onboarding.vaultSetupCompleted` | — | #3 — Obsidian integration adoption |
| `settings.themeChanged` | `theme: "paper" \| "sepia" \| "night" \| "ink"` | #5 — feature adoption |
| `settings.fontChanged` | `font: String` | #5 — feature adoption |
| `reader.immersiveModeToggled` | `enabled: "true" \| "false"` | #6 — feature discoverability |
| `shareExtension.used` | — | #1 — return usage signal |

**Do not track:** article content, titles, URLs, reading time, scroll position, or any user-identifiable information.

---

## Implementation Notes

### Service layer

Add `Verso/Sources/Services/AnalyticsService.swift` following the existing service pattern. It should:
- Expose a `func track(_ event: String, parameters: [String: String] = [:])` method
- Check the opt-in UserDefaults flag before sending any event
- Wrap TelemetryDeck's `TelemetryManager.send()` call
- Be a singleton (`AnalyticsService.shared`) injected where needed, or passed via the environment

### SDK integration

Add TelemetryDeck to `project.yml` under `packages`:

```yaml
TelemetryClient:
  url: https://github.com/TelemetryDeck/SwiftClient.git
  from: "2.0.0"
```

Initialize in `VersoApp.swift` on launch, inside the analytics opt-in check.

### Opt-in preference key

```swift
// UserDefaults key
static let analyticsOptInKey = "verso.analytics.optIn"
```

Default value: `false`. Set to `true` only after explicit user consent.

### Consent UI

Add a consent step to `OnboardingView` (step between folder picker and completion):
- Headline: "Help make Verso better"
- Body: "Share anonymous usage data — no personal info, no article content, ever."
- Buttons: "Sure, why not" (opt in) / "No thanks" (skip)

Add a "Share anonymous data" toggle to `SettingsView` for later changes.

---

## Backlog Items

These tickets should be created before the relevant feature is implemented:

- [ ] **SDK integration** — Add TelemetryDeck package, initialize in VersoApp, wire up AnalyticsService
- [ ] **Onboarding consent step** — Add opt-in prompt as final onboarding step
- [ ] **Settings toggle** — Add analytics opt-in toggle to Settings screen
- [ ] **Privacy policy update** — Update in-app privacy policy to reflect opt-in analytics
- [ ] **Instrument article flow** — Wire `article.saved`, `article.opened`, `article.readCompleted` during ArticleLibraryService implementation
- [ ] **Instrument parse failures** — Wire `article.parseFailed` in ArticleParserService
- [ ] **Instrument onboarding** — Wire `onboarding.stepCompleted` and `onboarding.vaultSetupCompleted`
- [ ] **Instrument settings** — Wire `settings.themeChanged`, `settings.fontChanged` in ThemeManager and ReadingPreferencesService
- [ ] **Instrument immersive mode** — Wire `reader.immersiveModeToggled` in reading view
