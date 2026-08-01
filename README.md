# Mosaic

Mosaic 0.0.1 is a minimal slide package for Typst. A slide is a grid of cells;
Mosaic owns the structure and content routing, and appearance stays native
Typst. It manages grids, page boundaries, logical slide numbering, full-slide
background and foreground planes, and incremental visibility. Page setup,
typography, headings, figures, colors, and document semantics remain ordinary
Typst rules.

The full guide and API reference live in `docs/` (build with `make website`) and
the architecture is documented in [`ARCHITECTURE.md`](ARCHITECTURE.md). This
file is a quick start.

## Quick start

```typ
#import "@local/mosaic:0.0.1" as m

#show: m.setup

== Ordinary slide

Write normal Typst content.

== Results

- Main result
- Supporting evidence
```

Each `==` heading starts a `layouts.default(variant: "header-body")` slide: its
text fills the header cell and the content that follows fills the body. Mosaic
uses a zero page margin so cells and planes can reach the slide edges; content
spacing is each cell's `inset`.

Mosaic has three concepts — structure, content, and appearance.

## Structure

Grids are trees of cells. `m.grid.h` places cells side by side, `m.grid.v`
stacks them, either nests, and `m.grid.t(size, child)` sets a non-default track
size. Each string is a stable cell ID.

```typ
#let grid = m.grid.h(
  m.grid.t(2fr, "main"),
  m.grid.v("details", "notes"),
)
```

`m.layouts` provides ready-made grids for familiar structures — `default`,
`title`, `section`, `image`, and `table` — each resolving to the same grid
model. Pass one to `m.slide(grid: ...)`.

## Content

Fill a grid's content-bearing cells (those with `content: none`) positionally
in traversal order, or by ID with `cells:`. Both are equivalent; `cells:` reads
on its own for multi-cell grids and does not depend on grid order.

```typ
#m.slide(grid)[Main][Details][Notes]

#m.slide(
  grid: grid,
  cells: (main: [Main], details: [Details], notes: [Notes]),
)
```

A cell whose content the grid owns (an image, a logo) gets `content:` in the
grid and consumes no slide body:

```typ
#m.grid.cell("logo", content: image("logo.svg"))
```

## Appearance

Cells are structural and carry no styling. Every rendered cell is one block
labeled `<mosaic-cell-ID>`, so you style it with ordinary rules. The cell ID is
the single handle: `cell(id)` defines, `cells: (id: …)` fills,
`label("mosaic-cell-id")` styles.

```typ
#show label("mosaic-cell-body"): set align(horizon)
#show label("mosaic-cell-body"): it => block(width: 100%, height: 100%, fill: luma(240), it)
```

Typography, headings, and captions are native `set`/`show` rules placed after
`#show: m.setup`. Deck-wide colors, spacing, and furniture flow through `setup`:

```typ
#show: m.setup.with(
  colors: m.color.scheme("dark") + (accent: rgb("#e69f00")),
  features: (slide-number: true, progress: true),
)
#set text(font: "EB Garamond", size: 26pt)
#show heading.where(depth: 2): set text(size: 1.4em)
```

Precedence is native rule nesting: `setup` and themes set baselines, deck-level
rules override them, and a rule scoped in a block around one `m.slide` overrides
them for that slide only.

## Incremental content

`m.on`, `m.reveal`, `m.replace`, and `m.reduce` attach explicit step ranges to
content; the step count is discovered automatically and each step renders as one
frame. `setup(handout: true)` emits only the final frame of each logical slide.

```typ
#m.slide[
  == Findings
  #m.reveal[
    - The estimate is positive.
    - The interval excludes zero.
  ]
]
```

## Bundled themes

`m.themes` bundles three polished themes — `metropolis`, `cream`, and
`minimalist` — each an ordinary Typst module exporting `apply` (the document
wrapper), the layout factories `default`, `title`, and `section`, plus `colors`
and `palette`:

```typ
#import "@local/mosaic:0.0.1" as m
#let theme = m.themes.metropolis

#show: theme.apply

#theme.title([My talk], subtitle: [A subtitle])

== Ordinary content

#theme.section([Methods])
```

`apply` exposes a few knobs via `.with(...)`. For deeper changes, copy the theme
file from `mosaic/src/themes/` next to your deck, import the copy, and edit it
freely. A theme is just a `#show:` wrapper around `setup` plus native rules;
the Grayscale theme in `docs/examples/portfolio/` shows the vendored, copy-me
side of the convention.

## Development

```sh
make install   # copy mosaic/ into Typst's local package index
make check     # compile every test deck; verify every invalid fixture fails
make website   # build the tutorial slides, API reference, and Calepin site
make build     # check, then build slides and website
```

`make check` and `make website` install the package first, so their
`@local/mosaic:0.0.1` imports always use the current sources. Individual decks
compile directly, for example `typst compile --root . tests/test.typ`. The
negative fixtures under `tests/invalid/` verify clear diagnostics for malformed
grids, layouts, tracks, timing ranges, cell operations, heading placement, and
conflicting slide arguments.

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the module layers and the rules for
placing new code.
