#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example


#set document(title: [Appearance])
#metadata((title: "Appearance")) <website-metadata>

#title()

A slide is a stack of native Typst layers: a background plane, a grid of cells,
and a foreground plane. The planes are content you supply directly; each cell is
a single block labeled `<mosaic-cell-ID>`. You style all of it with ordinary
`set` and `show` rules. `m.setup` establishes the baseline (font, page and text
defaults, canonical deck metadata, semantic colors, and the canonical cell
vocabulary), and every rule you add layers on top. Cell structure and local
styling remain ordinary Typst rather than going through a theme object or
separate styling DSL.

= Styling cells

Target a cell by its label. Font, size, color, and alignment are `set text`,
`set par`, and `set align`; the cell's own fill, stroke, and corner radius go
through `m.surface`:

```typ
#show label("mosaic-cell-copy"): set align(left + horizon)
#show label("mosaic-cell-copy"): set text(fill: black, size: 1.1em)
#show label("mosaic-cell-copy"): m.surface(fill: white)

#let columns = m.grid.h("copy", "image")
#m.slide(layout: columns, content: (
  copy: [Copy],
  image: [Image],
))
```

== Content rules and surface rules

Two kinds of rules cover a cell, split by what they touch. Properties of the
content *inside* the cell (text, alignment, paragraphs, lists) pass through
the label as ordinary `set` rules. Properties of the cell's *own block* (fill,
stroke, corner radius) cannot, because that block is constructed before any
rule applies; the only way to paint it is to wrap the labeled block in a new
block that carries the paint. `m.surface(..)` builds exactly that wrapper, so
it is shorthand for the native transform, not a separate styling system:

```typ
#show label("mosaic-cell-copy"): m.surface(fill: white)
// is the same rule as
#show label("mosaic-cell-copy"): it => block(
  width: 100%,
  height: 100%,
  fill: white,
  it,
)
```

A full-height cell (`1fr` or a fixed track) fills its region with the default
`height: 100%`; for a content-sized cell (an `auto` track) pass
`height: auto` so the fill hugs the content. The full-slide planes carry the
labels `<mosaic-cell-background>` and `<mosaic-cell-foreground>`, so the same
two kinds of rules style them as well. The one structural knob that lives
on the cell itself is `inset`, because padding affects layout measurement:

```typ
#m.grid.cell("image", inset: 0pt)
```

Rules after `#show: m.setup` override the baseline deck-wide. Scope a rule and
slide inside a block to change only that slide:

```typ
#[
  #show label("mosaic-cell-body"): set align(center + horizon)
  #m.slide[Centered for this slide only]
]
```

== Reusable looks

Bundle repeated cell rules in a transformer and apply it once with `#show:`:

```typ
#let styled(body) = {
  show label("mosaic-cell-b"): it => block(
    width: 100%,
    height: 100%,
    fill: blue,
    it,
  )
  body
}

#show: styled
#m.slide(layout: m.grid.h("a", "b"))[Left][Right]
```

#embedded-example(
  calepin.elements.gallery,
  "appearance/reusable-look",
  frames: 2,
  title: "One grid and one set of reusable cell rules shared by two slides",
)

A #link("appearance.html#themes")[theme] packages this pattern at deck scale.

= Deck identity

Declare document-wide title information once in `m.setup`. The values feed
Mosaic's deferred title layouts, standard Typst document metadata, and the
queryable `<mosaic-deck-metadata>` record:

```typ
#let authors = (m.layouts.author(
  "Ada Lovelace",
  affiliations: ((id: "lab", name: [Systems Lab]),),
),)

#show: m.setup.with(
  title: [Reliable systems],
  subtitle: [One source of truth],
  authors: authors,
  date: [2026],
)

#m.slide(layout: "title")
```

`m.layouts.title()` inherits `title`, `subtitle`, `authors`, and `date` from
setup. An explicit layout argument wins; pass `none` (or `()` for `authors`) to
suppress an inherited optional field on one title slide:

```typ
#m.slide(layout: m.layouts.title(
  title: [Alternate cover],
  subtitle: none,
  authors: (),
  date: none,
))
```

Mosaic does not create a title slide automatically: setup declares deck
identity, while each `m.slide(layout: "title")` chooses where it
is shown. String author names are also written to Typst's standard `document.author`
field; rich-content names remain available in Mosaic's metadata and title
layout. Tooling can inspect the complete record with
`typst eval 'query(<mosaic-deck-metadata>).map(it => it.value)' --in document.typ`.

The same setup may declare partial cell-content defaults such as `footer`.
Unlike deck metadata, these are rendering fallbacks: they apply only when the
resolved layout contains that cell ID, and explicit slide content or `none`
overrides them. See #link("structure.html#content")[the content layout].

#embedded-example(
  calepin.elements.gallery,
  "appearance/setup-deck",
  frames: 2,
  title: "Setup metadata, semantic colors, and inherited footer content",
)

= Typography

Place native Typst text and heading rules after `m.setup` so they apply across
the deck:

```typ
#show: m.setup
#set text(font: "EB Garamond", size: 26pt)
#show heading.where(depth: 1): set text(font: "Inter", weight: "black")
#show heading.where(depth: 2): set text(size: 1.4em)
```

A semantic heading feeds outlines, bookmarks, and heading slides. Use `text`
directly for display type that should not appear in
navigation, or exclude the heading:

```typ
#text(size: 60pt, weight: "black")[BOLD]
#heading(outlined: false, bookmarked: false)[Aside]
```

Leading, lists, and captions remain native `par`, `list`, `enum`, `terms`, and
`figure.caption` styling.

