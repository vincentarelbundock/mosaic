---
name: mosaic
description: Create, edit, debug, and verify slide decks built with the Mosaic package for Typst. Use when working with Mosaic setup, themes, title/content/section layouts, custom grids, named cells, native Typst styling, incremental reveals, speaker notes, or Mosaic compilation errors.
---

# Mosaic for Typst

Build Mosaic decks as ordinary Typst documents. Prefer the smallest authoring surface that fits the request: headings for ordinary slides, named layouts for title and section slides, and low-level grids only for genuinely custom composition.

## Establish the environment

1. Inspect the existing deck and preserve its import spelling and theme. Do not replace a themed facade with the root facade unless asked.
2. Check that Typst is available with `typst --version`.
3. When Mosaic is not installed, clone and install the package locally:

   ```sh
   git clone https://github.com/vincentarelbundock/mosaic.git
   cd mosaic
   make install
   ```

4. Compile from the project root when the deck uses repository-relative assets:

   ```sh
   typst compile --root . path/to/deck.typ
   ```

Do not claim success until Typst has compiled the edited deck.

## Start with ordinary slides

Use this complete baseline for a new local deck:

```typ
#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(title: [A short title])

#m.slide(layout: "title")

= First section

== Main result

Write ordinary Typst content.

== Evidence

- First point
- Second point
```

A level-one heading creates an unnumbered section slide. A level-two heading creates a numbered content slide whose heading fills `header` and following content fills `body`. Use explicit `m.slide` only when a heading slide is insufficient.

## Select layouts

`layout` selects both a configured design and its slide semantics:

```typ
#m.slide()                    // configured content layout
#m.slide(layout: "content")
#m.slide(layout: "title")
#m.slide(layout: "section")
```

The standard names are `content`, `title`, and `section`. Content slides are numbered by default; title and section slides are not. Section slides advance the section counter. `numbered:` explicitly overrides the numbering default.

Use a layout factory when one slide needs a variant:

```typ
#m.slide(
  layout: m.layouts.title(
    title: [Reliable systems],
    subtitle: [One source of truth],
    variant: "accent-block",
  ),
)

#m.slide(
  layout: m.layouts.content(variant: "header-body", columns: 2),
  content: (
    header: [Comparison],
    body-1: [First column],
    body-2: [Second column],
  ),
)

#m.slide(
  layout: m.layouts.section(subtitle: [What changes]),
)[Methods]
```

Title variants are `academic`, `left-aligned`, `centered-stack`, `accent-block`, `image-left`, `image-right`, `image-top`, `image-bottom`, and `image-background`. Section variants are `plain` and the same five image variants. Content variants are `body`, `header-body`, `body-footer`, and `header-body-footer`.

A direct `m.layouts.content/title/section(...)` value retains its semantic layout name. A raw custom grid uses ordinary content-slide semantics.

## Configure the deck once

Put deck identity, semantic colors, layout overrides, recurring cell defaults, and page planes in `m.setup`:

```typ
#let authors = (
  m.layouts.author("Ada Lovelace"),
)

#show: m.setup.with(
  title: [Reliable systems],
  subtitle: [One source of truth],
  authors: authors,
  date: [2026],
  colors: (accent: rgb("#007f73")),
  content: (
    footer: [Mosaic · Engineering],
    foreground: [#place(bottom + right)[#m.components.progress()]],
  ),
)

#m.slide(layout: "title")
```

The semantic color keys are `canvas`, `surface`, `accent`, `text`, `muted`, and `line`. Color overrides are partial. Do not introduce a separate footer, logo, background, or foreground feature API: recurring named-cell content and the reserved `content.background` / `content.foreground` planes own those jobs. Set an explicit value to `none` to suppress an inherited default.

Setup does not insert a title slide automatically.

## Use themes as facades

Import one facade as `m` and keep the rest of the deck unchanged:

```typ
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.dark as m

#show: m.setup
```

Bundled facades are `light`, `dark`, `cream`, `metropolis`, and `minimalist`. The root package is the canonical light facade. Theme definitions are passive data consumed by Mosaic's engine; do not call setup internals from a theme.

## Build custom structure only when needed

A Mosaic grid is a transparent tree of named cells:

```typ
#let comparison = m.grid.h(
  m.grid.t(2fr, "main"),
  m.grid.v("details", "notes"),
)

#m.slide(
  layout: comparison,
  content: (
    main: [Main result],
    details: [Supporting detail],
    notes: [Interpretation],
  ),
)
```

- `m.grid.h` splits horizontally.
- `m.grid.v` splits vertically.
- `m.grid.t(size, child)` assigns a native Typst track size.
- `m.grid.cell(id, ...)` creates an explicitly configured cell.
- Positional bodies fill content-bearing cells in traversal order.
- `content:` fills cells by stable ID and is clearer for multi-cell layouts.
- Do not combine positional bodies with named cell content.

Use a layout factory instead of rebuilding a standard title, section, header/body, or footer structure as a raw grid.

## Style with native Typst rules

Mosaic labels every rendered cell `<mosaic-cell-ID>`. Style that label with ordinary Typst `show` and `set` rules:

```typ
#show label("mosaic-cell-body"): set align(horizon)
#show label("mosaic-cell-body"): it => block(
  width: 100%,
  height: 100%,
  fill: luma(240),
  inset: 1.2em,
  it,
)
```

Apply typography and content rules after `#show: m.setup`. Do not invent a separate Mosaic styling API or put decorative styling into the grid tree. Use `m.surface` and `m.components` when their documented semantic treatments fit; otherwise use native Typst.

## Add reveals and notes

Use `m.pause` for persistent source-order reveals:

```typ
#m.slide[
  == Findings
  - The estimate is positive.
  #m.pause
  - The interval excludes zero.
]
```

Use `m.steps.on`, `m.steps.reveal`, `m.steps.replace`, or `m.steps.reduce` for explicit timing and replacement. Mosaic discovers the frame count. `setup(handout: true)` emits only the final frame of each logical slide.

Attach notes with `m.note[...]`. Notes do not render in the default `output: "slides"`. Use `output: "speaker"` for slide thumbnails plus notes or `output: "notes"` for notes only.

## Diagnose before changing structure

When compilation fails:

1. Recompile the smallest affected deck and capture the exact diagnostic.
2. Check for an unknown layout name, a missing named cell, mixed positional and named content, or an invalid layout variant.
3. Confirm that dictionary-held functions are called with parentheses when needed, for example `(theme.layouts.section)()`.
4. Confirm that `layouts:` passed to setup is a dictionary and only overrides `content`, `title`, or `section`.
5. Confirm that image variants receive an image and valid tracks.
6. Change the narrowest source responsible, then recompile the original deck.

Do not add compatibility aliases for removed APIs. In particular, slides use `layout:`, not a separate semantic selector.

## Verify the result

For a deck change:

```sh
typst compile --root . path/to/deck.typ /tmp/deck.pdf
pdfinfo /tmp/deck.pdf
```

Inspect representative rendered pages when structure, spacing, themes, images, or incremental frames changed. Check title, section, ordinary content, and any custom grid separately.

For changes inside the Mosaic repository:

```sh
make install
make check
make website
```

Completion requires:

- every edited deck compiles from current sources;
- page count and incremental frames are plausible;
- no content is clipped, overlapped, or assigned to the wrong cell;
- automatic and explicit slides use the intended layout;
- documentation examples use the same public API as the package;
- removed APIs were not reintroduced as aliases.
