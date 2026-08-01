# Mosaic

Mosaic 0.0.1 is a minimal slide package for Typst. It represents slide
grids as trees composed from horizontal and vertical splits:

> An empty cell consumes one slide body. A fixed-content cell supplies its own
> content. `m.grid.h` and `m.grid.v` arrange cells recursively.

Mosaic manages grid, page boundaries, logical slide numbering, full-slide
background and foreground planes, and incremental visibility. Page setup,
typography, headings, figures, styling, and document semantics remain native
Typst.

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

Each `==` heading starts a `layouts.default(variant: "header-body")` slide. Its text fills the
header cell, and the content that follows fills the one-column body cell.

Mosaic presentations conventionally use a zero page margin so grids,
cell surfaces, and visual planes can reach the physical slide edges. Content
spacing belongs to cell `inset`; the default inset is applied uniformly to
every side of every cell. Adjacent cells therefore contribute one inset each
to the space between their content. Image cells can use `0pt` to bleed to
their cell edges. `gutter` adds space between adjacent cell surfaces and
defaults to `0pt`.

## Semantic layouts

`m.layouts` is a namespace of semantic layout constructors layered above
grids and cells. Constructors emit deferred grid dictionaries; pass one to
`slide(grid: ...)`. The deck compiler resolves its geometry and appearance only
after `setup` has established the document-wide presentation settings.

```typ
#let brand = m.setup.with(
  colors: m.color.scheme("dark") + (
    accent: rgb("#e69f00"),
  ),
  features: (
    slide-number: true,
    slide-total: true,
    progress: true,
    footer: [Research group],
  ),
)

#show: brand

#m.slide(grid: m.layouts.title(
  [Mosaic],
  subtitle: [A setup-driven semantic deck],
  authors: (m.author([Vincent]),),
))

#m.slide(grid: m.layouts.image(
  variant: "figure",
  path: path("/docs/assets/images/bonsai.webp"),
  alt: "Bonsai tree",
))
```

`m.color.scheme("light")` and `m.color.scheme("dark")` return complete
semantic color dictionaries for `setup(colors: ...)`. `m.color.palette`
returns an ordered categorical color array instead of configuring the deck.

The public layout collection contains five constructors:

- `default`: optional full-width header and footer cells around an
  argument-controlled body column grid, with independent per-cell backgrounds
  and scheme-derived inverse colors for selected header/footer cells through
  `inverted`, native body-column `tracks`, and optional foreground progress via
  `progress: "number"`, `"circle"`, or `"line"`;
- `title`: `academic`, `left-aligned`, `centered-stack`, `accent-block`,
  `image-left`, `image-right`, `image-top`, `image-bottom`, and
  `image-background`; the title text is the first positional argument and the
  surrounding `slide` consumes no bodies; the academic structure
  accepts arrays of validated `author()` objects with de-duplicated affiliations,
  generated superscripts, contacts, and event and date metadata; `rule`
  controls the short accent rule (drawn on text variants, omitted on image
  variants by default) and `align` anchors the `image-background` title
  stack over the unmodified image;
- `section`: `plain`, `image-left`, `image-right`, `image-top`, `image-bottom`,
  and `image-background`, with optional numbering and visual-order `tracks`;
- `image`: `full`, `figure`, `left`, `right`, `top`, and `bottom`, with optional
  path-managed images and native split tracks;
- `table`: title, highlight, caption, and source metadata around native content;

Constructors whose rendering uses a semantic accent accept `role`. Put
`background`, `foreground`, and `numbered` on the surrounding `slide`. Stable
cell IDs reflect meaning, including `image` and `body`.

Set document-wide colors and spacing with `m.setup`. Put local cell
styles on `m.grid.cell`, track sizes on `m.grid.t`, and reusable variations in
ordinary Typst functions or `.with(...)` values.

See `docs/tutorial-examples/layouts/` for focused, compiled layout
examples.

## Bundled themes

`m.themes` bundles three polished themes: `metropolis`, `cream`, and
`minimalist`. Each is an ordinary Typst module exporting `apply` (the
document wrapper), the layout factories `default`, `title`, and `section`,
plus `colors` and `palette`:

```typ
#import "@local/mosaic:0.0.1" as m
#let theme = m.themes.metropolis

#show: theme.apply

#theme.title([My talk], subtitle: [A subtitle])

== Ordinary content

Routed through the theme's default layout.

#theme.section([Methods])
```

`apply` exposes a few knobs via `.with(...)` (for example
`theme.apply.with(base-size: 24pt)`). For deeper customization, copy the
theme file from `mosaic/src/themes/` next to your deck, import the copy, and
edit it freely. The Grayscale theme in `docs/examples/portfolio/` shows that
vendored, copy-me side of the convention.