A heading cannot be placed inside an incremental grid node (`m.grid.on`,
`m.steps.reveal`, and related reducers); keep it structurally stable across a slide's
frames.

= Color

Each active facade supplies a complete semantic palette. Override only the
deck-wide roles that differ through `m.setup`; omitted roles retain the selected
theme's defaults:

```typ
#show: m.setup.with(colors: (
  canvas: rgb("#f4f8f7"),
  accent: rgb("#007f73"),
))
```

The accepted roles are `canvas`, `surface`, `text`, `muted`, `line`, and
`accent`. Unknown roles and non-color values are errors. Canvas, typography,
rules, runtime-aware components, and semantic layouts consume the resolved
values. Explicit component colors remain local overrides:

```typ
#m.slide(
  layout: m.layouts.content(variant: "header-body"),
  content: (foreground: [
    #place(bottom + left)[
      #m.components.progress(
        variant: "line",
        width: 100%,
        color: rgb("#e69f00"),
      )
    ]
  ]),
)[Title][Body]
```

Native rules after `m.setup` are still the right tool for typography or a
special local composition:

```typ
#[
  #show label("mosaic-cell-body"): set text(fill: white)
  #m.slide(
    content: (background: block(width: 100%, height: 100%, fill: rgb("#111827"))),
  )[Dark for this slide only]
]
```

Color collections remain ordinary Typst arrays. Define them near the chart or
diagram that uses them, or import a focused color package. Component `role:`
values remain local to components such as `frame`, `label`, and `quote`.

= Themes

Themes separate a deck's content from its visual system. Use a bundled theme
when its palette and typography fit the talk; develop a theme when the design
needs to become reusable.

== Using themes

Five themes ship inside the package under `m.themes`: `light`, `dark`,
`metropolis`, `cream`, and `minimalist`. Import one as the active Mosaic facade:

```typ
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.metropolis as m
#show: m.setup.with(
  title: [My talk],
  subtitle: [With a borrowed look],
)

#m.slide(layout: m.layouts.title())
== First slide
#m.slide(
  layout: m.layouts.section(),
  content: (section: [A new chapter]),
)
```

The imported facade supplies the complete Mosaic API, so the same `m.slide`,
`m.layouts`, `m.components`, notes, pauses, and incremental commands remain
available. Use `m.setup.with(...)` for deck metadata, partial semantic-color
overrides, inherited content, output modes, and options exposed by that theme.

The root facade is exactly the bundled light facade, not a similar-looking copy:

```typ
// Default spelling
#import "@local/mosaic:0.0.1" as m
```

```typ
// Explicit light spelling
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.light as m
```

Choose the dark facade for a complete technical-talk palette. It carries the
same public API while applying dark semantic colors to the canvas, layout
decoration, furniture, code, tables, links, and muted text:

```typ
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.dark as m
#show: m.setup
```

#embedded-example(
  calepin.elements.gallery,
  "appearance/dark-theme",
  frames: 3,
  title: "The bundled dark theme across title, technical content, and section slides",
)

== Developing themes

Start locally in one presentation file. Define the complete semantic palette,
add static text arguments or native rules only when needed, and bind the
dictionary directly:

```typ
#import "@local/mosaic:0.0.1" as m

#let theme = (
  colors: (
    canvas: white,
    surface: rgb("#f5f5f5"),
    text: rgb("#17243a"),
    muted: rgb("#52657f"),
    line: rgb("#aeb9c8"),
    accent: rgb("#a23b72"),
  ),
  text: (font: "Inter", size: 20pt),
)

#show: m.theme.setup(theme)
```

Only `colors` is required. `name`, `defaults`, `options`, `text`,
`normalize-lists`, `layouts`, and `apply` are optional. `text` may be a static
dictionary as above. Use `text: options => (...)` only when callers must be able
to override theme-specific typography options.

A reusable complete facade keeps three core files: `theme.typ` binds and exports
the public API, `definition.typ` contains passive design decisions, and
`layouts.typ` is the exact callable layout namespace. Add `tokens.typ`,
`components.typ`, or assets only when the design genuinely needs them. The
facade binds once with `mosaic.theme.setup(definition)`; no setup forwarding file
or layout implementation forwarding file is needed.

Mosaic continues to own setup validation, metadata, content inheritance, output
modes, overflow policy, counters, heading slides, and compilation. Definitions
never import setup internals or forward Mosaic's setup arguments.

The complete theme below demonstrates that reusable three-file structure.

#embedded-example(
  calepin.elements.gallery,
  "appearance/starter-theme",
  frames: 5,
  title: "The starter theme deck",
)

The starter's `definition` dictionary is the only theme-specific input to the
engine. Its six semantic color roles are `canvas`, `surface`, `text`, `muted`,
`line`, and `accent`. Static `text` values become native text arguments;
`text(options)` remains available for configurable theme options.
`apply(body, colors:, options:)` scopes unrestricted native rules around the
body. Complete `layouts.content`, `layouts.title`, and `layouts.section` values
define the named layouts used by explicit and automatic slides. Theme-specific defaults in `options` are consumed
by the engine before ordinary setup validation. Generic components using the
`neutral` or `accent` role resolve those roles contextually from the same theme
palette; a facade may still export a specialized component module for additional
role treatments.

For a packaged theme, copy Light's `definition.typ`, `layouts.typ`, and exact
facade, then change only design values and genuine layout deltas. Other built-ins
use the same engine rather than inheriting Light's palette or typography. The
Greyscale example follows the vendored-theme convention;
#link("api/theme.html")[Theme authoring API] documents the exact binding, and
#link("examples.html")[Examples] shows complete rendered decks.
