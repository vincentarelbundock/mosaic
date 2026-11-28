# Calmly example deck

A complete 19-frame deck. Assets, Makefile, and the compiled PDF are in the [repository](https://github.com/vincentarelbundock/mosaic/tree/main/docs-src/examples/decks/calmly).

## `main.typ`

````typ
// A Mosaic re-creation of the Calmly theme for Touying. preamble.typ holds the
// deck-local theme definition together with the two slide shapes Calmly has
// that Mosaic has no layout for. Calmly's box components are Mosaic callouts,
// so the deck calls those directly.
#import "preamble.typ": *
#show: setup.with(
  title: [Calmly],
  subtitle: [A Mosaic re-creation of a Touying theme],
  authors: (layouts.author(
    [Jane Musterfrau],
    affiliations: ([Department of Computer Science, University of Example],),
  ),),
  date: [February 2026],
)

// 01. Title
#slide(layout: "title")

// 02. Section
= Foundations

// 03. Text styling
== Text styling

Body copy sits a shade lighter than the ink so that #strong[bold text] and headings carry the emphasis on their own.

- #strong[Bold text] for emphasis
- #emph[Italic text] for subtle emphasis
- #text(fill: colors.accent, weight: "medium")[Alert text] highlights important terms
- #text(fill: colors.muted)[Muted text] for secondary information

// 04. Lists
== Lists and structure

Bullets take the secondary accent and numbers take the primary one:

- A first-level point
  - A second-level qualification
    - A third-level aside
- Another first-level point

+ Numbered items take the primary accent
+ And keep the same rhythm

// 05. Boxes
== Boxes

#components.callout(title: [Key Point])[
  The default `accent` role, for the one idea to carry out of the room.
]

#v(0.4em)

#components.callout(role: "warning", title: [Caution])[
  A qualification worth hearing first.
]

#v(0.4em)

#components.callout(role: "error", title: [Warning])[
  Critical information.
]

// 07. Section
= Layout

// 08. Two columns
// Named cells rather than positional blocks: the configured layout carries a
// footer, and the theme's progress chrome belongs there.
#slide(layout: "content", columns: 2, cells: (
  header: [== Two columns],
  body-1: [
    *Left*

    Each column is an ordinary body cell. Nothing here is a special layout.
  ],
  body-2: [
    *Right*

    The gap the theme sets is the gutter between them.
  ],
))

// 09. Figure
== Figures and captions

#align(center + horizon, components.figure(
  {
    let bars = ((2004, 38), (2009, 46), (2014, 61), (2019, 72), (2024, 88))
    grid(
      columns: bars.len(),
      column-gutter: 28pt,
      align: bottom,
      ..bars.map(((year, value)) => stack(
        dir: ttb,
        spacing: 10pt,
        rect(width: 44pt, height: value * 1.7pt, fill: colors.accent, radius: (top: 4pt)),
        text(size: 0.7em, fill: colors.muted)[#year],
      )),
    )
  },
  caption: [Adoption of the theme, entirely invented],
  kind: image,
))

// 10. Code
== Code

Blocks take the surface fill, a hairline border, and a soft radius:

```python
def calmly(variant="light", colortheme="tomorrow"):
    """Resolve a palette for the requested variant."""
    palette = PALETTES[colortheme][variant]
    return palette | {"progress": (palette.secondary, palette.primary)}
```

Inline code such as `variant: "dark"` keeps the ink color.

// 11. Mathematics
== Mathematics

#align(center)[
  #math.equation(
    block: true,
    alt: "alpha star equals the arg min over alpha in A of the validation loss at w star of alpha, alpha",
    $ alpha^* = arg min_(alpha in cal(A)) cal(L)_"val" (w^*(alpha), alpha) $,
  )
]

#v(0.4em)