## API

`setup(body, paper: "16-9", colors: (:), spacing: (:), features: (:),
handout: false, frozen-counters: (), frozen-states: ())` applies presentation
defaults and compiles the document into slides. `paper` accepts
`"16-9"` (the default) and `"4-3"`, the two presentation aspect ratios built
into Typst. Page margins are fixed at zero and the page fill comes from
`colors.canvas`. A `=` heading becomes a section slide and `==` starts a
regular slide.

The default typeface list starts with Inter and ends with Typst's embedded
Libertinus Serif as a guaranteed terminal family. Typst's last-resort glyph
fallback also remains enabled. Body text is 28pt, titles are 2em, slide
headings are 1.4em semibold, captions are 0.72em, and supporting text is 0.55em.
The default cell inset is 1.25em, vertical overflow observation is enabled,
and bulleted, numbered, and term-list items use 0.5em spacing.

Use native Typst rules after setup to override its defaults:

```typ
#show: m.setup

#set text(font: "Libertinus Serif", size: 30pt)
#show heading.where(depth: 2): set text(size: 1.3em, weight: "bold")
#show figure.caption: set text(size: 0.72em)
```

`setup` also renders explicit `slide()` calls, so both authoring styles can be
mixed freely:

```typ
#show: m.setup

== Automatic slide

Write ordinary Typst.

#m.slide(m.grid.h("left", "right"))[Left][Right]

== Automatic again

Continue with headings.
```

`deck()` and `slide()` create deferred Mosaic commands. They must appear in
the document controlled by `#show: m.setup`.

`m.grid.cell(content: none, style: (:), id: none)` creates a named leaf in the
grid tree with a default `1.25em` inset. The default single-cell grid created by
`setup` receives `spacing.inset`. With no `content`, a cell consumes one
body supplied to `slide()`. A fixed-content cell supplies its own content and
consumes no slide body. `id` must be a non-empty string and must be unique
within its grid. The optional style dictionary accepts the native
`m.grid.cell` style fields `fill`, `inset`, `align`, and `stroke`. It also
accepts `before` and `after` fixed content around a consuming body; `fit` as
`"auto"`, `"width"`, `"contain"`, or `none`; and `text`, a dictionary of native
Typst `text` arguments applied to the complete combined cell content:

```typ
#let numbered = m.grid.v(
  "body",
  m.grid.t(auto, m.grid.cell(id: "number", content: align(right)[
    #m.slide-number(total: true)
  ])),
)

#let highlighted = m.grid.cell(
  id: "body",
  style: (
    fill: rgb("#f8dce5"),
    inset: 0.55em,
    text: (
      size: 1.2em,
      weight: "bold",
    ),
  ),
)
```

Cell `text` styling is useful when the complete cell has one typographic role,
such as a title band. Semantic headings remain native Typst elements and
should be styled with ordinary `set heading` and `show heading` rules.

`image(source, width: 100%, height: 100%, fit: "cover", lighten: none,
darken: none, ..native)` is a slide-sized convenience around Typst's native
`image()`. Additional native arguments such as `alt` pass through unchanged.
`lighten` and `darken` add mutually exclusive white or black washes.
Pass project assets as native Typst paths, for example
`m.image(path("photo.webp"))`, so they remain relative to the calling
document across the package boundary.

For a full-bleed image cell, set `content` to `m.image(...)` and the
cell's `inset` to `0pt`.

`m.grid.h(gutter: 0pt, ..children)` arranges string cell IDs or grid nodes
horizontally. `m.grid.v(gutter: 0pt, ..children)` stacks them vertically.
Unwrapped children receive `1fr`; `m.grid.t(size, child)` assigns an explicit
native track size:

```typ
#let grid = m.grid.h(
  m.grid.t(2fr, "main"),
  m.grid.t(1fr, m.grid.v("details", "notes")),
)

#m.slide(grid: grid)[Main][Details][Notes]
```

Strings become consuming cells with stable IDs. `m.grid.h` and `m.grid.v`
produce one canonical split representation. `m.grid.t` has no default size and
is valid only as a direct child of those constructors.

`palette("okabe-ito", lighten: none, darken: none)` returns the eight colors
of the Okabe–Ito color-vision-deficiency-friendly palette as an array. Use
`lighten` or `darken` to transform the complete palette; the two arguments
cannot be combined.

### Components

`components` contains ordinary Typst content, so its results can be used in a
Mosaic cell, a native grid, or any other content context. The initial library
includes:

- containers and compact references: `frame` and `label`;
- slide content: `callout` and `quote`;
- annotations: `divider`;
- navigation: `progress`, with `number`, `circle`, and `line` variants.

`components.progress()` follows the current logical slide automatically and
can be placed in any cell or native Typst container. The numeric treatment is
compact enough for a footer, the ring suits tight corners, and the line fills
its available width:

```typ
#m.components.progress(variant: "number")
#m.components.progress(variant: "circle")
#m.components.progress(variant: "line")
```

Pass `current` and `total` together to display another progress value.

`components.roles` is a dictionary containing the semantic roles
`neutral`, `accent`, `information`, `success`, `warning`, `danger`, and
`takeaway`. Widgets accept a role name and native-style overrides rather than
assigning fixed colors to names such as “warning.”

Cells require a non-empty string `id`; string children passed to `m.grid.h` and
`m.grid.v` are shorthand for consuming cells with that ID.

`deck(default-grid: m.grid.cell(), background: none, foreground: none)` sets
the grid and visual planes inherited by subsequent slides. Call it once near
the start of the document. A later call changes the defaults for the slides
that follow it.

`slide(grid: auto, background: auto, foreground: auto, colors: auto,
numbered: true, ..bodies)` validates a tree, assigns bodies to its empty cells,
and renders one logical slide. `auto` inherits the corresponding deck default,
`none` disables an inherited visual plane, and explicit content overrides it.
Background is painted behind the grid; foreground is painted over it.
Neither plane affects split measurements. Incremental content divides a
logical slide into steps; each step renders as one frame, which is one
PDF page.

Set `handout: true` on `setup` to render only the final frame of each logical
slide. Mosaic retains the final state of timed body content, reducers,
backgrounds, and foregrounds while static slides remain unchanged. Handout mode
does not scale, merge, or otherwise rewrite slide content.

Pass selected native Typst counters or states through `frozen-counters` and
`frozen-states` when repeated physical frames should advance them only once per
logical slide. Mosaic restores their pre-slide values before each continuation
frame; unlisted objects retain native behavior.

Mosaic produces queryable `<mosaic-overflow-warning>` metadata for vertical
cell overflow by default. The diagnostic does not scale or clip content. Set
`features: (overflow: "off")` to disable observation.

A grid tree can be passed as the first positional argument. Positional and
named forms are equivalent:

```typ
#let grid = m.grid.h("left", "right")
#m.slide(grid)[Left][Right]

#m.slide(grid: grid)[Left][Right]
```

A positional grid tree cannot be combined with `grid:`. Textual slide bodies
remain ordinary content blocks:

```typ
#m.slide[Hello] // Content
```

```typ
#m.deck(
  default-grid: m.grid.cell(style: (inset: 32pt)),
  foreground: [
    #place(bottom + right)[
      #pad(right: 32pt, bottom: 20pt)[
        #m.slide-number(total: true)
      ]
    ]
  ],
)

#m.slide(
  background: [
    #place(center)[
      #circle(width: 400pt, fill: blue.lighten(90%))
    ]
  ],
)[
  == Numbered slide
]

// Excluded from logical numbering; inherited foreground is disabled.
#m.slide(numbered: false, foreground: none)[Section title]
```

The visual planes occupy the full usable slide area. Native `place()` can
position any number of canvases, images, logos, labels, or counters within a
plane. `on()`, `replace()`, and `reduce()` work in fixed cells and visual
planes; their ranges contribute to the logical slide's incremental frame
count just like incremental content in a supplied body.

`slide-number(total: false)` displays the current logical slide number. It
advances once per numbered `slide()` call, so all incremental frames belonging
to a slide display the same number. With `total: true`, it displays the current
and final logical counts. On an unnumbered slide it displays nothing.

`step-number(total: false)` displays the current incremental frame number
within the logical slide.

`page-number(total: false)` displays the current physical PDF page number.

```typ
Slide #m.slide-number(total: true)
· step #m.step-number(total: true)
· PDF page #m.page-number(total: true)
```

## Native heading structure

Headings in a logical slide remain native Typst structure. On an incremental
slide, Mosaic emits each source heading as a canonical heading on the first
physical frame only. Later frames repeat the heading body as structurally
inert visual content, so `query(heading)`, `counter(heading)`, native outlines,
PDF bookmarks, labels, and accessible heading structure contain one entry per
source heading rather than one per frame.

Because a continuation is deliberately not a heading element, Mosaic records
the canonical heading's active text, block-spacing, and alignment styles and
reapplies them to its body on later frames. Built-in heading styling and
heading show-set rules therefore remain visually stable while the source can
stay as an ordinary `== Heading`. A transformational show rule that adds
decoration outside `it.body` is not replayed on continuations.

