# Verso — Micro-interaction Animation Spec

**FAB-83** · Deliverable for design review  
**Date:** 2026-05-03  
**Scope:** Pull-to-refresh · Article appear/disappear · Loading spinner · Screen transitions

---

## Global Timing Tokens

Defined in [`Verso/Sources/Design/Animation.swift`](../Verso/Sources/Design/Animation.swift):

| Token | Curve | Duration | Use |
|---|---|---|---|
| `VersoAnimation.fast` | easeOut | 150ms | Dismissals, fades out |
| `VersoAnimation.normal` | easeInOut | 250ms | General transitions, theme switch |
| `VersoAnimation.slow` | spring(0.4, 0.75) | ~400ms | Insert, appear |
| `VersoAnimation.spinner` | linear · repeat | 800ms/turn | Loading indicators |

---

## 1. Pull-to-Refresh

**Trigger:** User drags article list downward past the system threshold (~60pt).

### Indicator Entry
| Property | Start | End | Duration | Curve |
|---|---|---|---|---|
| Opacity | 0 | 1 | 200ms | easeOut |
| Y offset | −12pt | 0 | 200ms | easeOut |

### Spinner (while loading)
| Property | Value |
|---|---|
| Visual | `ProgressView().progressViewStyle(.circular)` |
| Tint | `theme.accent` |
| Rotation | 0° → 360°, 800ms linear, repeat forever |

### Indicator Dismiss (on completion)
| Property | Start | End | Duration | Curve |
|---|---|---|---|---|
| Opacity | 1 | 0 | 150ms | easeIn |
| Y offset | 0 | −12pt | 150ms | easeIn |

### SwiftUI API
```swift
List { ... }
    .refreshable {
        await viewModel.sync()
    }
// Override tint via ProgressView in the list header or use
// .tint(theme.accent) on the List
```

---

## 2. Article List — Appear / Disappear

**Appear trigger:** New article is inserted (iCloud sync, Share Extension save).  
**Disappear trigger:** Article is deleted or archived.

### Appear
| Property | Start | End | Duration | Curve |
|---|---|---|---|---|
| Opacity | 0 | 1 | 300ms | spring(0.4, 0.75) |
| X offset | −16pt | 0 | 300ms | spring(0.4, 0.75) |

### Disappear
| Property | Start | End | Duration | Curve |
|---|---|---|---|---|
| Opacity | 1 | 0 | 200ms | easeIn |
| X offset | 0 | +16pt | 200ms | easeIn |

### SwiftUI API
```swift
ForEach(articles) { article in
    ArticleRow(article: article)
        .transition(
            .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal:   .move(edge: .trailing).combined(with: .opacity)
            )
        )
}
.animation(VersoAnimation.slow, value: articles)
```

---

## 3. Loading Spinner (Initial / Mid-session)

**Trigger:** App launch with empty cache, or background sync started while list is visible.

### Entry (delayed to avoid flash on fast loads)
| Property | Start | End | Delay | Duration | Curve |
|---|---|---|---|---|---|
| Opacity | 0 | 1 | 100ms | 150ms | easeOut |

### Spinner
| Property | Value |
|---|---|
| Size | 28pt diameter |
| Color | `theme.accent` |
| Rotation | 800ms linear, repeat forever, no autoreverse |

### Exit (when content arrives)
| Property | Start | End | Duration | Curve |
|---|---|---|---|---|
| Opacity | 1 | 0 | 200ms | easeOut |

### SwiftUI API
```swift
if isLoading {
    ProgressView()
        .progressViewStyle(.circular)
        .tint(theme.accent)
        .frame(width: 28, height: 28)
        .transition(.opacity.animation(VersoAnimation.fast))
}
```

---

## 4. Screen Transitions

### 4a. List → Article Detail (Push)

| Layer | Animation |
|---|---|
| Navigation chrome | System NavigationStack slide (no override) |
| Article body content | Fade in: opacity 0→1, 250ms easeOut, 50ms delay after push settles |

The delay lets the system slide complete before revealing text, preventing content from appearing to "race" the chrome.

```swift
// In ArticleDetailView
.opacity(appeared ? 1 : 0)
.onAppear {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        withAnimation(VersoAnimation.normal) { appeared = true }
    }
}
```

### 4b. Article Detail → List (Pop / Back)

| Layer | Animation |
|---|---|
| Navigation chrome | System swipe-back gesture (no override) |
| Previously selected row | Row background briefly highlights: opacity 0.12→0, 300ms easeOut |

```swift
// In ArticleRow, on re-appear
.background(
    theme.accent
        .opacity(isReturningFrom ? 0.12 : 0)
        .animation(VersoAnimation.normal, value: isReturningFrom)
)
```

### 4c. Sheets (Folder Picker, etc.)

System sheet slide-up/slide-down. No override — system behavior is appropriate.

---

## Notes

- All durations respect iOS accessibility **Reduce Motion** setting. When enabled, substitute `.opacity` transitions for `.move` and `.slide` transitions.
- Timing tokens in `VersoAnimation` should be the single source of truth — avoid hardcoded duration literals elsewhere.
- The 50ms article-content delay (§4a) is a heuristic; validate against real NavigationStack timing on device.
