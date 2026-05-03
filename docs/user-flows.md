# Verso — Primary User Flows

**FAB-58** · High-level flowcharts for the 3 core journeys. Deliverable to unblock wireframing.

---

## Flow 1 — Save Article via Share Sheet

The user encounters an article in any app (Safari, Twitter/X, RSS reader, etc.) and sends it to Verso using the iOS Share Sheet.

```mermaid
flowchart TD
    A([User reading article in any app]) --> B[Taps Share button]
    B --> C[iOS Share Sheet appears]
    C --> D[Taps Verso in Share Sheet]
    D --> E{iCloud folder\nconfigured?}

    E -- No --> F[Prompt: Open Verso to finish setup]
    F --> G([User opens Verso app to complete onboarding])

    E -- Yes --> H[Share Extension loads URL]
    H --> I[WKWebView runs Readability.js\non the URL]
    I --> J{Parsing\nsuccessful?}

    J -- No --> K[SwiftSoup fallback parser runs]
    K --> L[Basic content extracted]
    J -- Yes --> L

    L --> M[Content converted to Markdown]
    M --> N[Preview shown: title, estimated read time, thumbnail]
    N --> O{User confirms?}

    O -- Cancels --> P([Share Extension closes, returns to app])
    O -- Taps Save --> Q[Markdown file written to iCloud Drive folder]
    Q --> R[Save confirmation shown]
    R --> P
```

---

## Flow 2 — Read Article with All Features

The user opens Verso and reads a saved article using available reading customisation options.

```mermaid
flowchart TD
    A([User opens Verso]) --> B[App scans iCloud Drive folder]
    B --> C[Article list loads\nsorted by date, newest first]
    C --> D[User taps an article]
    D --> E[Article reader opens\ndefault: Paper theme, New York font]
    E --> E2[Article status set to 'reading'\nif it was 'unread']

    E2 --> F{User action}

    F -- Taps screen --> G[Toggle immersive mode\nhide / reveal chrome]
    G --> F

    F -- Opens Theme menu --> H[Selects theme:\nPaper · Sepia · Night · Ink]
    H --> F

    F -- Opens Font menu --> I[Selects font:\nNew York · Georgia · SF · OpenDyslexic]
    I --> F

    F -- Adjusts text size --> J[Font size increases / decreases]
    J --> F

    F -- Scrolls to end --> K[Article marked as read]
    K --> L[User taps Back]

    F -- Taps Back --> L
    L --> C
```

---

## Flow 3 — Archive and Search

Two related flows for managing the article library: finding articles via search and archiving articles the user no longer wants in the main list.

```mermaid
flowchart TD
    A([User is on article list]) --> B{User action}

    %% Search path
    B -- Taps Search icon --> C[Search bar appears]
    C --> D[User types query]
    D --> E[Results filter in real-time\nmatches title + body content]
    E --> F{Result found?}
    F -- No --> G[Empty state: no results]
    G --> D
    F -- Yes --> H[User taps a result]
    H --> I([Article reader opens])

    %% Archive path
    B -- Swipes left on article --> J[Archive action appears]
    J --> K[User taps Archive]
    K --> L[Markdown file moved to\n/Archived subfolder in iCloud Drive]
    L --> M[Article removed from main list]
    M --> N{User wants to\nsee archived?}
    N -- No --> A
    N -- Yes, taps filter --> O[Archive view shows\nall archived articles]
    O --> P{User action in Archive}
    P -- Taps article --> I
    P -- Swipes to unarchive --> Q[File moved back to\nmain iCloud Drive folder]
    Q --> A
```

---

*These flows are intentionally high-level — they cover the main path and key decision points. Edge cases (network errors, corrupted files, permission denied) are deferred to a later detailed spec.*