#table(
  columns: (auto, 1fr),
  stroke: none,
  row-gutter: 0.45em,
  [#math.equation(alt: "alpha", $alpha$)], [An architecture drawn from the search space #math.equation(alt: "A", $cal(A)$)],
  [#math.equation(alt: "w star of alpha", $w^*(alpha)$)], [The weights that minimize training loss for #math.equation(alt: "alpha", $alpha$)],
  [#math.equation(alt: "validation loss", $cal(L)_"val"$)], [Validation loss, the outer objective],
)

// 12. Focus
#focus-slide[Methodology]

// 13. Section
= Evidence

// 14. Table
== Results

#align(center + horizon, table(
  columns: 4,
  align: (left, right, right, right),
  inset: (x: 0.7em, y: 0.45em),
  stroke: none,
  table.hline(stroke: 0.9pt + colors.muted),
  table.header([Method], [Error], [Params], [GPU hours]),
  table.hline(stroke: 0.5pt + colors.line),
  [Manual baseline], [3.46], [3.4M], [n/a],
  [Search, first order], [2.83], [3.3M], [96],
  [Ours], [*2.55*], [*2.9M*], [*9*],
  table.hline(stroke: 0.9pt + colors.muted),
))

// 15. Incremental reveal
== One point at a time

Mosaic adds frames until the last timed command has run:

- The estimate is positive across every specification.
#steps.pause
- The interval excludes zero in the pooled sample.
#steps.pause
- It does not in the two smallest subgroups.
#steps.pause

#components.callout(role: "error", title: [Caveat])[
  Power, not sign, is what the subgroups are short of.
]

// 16. Standout
#standout-slide[Thank you]

// 17. Contact
== Questions?

#v(0.4em)

#align(center)[
  #accent-rule

  #v(1.2em)

  jane\@example.edu

  #v(0.3em)

  #text(fill: colors.muted)[github.com/example/calmly-mosaic]
]
````

## `preamble.typ`

