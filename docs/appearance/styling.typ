#import "/.calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example, thumbnail-gallery

#set document(title: [Styling cells])
#metadata((title: "Styling cells")) <website-metadata>

#title()

A slide is a stack of native Typst layers: a background plane, a grid of cells, and a foreground plane. The planes are content you supply directly; each cell is a single block labeled `<mosaic-cell-ID>`. You style all of it with ordinary `set` and `show` rules. Every rule a slide renders with comes from its theme: Mosaic's engine contributes page geometry, deck information, and colors, but no slide typography of its own. Rules you write after `m.setup` layer on top of the theme's. There is no separate styling system to learn.

Behind that, the engine keeps exactly one record of its own: the deck record, written once by `m.setup` and never changed afterward. It holds what you declare there, structure and geometry, plus the semantic colors and roles. Those colors are the one deliberate exception to "everything is a rule": components are functions, and no native rule can carry a surface fill or an accent color into a function call the way `set text` carries typography into text. Declaring six colors and a role palette at setup is the whole extent of it.

= Styling cells

Target a cell by its label. Font, size, color, and alignment are `set text`, `set par`, and `set align`; the cell's own fill, stroke, and corner radius go through `m.surface`:

```typ
#show label("mosaic-cell-copy"): set align(left + horizon)
#show label("mosaic-cell-copy"): set text(fill: black, size: 1.1em)
#show label("mosaic-cell-copy"): m.surface(fill: white)

#let columns = m.grids.h("copy", "image")
#m.slide(layout: columns, content: (
  copy: [Copy],
  image: [Image],
))
```

#embedded-example(
  calepin.elements.gallery,
  "structure/content-layout-inverted",
  frames: 1,
  title: "A content slide with styled header and footer cells",
  renderer: thumbnail-gallery,
)

= Content rules and surface rules

Two kinds of rules cover a cell, split by what they touch. Properties of the content *inside* the cell (text, alignment, paragraphs, lists) pass through the label as ordinary `set` rules. Properties of the cell's *own block* (fill, stroke, corner radius) cannot, because that block is constructed before any rule applies; the only way to paint it is to wrap the labeled block in a new block that carries the paint. `m.surface(..)` builds exactly that wrapper, so it is shorthand for the native transform, not a separate styling system:

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

A full-height cell (`1fr` or a fixed track) fills its space with the default `height: 100%`; for a content-sized cell (an `auto` track) pass `height: auto` so the fill hugs the content. The full-slide planes carry the labels `<mosaic-background>` and `<mosaic-foreground>`, so the same two kinds of rules style them as well. The one structural setting that lives on the cell itself is `inset`, because padding affects layout measurement:

```typ
#m.grids.cell("image", inset: 0pt)
```

Rules after `#show: m.setup` override the baseline deck-wide. Scope a rule and slide inside a block to change only that slide:

```typ
#[
  #show label("mosaic-cell-body"): set align(center + horizon)
  #m.slide[Centered for this slide only]
]
```

The same scoped block builds one-off slides. To show one large number or phrase on an otherwise empty slide, center the body cell and set the text size:

```typ
#[
  #show label("mosaic-cell-body"): set align(center + horizon)
  #m.slide(content: (body: text(size: 6em, weight: "bold")[15 000 000]))
]
```

For a slide that shows a picture on a black background, paint the background plane through its label and center the image in the `background` entry:

```typ
#[
  #show label("mosaic-background"): m.surface(fill: black)
  #m.slide(
    content: (
      background: align(center + horizon, image("fig/logo.png", height: 100%, fit: "contain")),
      body: [],
    ),
  )
]
```

= Styling a whole slide

The grid of every slide also carries the label `<mosaic-slide>`, so one rule
reaches every cell of a slide at once. Use it when the whole slide changes
together. Light text over a photograph is the common case:

```typ
#[
  #show label("mosaic-slide"): set text(fill: white)
  #m.slide(
    layout: "image",
    variant: "left",
    image: (path: path("cover.webp"), scrim: black.transparentize(40%)),
  )[== Header][Both cells are white from one rule]
]
```

Naming each cell instead works, but ties the rule to the cells the layout
happens to produce: change the variant and a cell can silently keep the deck's
ordinary color. `<mosaic-slide>` sits outside the per-cell labels, so a
`<mosaic-cell-*>` rule still refines it: set the slide's color once, then
override one cell.

= Type and geometry in designed layouts

The `title` and `section` layouts are compositions, not bare grids: each variant interleaves text tiers with explicit spacers, rules, and offsets. Restyling one splits along that seam.

Typography goes through labels, exactly as a cell does. Every tier a variant emits carries its own label, so a rule reaches it without knowing anything about the layout:

```typ
#show label("mosaic-section-number"): set text(weight: "black")
#show label("mosaic-section-subtitle"): set text(style: "italic")
#show label("mosaic-title-display"): set text(tracking: -0.02em)
```

Geometry does not. The `v(0.24em)` between a rule and a title, or the `dy: -1.15em` that bleeds an oversized numeral off the top edge, is produced while the layout composes itself, and no show rule can reach inside it. Those measurements are the variant's design, and they are deliberately not parameters: a variant earns its place by being a finished composition. When the arrangement itself is wrong for your content, pick another variant, or draw the slide you want as an ordinary grid of cells and style it with label rules. A size, weight, or color is always a label rule.

= Reusable looks

Bundle repeated cell rules in a function and apply it once with `#show:`:

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
#m.slide(layout: m.grids.h("a", "b"))[Left][Right]
```

#embedded-example(
  calepin.elements.gallery,
  "appearance/reusable-look",
  frames: 2,
  title: "One grid and one set of reusable cell rules shared by two slides",
)

#embedded-example(
  calepin.elements.gallery,
  "structure/content-layout-custom",
  frames: 2,
  title: "A reusable look applied to two content slides",
  renderer: thumbnail-gallery,
)

A #link("themes.html")[theme] packages this pattern for a whole deck.
