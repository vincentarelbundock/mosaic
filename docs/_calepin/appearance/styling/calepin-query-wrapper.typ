#let _calepin-document-element = document
#import "/_calepin/calepin.typ": *
#let document = _calepin-document-element



#let _raw-chunk-langs = ("python", "r", "mermaid", "dot", "tikz", "d2")
#show raw.where(block: true, lang: "typ", theme: auto): it => _without-raw-chunk-transforms(() => _html-themed-raw-block(it))
#show raw.where(block: true, lang: "typst", theme: auto): it => _without-raw-chunk-transforms(() => _html-themed-raw-block(it))
#show raw.where(block: true, lang: "python", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("python", it) }
#show raw.where(block: true, lang: "r", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("r", it) }
#show raw.where(block: true, lang: "mermaid", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("mermaid", it) }
#show raw.where(block: true, lang: "dot", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("dot", it) }
#show raw.where(block: true, lang: "tikz", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("tikz", it) }
#show raw.where(block: true, lang: "d2", theme: auto): it => if _disable-raw-chunk-transforms.get() { _html-themed-raw-block(it) } else { chunk_from_raw_plain("d2", it) }

#show raw.where(block: true, theme: auto): it => {
  if _is-query() {
    it
  } else if _disable-raw-chunk-transforms.get() {
    _html-themed-raw-block(it)
  } else if it.has("lang") and it.lang != none and _raw-chunk-langs.contains(it.lang) and _fenced-chunks-runs(
    it.lang,
    _resolve-options(it.lang, _call-defaults).at("fenced-chunks"),
  ) {
    chunk_from_raw_plain(it.lang, it)
  } else {
    _html-themed-raw-block(it)
  }
}

#show heading: it => {
  if _is-html() and "label" in it.fields() {
    std.html.elem("calepin-heading-anchor", attrs: (data-id: str(it.label)))
  }
  it
}

// Notebook theme
#import "/_calepin/calepin.typ": _html-themed-raw-block, _is-query, chunk_from_raw_plain

// Body text size, captured below at document-body level. Code blocks are sized
// relative to this rather than to `1em`, which would compound: a literal
// ```typ block is rendered by replacing its source `raw` element, so it renders
// inside Typst's already-reduced raw text context, whereas executed chunks are
// emitted as ordinary calls at body size. Anchoring to the captured body size
// gives both paths a single, matching reduction instead of shrinking twice.
#let _calepin-body-size = std.state("calepin-body-size", 11pt)

#show raw.where(block: true): it => {
  if it.theme != auto {
    context {
      set text(size: _calepin-body-size.get() * 0.8)
      it
    }
  } else if it.lang != none and (_is-query() or _raw-chunk-langs.contains(it.lang)) and _fenced-chunks-runs(
    it.lang,
    _resolve-options(it.lang, _call-defaults).at("fenced-chunks"),
  ) {
    chunk_from_raw_plain(it.lang, it)
  } else {
    _html-themed-raw-block(it)
  }
}

#context _calepin-body-size.update(text.size)

#import "/_calepin/calepin.typ" as calepin
#import "/_includes/embedded-examples.typ": embedded-example, thumbnail-gallery

#set document(title: [Styling cells])
#metadata((title: "Styling cells")) <website-metadata>

#title()

As the #link("../reference/concepts.html#anatomy-of-a-slide-deck")[anatomy page] shows, every part of a slide is a native Typst layer carrying a label, and you style all of it with ordinary `set` and `show` rules. Every rule a slide renders with comes from its theme: Mosaic's engine contributes page geometry, deck information, and colors, but no slide typography of its own. Rules you write after `m.setup` layer on top of the theme's. There is no separate styling system to learn.

Behind that, the engine keeps exactly one record of its own: the deck record, written once by `m.setup` and never changed afterward. It holds what you declare there, structure and geometry, plus the semantic colors and roles. Those colors are the one deliberate exception to "everything is a rule": components are functions, and no native rule can carry a surface fill or an accent color into a function call the way `set text` carries typography into text. Declaring six colors and a role palette at setup is the whole extent of it.

