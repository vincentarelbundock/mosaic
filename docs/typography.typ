#import "/.calepin/calepin.typ" as calepin

#set document(title: [Typography])
#metadata((title: "Typography")) <website-metadata>

#title()

Style type with Typst's native `text`, `heading`, `par`, and `list` rules.
Place them after the `m.setup` show rule and they apply throughout the deck.

= Set the deck font

A document-wide `set text` sets the base font, size, and fill:

```typ
#show: m.setup

#set text(font: "EB Garamond", size: 26pt)
```

That single rule reaches every slide, including template bodies and hand-built
grid cells.

= Style titles and headings

Level-1 headings are section titles and level-2 headings are slide titles.
Style them with show rules keyed on `heading`:

```typ
#show heading.where(depth: 1): set text(font: "Inter", weight: "black")
#show heading.where(depth: 2): set text(size: 1.4em)
```

Anything `text` accepts works here, including `fill`, `tracking`, and `style`.

= Large decorative text

A `heading` is semantic: it feeds the outline, PDF bookmarks, and
`m.current-heading`, and drives automatic section slides. Use it for real
titles.

For large type that should *not* appear in navigation — a cover word, a pull
quote, a number — use `text` directly, or exclude the heading:

```typ
// Styled, but absent from the outline and bookmarks.
#text(size: 60pt, weight: "black")[BOLD]

// A heading kept out of navigation furniture.
#heading(outlined: false, bookmarked: false)[Aside]
```

Keep a heading stable across a slide's incremental frames: it cannot be placed
inside an incremental grid node (`m.grid.on`, `m.reveal`, and related reducers).

= Paragraphs and lists

Leading, spacing, and list markers belong to `par`, `list`, `enum`, and
`terms`. Mosaic sets sensible list spacing by default; override it when a slide
needs it:

```typ
#set par(leading: 0.8em)
#set list(marker: [—])
```

= Captions and supporting text

Style figure captions through `figure.caption`:

```typ
#show figure.caption: set text(size: 0.8em, style: "italic")
```

For other supporting text — bylines, footnotes, asides — apply `text` at the
point of use or with your own show rule.
