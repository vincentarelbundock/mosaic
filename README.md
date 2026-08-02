# Mosaic

Mosaic 0.0.1 is a slide package for Typst. A slide is a grid of cells between a
background and foreground plane. Mosaic labels every cell `<mosaic-cell-ID>`, and
styling is ordinary Typst `show` and `set` rules on those labels; there is no
separate styling API. Mosaic manages grids, page boundaries, logical slide
numbering, full-slide background and foreground planes, and incremental
visibility. Page setup, typography, headings, figures, colors, and document
semantics remain ordinary Typst rules.

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

Each `==` heading writes a heading slide on `layouts.default(variant: "header-body")`: its
text fills the header cell and the content that follows fills the body. Mosaic
uses a zero page margin so cells and planes can reach the slide edges; content
spacing is each cell's `inset`.

Mosaic has three concepts: structure, content, and appearance.

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

`m.layouts` provides ready-made grids for familiar structures (`default`,
`title`, and `section`), each resolving to the same grid model. Pass one to
`m.slide(grid: ...)`; compose images and tables with native Typst content.

## Content

Fill a grid's content-bearing cells (those with `content: none`) positionally
in traversal order, or by ID with `content:`. Both are equivalent; `content:` reads
on its own for multi-cell grids and does not depend on grid order.

```typ
#m.slide(grid)[Main][Details][Notes]

#m.slide(
  grid: grid,
  content: (main: [Main], details: [Details], notes: [Notes]),
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
the single handle: `cell(id)` defines, `content: (id: …)` fills,
`label("mosaic-cell-id")` styles.

```typ
#show label("mosaic-cell-body"): set align(horizon)
#show label("mosaic-cell-body"): it => block(width: 100%, height: 100%, fill: luma(240), it)
```

Typography, headings, captions, page color, and text color are native `set`/`show`
rules placed after `#show: m.setup`. Spacing and furniture flow through `setup`;
built-in colored layout decoration takes an explicit `accent:`:

```typ
#show: m.setup.with(
  features: (slide-number: true, progress: true),
)
#set page(fill: rgb("#111827"))
#set text(font: "EB Garamond", size: 26pt, fill: rgb("#f3f4f6"))
#show heading.where(depth: 2): set text(size: 1.4em)
```

Precedence is native rule nesting: `setup` and themes set baselines, deck-level
rules override them, and a rule scoped in a block around one `m.slide` overrides
them for that slide only.

## Incremental content

`m.steps.on`, `m.steps.reveal`, `m.steps.replace`, and `m.steps.reduce` attach explicit step ranges to
content; the step count is discovered automatically and each step renders as one
frame. `setup(handout: true)` emits only the final frame of each logical slide.

```typ
#m.slide[
  == Findings
  #m.steps.reveal[
    - The estimate is positive.
    - The interval excludes zero.
  ]
]
```

## Speaker notes

`m.note[...]` attaches non-rendering Typst content to the current logical slide.
Ordinary notes apply to every frame. Put a note inside `m.steps.on`,
`m.steps.reveal`, or `m.steps.replace` to give it the same automatic frame
assignment as nearby incremental content; notes never create frames themselves.

```typ
#m.slide[
  #m.note[Introduce the result.]
  #m.steps.reveal(
    [Estimate #m.note[Explain the sign and magnitude.]],
    [Interval #m.note[Discuss uncertainty.]],
  )
]
```

The default `output: "slides"` omits note text from the presentation. Build a
printable A4 companion document with either `output: "speaker"` (slide thumbnail
plus applicable notes) or `output: "notes"` (notes only):

```typ
#show: m.setup.with(output: "speaker")
```

Every emitted frame also carries queryable `<mosaic-speaker-notes>` metadata
with its logical slide number, frame number, and applicable note content.
Companion output is one A4 page per emitted frame; compilation reports an
explicit overflow error when the applicable notes do not fit that page.

## Bundled themes

`m.themes` bundles three complete Mosaic facades (`metropolis`, `cream`, and
`minimalist`). Import one as `m`; it provides themed `setup` and `layouts`
alongside the ordinary Mosaic API:

```typ
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.metropolis as m

#show: m.setup

#m.slide(
  grid: m.layouts.title([My talk], subtitle: [A subtitle]),
  numbered: false,
)

== Ordinary content

#m.slide(
  grid: m.layouts.section(),
  content: (section: [Methods]),
  section: true,
  numbered: false,
)
```

The themed `setup` exposes a few knobs via `.with(...)`. For deeper changes,
copy the theme beside your deck, import the copy as `m`, and edit it freely.
A theme is a small Mosaic facade plus native rules;
the Grayscale theme in `docs/examples/decks/portfolio/` shows the vendored, copy-me
side of the convention.

## Development

```sh
make doctor          # report required, target-specific, and optional tools/fonts
make install         # copy mosaic/ into Typst's local package index
make check           # run package, diagnostic, and documentation-integrity tests
make website         # build examples, API reference, and the Calepin site
make build           # validate prerequisites, test, and build the complete site
```

`make check` and `make website` install the package first, so their
`@local/mosaic:0.0.1` imports always use the current sources. Individual decks
compile directly, for example `typst compile --root . tests/grid-runtime.typ`. The
negative fixtures under `tests/invalid/` verify clear diagnostics for malformed
grids, layouts, tracks, timing ranges, cell operations, heading placement, and
conflicting slide arguments. Every positive deck is classified explicitly in
`tests/positive-manifest.json`; every invalid fixture has an exact message in
`tests/invalid/expected-diagnostics.txt`. `scripts/run-tests.py` owns output
inspection instead of embedding assertions in Make recipes.

Core checks require Python, Typst, Poppler's `pdftotext`, and `pdfinfo`.
Documentation builds additionally require Calepin, Poppler's `pdftoppm`,
FFmpeg, and Pillow. `kpsewhich`, R, `jupyter_client`, and the bundled-theme fonts
reported by `make doctor` are optional. Missing optional fonts change metrics or
produce warnings but do not invalidate package tests.

Generated files have three lifetimes. `make clean` removes ephemeral staging and
stamp files. `make clean-generated` also removes reproducible PDFs, covers,
embedded assets, WebP derivatives, and the showcase video. `make distclean`
additionally removes published HTML and Calepin cache files. The repository keeps
authored documentation and intentional publication artifacts in `docs/`, while
Calepin's regenerable `_calepin` cache is ignored except for the published
favicon.

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the module layers and the rules for
placing new code.