= Deck typography

Place native Typst text and heading rules after `m.setup` so they apply across the deck:

```typ
#show: m.setup
#set text(font: "EB Garamond", size: 26pt)
#show heading.where(depth: 1): set text(font: "Inter", weight: "black")
#show heading.where(depth: 2): set text(size: 1.4em)
```

A semantic heading feeds outlines, bookmarks, and content slides. Use `text` directly for display type that should not appear in navigation, or exclude the heading:

```typ
#text(size: 60pt, weight: "black")[BOLD]
#heading(outlined: false, bookmarked: false)[Aside]
```

Leading, lists, and captions remain native `par`, `list`, `enum`, `terms`, and `figure.caption` styling.

A heading cannot be placed inside an incremental grid node (`m.grids.on`, `m.steps.reveal`, and related step commands); keep it structurally stable across a slide's frames.

Everything about the deck's palette, overriding entries, the bundled palette collection, and inverting a slide, lives on the #link("colors.html")[Colors] page.

= Styling cells

Target a cell by its label. Font, size, color, and alignment are `set text`, `set par`, and `set align`; the cell's own fill, stroke, and corner radius go through `m.surface`. The #link("../api/labels.html")[label reference] lists every label a slide emits:

```typ
#let ink = rgb("#20262d")

#show label("mosaic-cell-header"): set text(fill: white)
#show label("mosaic-cell-header"): m.surface(fill: ink, height: auto)
#show label("mosaic-cell-footer"): set text(fill: white)
#show label("mosaic-cell-footer"): m.surface(fill: ink, height: auto)

#m.slide(layout: m.layouts.content())[
  == Inverted header and footer
][
  #lorem(36)
][
  Both regions share one pair of ordinary Typst color bindings.
]
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
#show label("mosaic-cell-body"): m.surface(fill: white)
// is the same rule as
#show label("mosaic-cell-body"): it => block(
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
  #m.slide(cells: (body: text(size: 6em, weight: "bold")[15 000 000]))
]
```

For a slide that shows a picture on a black background, paint the background plane through its label and center the image in the `background` entry:

```typ
#[
  #show label("mosaic-background"): m.surface(fill: black)
  #m.slide(
    cells: (
      body: [],
    ),
    background: align(center + horizon, image("fig/logo.png", height: 100%, fit: "contain")),
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
#m.slide(layout: m.grids.columns("a", "b"))[Left][Right]
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

A #link("themes.html")[theme] packages this pattern for a whole deck, and writing one is how a look becomes reusable across decks.

= Inverting cells by hand

`slide(invert: true)`, described under #link("colors.html#inverting-one-slide")[Inverting one slide], swaps a whole slide's ground and ink within the palette. When you want finer control, invert selected cells with the same label rules as above. Pair each ground with the text color that reads against it, and apply both halves in the same rule: `m.surface` fills the cell's own block and a neighboring `set text` colors the content inside it, so a helper that takes a `(fill, text)` pair can repaint any set of cells:

#embedded-example(
  calepin.elements.gallery,
  "faq/color-inversion",
  frames: 2,
  title: "One layout rendered on a light ground and on a dark one",
  renderer: thumbnail-gallery,
)

The same helper inverts a single slide, a run of slides, or a whole deck, depending on where you place the `#show:` rule. Scope it inside a block for one slide, or write it once after `m.setup` to change the baseline. To invert the full bleed rather than the cells, add `#set page(fill: ..)`; the background and foreground planes take the same rules through the `<mosaic-background>` and `<mosaic-foreground>` labels.

Mosaic does not derive the text color from the fill. Two reasons, both practical. Mid-tone grounds sit where an automatic flip is least reliable: a muted sage such as `rgb("#aebdb3")` reads as "light" to a luminance rule, but white on it measures 1.8:1, well under the 4.5:1 that body text wants. And a cell's declared fill is often not what the viewer sees behind the text, because an image, scrim, or background plane covers it. Naming the pair keeps that judgment with the author, where a real slide can be looked at.
