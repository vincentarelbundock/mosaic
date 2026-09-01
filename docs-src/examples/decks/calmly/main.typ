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
