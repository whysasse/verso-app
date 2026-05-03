# Blueprint: Context-Based Design System (CBDS) Transition
## Project: Read-it-Later iPhone App (v2.0)
## Objective: Transition from static styles to a Temporal, Spatial, and Tactile ruleset.

---

### 1. The Core Philosophy
This system moves away from static UI consistency toward **Contextual Appropriateness**. The app should adapt its "vibe" based on the user's internal state (Time) and intent (Focus), rather than just light/dark modes.

**The Three Pillars:**
1.  **Temporal (Time):** Morning (Alert) vs. Day (Productive) vs. Evening (Relaxed).
2.  **Focus (Intent):** Library (Discovery) vs. Reader (Immersion).
3.  **Environment (Sensory):** System Light/Dark + Haptic feedback intensity.

---

### 2. Contextual Thresholds & Triggers
The `VibeMonitor` should observe these system inputs to determine the active `App_Context`.

| Context | Time Range | Key Intent |
| :--- | :--- | :--- |
| **Morning** | 06:00 - 10:00 | Quick scanning, high info density. |
| **Day** | 10:00 - 19:59 | Standard utility, balanced contrast. |
| **Evening** | 20:00 - 05:59 | Deep reading, low sensory friction. |

**Guard Rail:** Theme shifts must only occur on **App Launch**, **Background-to-Foreground transition**, or **Navigation Events**. Never shift UI mid-read.

---

### 3. Design Tokens (Deterministic Ruleset)

#### A. Visual & Spatial (Figma Variable Mapping)
| Token Role | Morning (Compact) | Day (Standard) | Evening (Relaxed) |
| :--- | :--- | :--- | :--- |
| `surface-bg` | Pure White / Black | System Gray | Warm Paper / OLED Black |
| `accent-tint` | Electric Blue | System Blue | Deep Indigo / Amber |
| `content-gutter` | 12pt | 16pt | 24pt |
| `line-height` | 1.2 | 1.4 | 1.6 |
| `meta-data-opacity`| 1.0 (Visible) | 0.8 | 0.2 (Hidden/Ghost) |

#### B. Tactile (Haptic Tokens)
*   **Morning:** `UIImpactFeedbackGenerator.FeedbackStyle.medium` (Double pulse on success).
*   **Day:** `UIImpactFeedbackGenerator.FeedbackStyle.light` (Single crisp pulse).
*   **Evening:** `UIImpactFeedbackGenerator.FeedbackStyle.soft` (Single dampened pulse).

---

### 4. Implementation Steps for AI Assistants

#### Step 1: Foundation (The VibeProvider)
- Create a `ContextModel` enum: `.morning`, `.day`, `.evening`.
- Create a `VibeProvider` (ObservableObject) that calculates the current context based on `Calendar.current`.
- Add a `userOffset` property to allow for manual "vibe" adjustments in settings.

#### Step 2: Semantic Theme Engine
- Create a `Theme` struct that holds all token values (Colors, Spacing, Haptics).
- Implement a `ThemeFactory` that returns a `Theme` based on the `ContextModel`.
- Inject the active `Theme` into the SwiftUI environment.

#### Step 3: Component Refactoring (The Bridge)
- **ArticleCard:** Update to use `Theme.contentGutter`. In `.evening` mode, hide secondary labels (tags, URL).
- **ReaderView:** Update to use `Theme.lineHeight`. Apply wider horizontal padding in `.evening`.
- **HapticWrapper:** Create a view modifier or helper that triggers `Theme.hapticStyle`.

#### Step 4: Documentation Sync
- Re-read existing `design-system.md`.
- Replace all literal color/spacing values with the new Semantic Intent tokens defined in this blueprint.

---

### 5. Challenges for the Developer
1. **The Edge Case:** Ensure that if a user starts an article at 19:55 and finishes at 20:10, the "Evening" mode only triggers once they return to the Library.
2. **Typography Check:** Keep `Font.Family` static as per project requirements, but use `Font.Weight` and `Theme.lineHeight` to differentiate the vibe.
3. **The "Silent" Mode:** In Evening context, haptics should be minimized to only "Essential" feedback to respect the user's wind-down time.