```typ
// Everything main.typ imports: the shared Mosaic API, a deck-local Mosaic
// theme, and the two slide shapes Calmly has that Mosaic has no layout for.
//
// The theme re-creates the look of the Calmly theme for
// Touying (https://github.com/YHan228/calmly-touying, MIT): a full-bleed blue
// header bar, a progress line and slide counter along the bottom edge, quiet
// grey body text, and olive bullets.
//
// This is a design, not a transcription. It states the palette and the few
// structural gestures that make Calmly recognizable, and leaves everything
// else to Mosaic's defaults.
#import "@preview/mosaic:0.0.2" as mosaic
#import mosaic: slide, note, fit, grids, layouts, steps, components

// Calmly's "tomorrow" palette, light variant. Six names are the deck's own
// chrome and two are the status colors components paint with.
#let colors = (
  canvas: rgb("#ffffff"),
  surface: rgb("#efefef"),
  text: rgb("#1d1f21"),
  muted: rgb("#8e908c"),
  line: rgb("#e0e0e0"),
  accent: rgb("#4271ae"),
  warning: rgb("#eab700"),
  error: rgb("#c82829"),
)

// Calmly's secondary accent, which is not one of Mosaic's semantic names: it
// marks bullets, opens the progress gradient, and tints the example callout.
#let olive = rgb("#718c00")

// The short rule under a section title, sweeping from one accent to the other.
#let accent-rule = box(
  width: 4em,
  height: 0.1em,
  radius: 0.05em,
  fill: gradient.linear(olive, colors.accent),
)

// The bottom edge chrome. It is the real `footer` cell rather than a
// foreground plane, so the layouts that carry no footer (title, section, and
// the focus and standout slides below) drop it without being told.
#let footer-chrome = grid(
  columns: (1fr, auto),
  column-gutter: 1.2em,
  align: horizon,
  mosaic.components.progress(
    variant: "line",
    count: "slides",
    width: 100%,
    thickness: 2pt,
    accent: colors.accent,
    fill: colors.line,
  ),
  mosaic.components.progress(variant: "1/1", accent: colors.muted),
)

// Calmly's section divider: the title over the short accent rule. The rule is
// a real grid row rather than content appended by a show rule, because the
// section cell fits its own content and anything appended would land outside
// the fitted region.
#let section-layout = mosaic.grids.rows(
  mosaic.grids.track(1fr, mosaic.grids.cell("section-space-above", content: [])),
  mosaic.grids.track(auto, "section"),
  mosaic.grids.track(auto, mosaic.grids.cell(
    "section-rule",
    content: align(center, accent-rule),
  )),
  mosaic.grids.track(1fr, mosaic.grids.cell("section-space-below", content: [])),
)

#let apply(body, colors: (:), options: (:)) = {
  // Body copy sits one step lighter than the ink, so headings and bold runs
  // carry the emphasis without a second color.
  set text(
    font: options.font,
    size: options.base-size,
    fill: colors.text.lighten(20%),
    fallback: true,
  )
  set list(marker: text(fill: olive)[•])
  set enum(numbering: n => text(fill: colors.accent, weight: "medium")[#n.])
  set table(stroke: 0.6pt + colors.line)
  show link: set text(fill: colors.accent)
  show figure.caption: set text(size: 0.72em, fill: colors.muted, style: "italic")

  // Stated absolutely: the level-1 heading scale and the section cell's scale
  // are both em multipliers, so an em size here would compound and a
  // `= Heading` section would outgrow an explicit section slide.
  let section-size = options.base-size * 1.75
  show heading: set text(fill: colors.text, weight: "semibold")
  show heading.where(depth: 1): set text(size: section-size)
  show heading.where(depth: 2): set text(size: 1.45em)

  show raw: set text(font: options.font-mono)
  show raw.where(block: true): set text(size: 0.7em)
  show raw.where(block: true): block.with(
    width: 100%,
    fill: colors.surface,
    stroke: 0.5pt + colors.line,
    radius: 8pt,
    inset: 0.9em,
  )

  // The signature header: a full-bleed bar in the accent color with the slide
  // title knocked out of it. The cell inset lives inside the label, so this
  // wrapper paints edge to edge and the heading keeps its padding. The heading
  // rule above sets its own fill, and a `set` rule beats the surrounding text
  // fill, so the bar restates the knockout color for headings too.
  show label("mosaic-cell-header"): it => block(
    width: 100%,
    fill: colors.accent,
    {
      show heading: set text(fill: colors.canvas)
      text(fill: colors.canvas, it)
    },
  )

  show label("mosaic-title-display"): set text(size: 1.85em, weight: "semibold")
  show label("mosaic-cell-title"): set text(fill: colors.text)
  show label("mosaic-cell-footer"): set text(size: 0.6em, fill: colors.muted)
  show label("mosaic-cell-section"): set align(center)
  show label("mosaic-cell-section"): set text(size: section-size, weight: "semibold", fill: colors.text)

  body
}

#let definition = (
  name: "Calmly",
  colors: colors,
  defaults: (
    cells: (footer: footer-chrome),
    // The deck gap is the title stack's vertical rhythm: the `ruled` variant
    // states its gaps as multiples of it, and Calmly's title page is airy.
    spacing: (gap: 1.6em),
  ),
  options: (
    font: ("Source Sans 3", "Inter", "Liberation Sans", "DejaVu Sans"),
    font-mono: ("JetBrains Mono", "DejaVu Sans Mono"),
    base-size: 20pt,
  ),
  layouts: (
    content: mosaic.layouts.content(variant: "header-body-footer"),
    // Calmly rules its title page with a neutral hairline rather than the
    // accent, which the `accent:` field states without a new variant.
    title: mosaic.layouts.title(variant: "ruled", accent: rgb("#c8c8c8")),
    section: section-layout,
  ),
  apply: apply,
)

#let setup = mosaic.themes.setup(definition)

// Calmly's focus slide: the accent gradient edge to edge, one line of display
// type knocked out of it. An ordinary body-only slide with a painted
// background plane.
#let focus-slide(body) = {
  show label("mosaic-cell-body"): set align(center + horizon)
  show label("mosaic-cell-body"): set text(fill: white, size: 2.2em, weight: "medium")
  slide(
    layout: layouts.content(variant: "body"),
    background: rect(
      width: 100%,
      height: 100%,
      fill: gradient.linear(angle: 135deg, olive, colors.accent, colors.accent.darken(25%)),
    ),
  )[#body]
}

// Calmly's standout slide: the same shape at maximum contrast. `invert: true`
// swaps canvas and text for one slide, and the body states the accent tint
// Calmly puts on the type.
#let standout-slide(body) = {
  show label("mosaic-cell-body"): set align(center + horizon)
  show label("mosaic-cell-body"): set text(fill: rgb("#81a2be"), size: 2.2em, weight: "semibold")
  slide(layout: layouts.content(variant: "body"), invert: true)[#body]
}
```
