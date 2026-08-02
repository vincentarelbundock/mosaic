#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example


#set document(title: [Appearance])
#metadata((title: "Appearance")) <website-metadata>

#title()

A slide is a stack of native Typst layers: a background plane, a grid of cells,
and a foreground plane. The planes are content you supply directly; each cell is
a single block labeled `<mosaic-cell-ID>`. You style all of it with ordinary
`set` and `show` rules. `m.setup` establishes the baseline (font, page and text
defaults, and the canonical cell vocabulary), and every rule you add layers on
top. Styling does not go through a dictionary, theme object, or separate API.

= Styling cells

Target a cell by its label. Font, size, color, and alignment are `set text`,
`set par`, and `set align`; the cell's own fill, stroke, and corner radius go
through `m.surface`:

```typ
#show label("mosaic-cell-copy"): set align(left + horizon)
#show label("mosaic-cell-copy"): set text(fill: black, size: 1.1em)
#show label("mosaic-cell-copy"): m.surface(fill: white)

#let columns = m.grid.h("copy", "image")
#m.slide(grid: columns, content: (
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
#m.slide(m.grid.h("a", "b"))[Left][Right]
```

#embedded-example(
  calepin.elements.gallery,
  "appearance/reusable-look",
  frames: 2,
  title: "One grid and one set of reusable cell rules shared by two slides",
)

A #link("appearance.html#themes")[theme] packages this pattern at deck scale.

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

Set page and text color natively after `m.setup`:

```typ
#show: m.setup
#set page(fill: rgb("#111827"))
#set text(fill: rgb("#f3f4f6"))
```

Without these rules, Mosaic keeps its warm-white default. Built-in layouts that
draw decoration accept `accent:`, which colors only that layout's rule, spine,
section number, or progress indicator:

```typ
#let accent = rgb("#e69f00")

#m.slide(grid: m.layouts.title(
  title: [Research result],
  accent: accent,
))

#m.slide(grid: m.layouts.default(
  variant: "header-body",
  progress: "line",
  accent: accent,
))[Title][Body]
```

For one dark slide, scope a native text rule around a background override:

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

A theme is a complete Mosaic facade with specialized `setup` and `layouts`.
Its setup packages native page, text, and cell rules; its layout factories
return the same deferred recipes consumed by `m.slide`.

The complete theme below is designed to be copied as a starting point.

#embedded-example(
  calepin.elements.gallery,
  "appearance/starter-theme",
  frames: 5,
  title: "The starter theme deck",
)

Because `set` and `show` rules cannot cross an import, document-wide styling
lives inside the themed `setup`. It also registers `layouts.default()` for
`==` heading slides and `layouts.section()` for section slides.

Three themes ship inside the package under `m.themes`
(`metropolis`, `cream`, and `minimalist`). Import one as the active Mosaic facade:

```typ
#import "@local/mosaic:0.0.1" as mosaic
#import mosaic.themes.metropolis as m
#show: m.setup

#m.slide(grid: m.layouts.title(
  title: [My talk],
  subtitle: [With a borrowed look],
))
== First slide
#m.slide(
  grid: m.layouts.section(),
  content: (section: [A new chapter]),
  section: true,
  numbered: false,
)
```

Use `.with(...)` for the few exposed knobs. For deeper changes, copy the theme
from `mosaic/src/themes/` beside your deck and edit it directly. The Grayscale
example follows that convention; #link("examples.html")[Examples] shows the
complete rendered decks.
