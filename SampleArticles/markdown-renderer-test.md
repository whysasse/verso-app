---
title: Markdown Renderer Test
source: Verso QA
url: https://example.com
date: 2026-05-09
---

# Heading One: The Quick Brown Fox

This is a regular paragraph. It contains **bold text**, _italic text_, and ***bold italic text*** all in the same sentence. Here is some `inline code` mid-paragraph, and here is a [link to somewhere](https://example.com).

## Heading Two: Lists and Structure

Here is an unordered list:

- First item in the list
- Second item, a bit longer to test wrapping behavior on narrow screens
- Third item with **bold** inside it
- Fourth item with `inline code` inside it

And an ordered list:

1. Step one: do the thing
2. Step two: check the thing
3. Step three: ship the thing
4. Step four: a longer step description to verify number alignment holds up across multiple lines of text

## Heading Two Again: Quotes and Rules

> This is a blockquote. It should show an accent-colored vertical bar on the left side. The text is in a secondary color and italic. Here is a longer sentence to make the blockquote wrap onto a second line so the border alignment can be verified.

---

## Heading Two: Code Blocks

A fenced code block in Swift:

```swift
struct ContentView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Text("Count: \(count)")
                .font(.title)
            Button("Increment") {
                count += 1
            }
        }
    }
}
```

A plain code block with no language tag:

```
GET /api/articles HTTP/1.1
Host: example.com
Accept: application/json
```

---

## Heading Two: Mixed Content

### Heading Three: Inline Styles Together

You can combine styles: **bold text followed by _italic text_** in the same paragraph. Or start with _italic and switch to **bold**_. Inline `code snippets` appear in accent color at a slightly smaller size.

#### Heading Four: The Smallest Head

This is under an H4. The heading should be visibly smaller than H3 but still distinct from body text. Below is a short paragraph to confirm the spacing between heading and body looks right.

A short paragraph under H4.

### Heading Three: Another Section

A paragraph before a list to check the spacing between a prose block and a list block.

- Alpha
- Beta
- Gamma: a longer item to ensure the bullet stays anchored to the first line even when the text wraps

1. First
2. Second
3. Third: again a longer item to verify number column alignment is stable on wrapped lines

A paragraph after the list to check the spacing on the other side.

---

## Heading Two: Horizontal Rules

Three horizontal rules follow, each preceded by a short line of text.

Above rule one.

---

Above rule two.

---

Above rule three.

---

## Heading Two: Long Paragraph

This is a longer paragraph designed to test line spacing, line length, and readability at the default font size. The quick brown fox jumps over the lazy dog. The five boxing wizards jump quickly. Pack my box with five dozen liquor jugs. How valiantly did Fabio adjust the zinc oxbow. Sphinx of black quartz, judge my vow. The job requires extra pluck and zeal from every young wage earner. This is the end of the long paragraph.

## Heading Two: End

This is the final paragraph of the test article. If everything above rendered correctly — headings in hierarchy, bold and italic inline, accent-colored links and inline code, blockquotes with a left border, code blocks with a surface background, clean bullet and number lists, and thin horizontal rules — the Markdown renderer is working as expected.