Keep semantic headings structurally stable: placing a heading inside `on`,
`reveal`, `replace`, or `reduce`, including a cell controlled by an incremental
grid node, is rejected.

`current-heading(level: 1, outlined: true, default: none)` returns the active
native heading at the requested resolved level. It must be called in an
ambient Typst context. A shallower heading resets deeper levels, and the
`outlined` filter is applied to the active heading rather than falling back to
an older matching heading:

```typ
#m.deck(
  foreground: context {
    let section = m.current-heading()
    if section != none {
      place(top + right)[
        #text(size: 0.65em, fill: gray)[#section.body]
      ]
    }
  },
)
```

The ordinary Typst outline remains the navigation model:

```typ
#outline(
  title: [Contents],
  target: heading.where(outlined: true),
  depth: 2,
)
```

`setup` turns headings into automatic single-cell slides while preserving
their native Typst structure:

```typ
#show: m.setup.with(
  spacing: (inset: 1.5em),
)

= Methods

== Data

This is one logical slide.

== Model

#m.reveal[
  - Specify the model.
  - Estimate its parameters.
  - Examine the diagnostics.
]
```

A source-depth-one heading (`=`) creates an unnumbered section slide using
setup's larger, centered section style. A source-depth-two heading (`==`)
begins a numbered logical slide. Deeper headings remain ordinary content in
the current slide. These boundaries intentionally use the source heading's
`depth`, preserving existing behavior when `heading(offset: ...)` changes its
resolved native `level`. `current-heading` always uses that resolved level.

Automatic `==` slides use `layouts.default(variant: "header-body")` independently of the
deck's default grid. Section headings accept no body content before the next
source-depth-two heading, and visible content before the first slide is an
error. Use an explicit `slide(grid: ...)` for individual slides that need
custom `m.grid.h()` or `m.grid.v()` splits; automatic headings can continue
before and after it.

The focused decks under `docs/tutorial-examples/basic/` and
`docs/tutorial-examples/navigation/` demonstrate these heading and section
semantics.

`on(range, before: "hidden", after: "hidden", body)` controls when content or
a grid node is active. A range can be an integer (`2`), open (`"2-"` or
`"-2"`), or closed (`"2-4"`). Outside the range, `before` and `after` accept
`"visible"`, `"hidden"` (preserves space), `"dimmed"` (renders text in gray),
or `"removed"` (allows reflow).

```typ
#m.on("2-")[Appears at step 2 and remains.]

#let grid = m.grid.h(
  "first",
  m.on("2-", m.grid.cell(id: "second")),
)
```

`reveal(start: 1, before: "hidden", after: "visible", ..items)` reveals list
items, content blocks, or grid nodes in consecutive steps.

```typ
#m.reveal[
  - First point
  - Second point
  - Third point
]
```

`replace(start: 1, align: top + left, ..bodies)` displays content alternatives
one at a time in one slot sized for the largest alternative. It is intended
for words, text chunks, diagrams, or the contents of a stable Mosaic cell.

`reduce(render: none, hide: none, dim: none, ..args)` adapts a command-based
renderer such as CeTZ or Fletcher. A whole rendered canvas remains ordinary
content and can be wrapped directly in `on`. Inside a reducer, `on` controls
individual commands, while `reveal` can introduce commands consecutively.
The package-specific `hide` function should preserve bounds so the diagram
does not move between steps.

```typ
#import "@preview/cetz:0.5.2"

#let canvas = m.reduce.with(
  render: cetz.canvas,
  hide: cetz.draw.hide.with(bounds: true),
)

#canvas({
  import cetz.draw: *

  circle((0, 0), radius: 1)

  (
    m.on("2-", line((0, 0), (4, 2))),
  )
})
```

Fletcher provides a bounds-preserving `hide` function for its node and edge
metadata, so its diagrams use the same adapter:

```typ
#import "@preview/fletcher:0.5.8" as fletcher

#let diagram = m.reduce.with(
  render: fletcher.diagram,
  hide: fletcher.hide,
)

#diagram(
  fletcher.node((0, 0), [Start]),
  m.reveal(
    start: 2,
    fletcher.edge((0, 0), (1, 0), "->"),
    fletcher.node((1, 0), [Finish]),
  ),
)
```

`"visible"`, `"hidden"`, and `"removed"` work for reduced commands. A
`"dimmed"` command requires a package-specific `dim` function.

The incremental wrappers also work structurally inside math equations:

```typ
$
  f(x)
    = #m.on("1-")[$x^2$]
    #m.on("2-")[$+ 2x$]
    #m.on("3-")[$+ 1$]
$

$
  f(x) = #m.replace(
    [$x^2 + 2x + 1$],
    [$(x + 1)^2$],
  )
$
```

Public callers construct grids instead of mutating or inspecting their
internal records. Use string children for ordinary consuming cells,
`m.grid.cell` for fixed content or local styles, and `m.grid.t` for explicit
track sizes.
The constructors validate every split, track, gutter, and cell ID.

Grids can be nested freely:

```typ
#let common-cell = (
  inset: 0.55em,
  stroke: 1pt + gray,
)

#let feature = m.grid.v(
  gutter: 0.8em,
  m.grid.t(auto, m.grid.cell(
    id: "title",
    style: common-cell + (
      fill: rgb("#f8dce5"),
      text: (size: 1.45em, weight: "bold"),
    ),
  )),
  m.grid.h(
    gutter: 1em,
    m.grid.t(2fr, m.grid.cell(id: "left", style: common-cell)),
    m.grid.v(
      gutter: 0.6em,
      m.grid.cell(id: "middle-top", style: common-cell),
      m.grid.cell(id: "middle-bottom", style: common-cell),
    ),
  ),
  m.grid.t(auto, m.grid.cell(id: "footer", style: common-cell)),
)

#m.slide(feature)[Title][Left][Middle top][Middle bottom][Footer]
```

For grids requiring spans or coordinates, put a native Typst `grid` inside a
single cell. Mosaic's document-wide setup controls semantic colors, typography,
spacing, logos, numbering, and progress furniture. Use native Typst rules for
document-specific semantic styling. Speaker notes and a general selector/query
language remain outside the current core.

## Source organization

`mosaic/lib.typ` is the public facade installed as `@local/mosaic:0.0.1`.
Internal modules import definitions directly from the module that owns them:

- `grid-model.typ` owns canonical cell/split records, validation, traversal,
  and constructor implementations; `grid-api.typ` exposes the public
  `mosaic.grid` namespace.
- `component-api.typ` curates the public component namespace without exposing
  implementation imports and helpers.
- `layout-core.typ` and `layout-support.typ` provide shared layout
  primitives. Each `layout-{name}.typ` module owns that layout's
  constructor, validation, and resolution; `layout-api.typ` and
  `layout-resolver.typ` are the curated public and runtime entry points.
- `deck-state.typ` and `deck-commands.typ` define deck-wide state and records.
  `slide-runtime.typ` owns handout/frame state and renders logical slides;
  `deck-compiler.typ` compiles top-level document content.
- `incremental-core.typ` provides shared range/state parsing.
  `incremental.typ` owns the incremental constructors, step discovery, and content
  transformation; `render.typ` renders one resolved grid-tree frame.
- `themes/*.typ` are the bundled themes; `theme-api.typ` curates the public
  `mosaic.themes` namespace.

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the complete dependency layers,
module responsibilities, and rules for placing new code.

## Development

List the available build commands and compile the tests and documentation:

```sh
make
make install
make check
make build
make website
make docs
```

`make install` copies `mosaic/` into Typst's local package index. `make check`
and `make website` run that installation first so their
`@local/mosaic:0.0.1` imports always use the current package sources.

`make check` compiles every positive test deck and verifies that each fixture in
`tests/invalid/` fails with a Mosaic diagnostic. `make build` includes this full
check before completing the tutorial slides and website.

`make website` compiles every focused deck in
`docs/tutorial-examples/` to a multipage SVG pattern under
`docs/assets/tutorials/` and then
builds the Calepin website in `docs/`. It also uses
[`tidy`](https://typst.app/universe/package/tidy/) to generate the HTML API
reference under `docs/api/` from the public modules' `///` comments. The
tutorial pages read those same
`.typ` files into syntax-highlighted verbatim blocks, so the displayed source
cannot drift from the rendered slideshow. Each tutorial shows one launcher
thumbnail; selecting it opens every SVG frame in Calepin's lightbox.

`make web-images` uses
[`rimage`](https://github.com/vlad-salone/rimage) to regenerate compact WebP
derivatives for the website. The full-resolution PNG and JPEG sources remain
in the repository.

Individual test decks can also be compiled directly:

```sh
# From the repository root:
typst compile --root . tests/test.typ
typst compile --root . tests/incremental.typ
typst compile --root . tests/numbering.typ
typst compile --root . tests/sections.typ
typst compile --root . tests/heading-offset.typ
```

The negative fixtures under `tests/invalid/` verify clear diagnostics for
malformed grids and layout records, invalid selectors, tracks, timing ranges,
cell operations, heading placement, and conflicting slide arguments.
