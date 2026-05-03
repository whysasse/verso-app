# Verso — Secondary User Flows

**FAB-59** · Flowcharts for secondary journeys: offline reading, iCloud Drive data access, tagging, progress saving, and text-to-speech.

---

## Flow 4 — Offline Reading & iCloud Drive Data Access

Two related flows that share the same underlying concern: how and where Verso's data lives. The first path covers what happens when the device loses connectivity; the second covers how a power user can access their Markdown files directly via the iOS Files app.

```mermaid
flowchart TD
    A([User opens Verso]) --> B{Network &\niCloud available?}

    %% Online path
    B -- Yes → online --> C[iCloud Drive syncs\nArticle list refreshed]
    C --> D([Normal reading — all features available])

    C --> E{User wants to\naccess files directly?}
    E -- Opens iOS Files app --> F[Navigates to\niCloud Drive → Verso folder]
    F --> G{Action in Files app}
    G -- Adds .md file --> H[File appears in Verso\non next sync]
    G -- Moves or deletes file --> I[Change reflected in\nVerso on next sync]
    G -- Opens or shares file --> J[iOS handles file\nin another app or Share Sheet]

    %% Offline path
    B -- No → offline --> K[Offline banner shown\nApp loads local cache]
    K --> L{Article already\ncached on device?}
    L -- Yes --> M[Article opens normally]
    L -- No --> N[Article greyed out\n'Not available offline']

    M --> O[User reads article\nProgress & tags saved locally]
    O --> P{Connection restored?}
    P -- Yes --> Q[Local changes sync\nto iCloud Drive]
    P -- Still offline --> O
```

---

## Flow 5 — In-Reader Features: Tags, Progress Saving & Text-to-Speech

Three features available from within the article reader. All are optional and non-destructive — the user can ignore any of them and simply read.

```mermaid
flowchart TD
    A([User opens article]) --> B[Reader loads at\nlast saved position]
    B --> C{User action}

    %% Progress saving
    C -- Scrolls and reads --> D[Position auto-saved\nperiodically in background]
    D --> E{User exits article?}
    E -- No --> C
    E -- Yes --> F[Position written to\nMarkdown frontmatter]
    F --> G[Next open: reader\nrestores saved position]

    %% Tagging
    C -- Taps Tag icon --> H[Tag panel slides up]
    H --> I{Any existing tags?}
    I -- Yes --> J[Shows current tags\nUser selects or deselects]
    I -- No --> K[Empty state:\ntype to create first tag]
    J --> L[User types a new tag]
    K --> L
    L --> M[Tag saved to\nMarkdown frontmatter]
    M --> N[Tag available as\nfilter in article list]
    N --> C

    %% Text-to-speech
    C -- Taps TTS button --> O[TTS panel appears\nwith speed control]
    O --> P[Playback starts from\ncurrent scroll position]
    P --> Q[Text highlighted\nas it is spoken]
    Q --> R{User action}
    R -- Pause / Resume --> P
    R -- Adjusts speed --> P
    R -- Closes reader --> S[Audio continues\nin background]
    S --> T[Lock screen & Control Centre\nshow playback controls]
    R -- Reaches end of article --> U[Playback stops\nArticle marked as read]
```

---

*These flows cover the happy path and key decision points. Error states (e.g. iCloud sync conflicts, TTS engine unavailable, corrupted frontmatter) are deferred to a later detailed spec.*
