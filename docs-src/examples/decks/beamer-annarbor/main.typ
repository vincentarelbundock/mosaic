// A Mosaic re-creation of Beamer's built-in AnnArbor theme. preamble.typ holds
// the deck-local theme definition and the imports. The deck
// follows the frame order of the tutorial deck the beamer theme galleries
// compile: title, outline, lists, blocks, and so on.
#import "preamble.typ": *

#show: setup.with(
  title: [Beamer Inbuilt Themes (AnnArbor)],
  subtitle: [A Mosaic re-creation of the wolverine palette],
  authors: (layouts.author(
    [Jane Musterfrau],
    affiliations: ([Department of Computer Science, University of Example],),
  ),),
  date: [February 2026],
)

// 01. Title
#slide(layout: "title")

// 02. Outline. Beamer's `\tableofcontents` frame is native Typst here: the
// heading keeps itself out of the outline it prints, and the entry rule drops
// the page numbers a deck has no use for. The entry stays a link to its
// section: a tagged PDF export requires each outline entry to reference its
// target, which plain text of the section title would not.
#slide(cells: (
  header: heading(level: 2, outlined: false)[Outline],
  body: {
    show outline.entry: entry => block(
      above: 0.8em,
      link(
        entry.element.location(),
        text(fill: structure, weight: "bold", entry.body()),
      ),
    )
    outline(title: none, depth: 1)
  },
))

// 03. Section
= Lists and text

// 04. Lists
== Lists in Beamer

This is an unordered list:

- Item 1
- Item 2
  - A nested qualification
- Item 3

and this is an ordered list:

+ Item 1
+ Item 2
+ Item 3

// 05. Text
== Text formatting

Body copy is set in black and the structure color carries everything else: headings, markers, and the banding at both edges.

- *Bold text* takes the structure blue
- _Italic text_ for a quieter emphasis
- #text(fill: alert)[Alerted text] marks the one term that matters
- #link("https://typst.app")[Links] and `inline code` share that same tone

// 06. Section
= Blocks

// 07. Blocks
== Blocks in Beamer

Beamer's three blocks are Mosaic callouts: one panel with a stripe and a bold title, picked by role.

#components.callout(title: [Standard Block])[
  This is a standard block. The `accent` role is the deck's own structure blue.
]

#v(0.4em)

#components.callout(role: "error", title: [Alert Message])[
  This block presents an alert message.
]

#v(0.4em)

// The panel fill is stated with the accent: `callout` tints its panel from the
// role, and the example green is not one of the palette's roles.
#components.callout(
  accent: example,
  fill: example.lighten(85%),
  title: [An example of a typesetting tool],
)[
  Example: MS Word, LaTeX, Typst.
]

// 08. Two columns
// The theme's content layout is the built-in variant, so `columns:` splits the
// body the way beamer's `\begin{columns}` splits a frame.
#slide(layout: "content", columns: 2, cells: (
  header: [== Two columns],
  body-1: components.callout(title: [Left])[
    Each column is an ordinary body cell.
  ],
  body-2: components.callout(title: [Right])[
    The frametitle bar and the banding come from the theme, not from the slide.
  ],
))

// 09. Section
= Layout and evidence

// 10. Figure
== Figures and captions

#align(center + horizon, components.figure(
  {
    let bars = ((2004, 38), (2009, 46), (2014, 61), (2019, 72), (2024, 88))
    grid(
      columns: bars.len(),
      column-gutter: 26pt,
      align: bottom,
      ..bars.map(((year, value)) => stack(
        dir: ttb,
        spacing: 9pt,
        rect(width: 40pt, height: value * 1.4pt, fill: structure, radius: (top: 3pt)),
        text(size: 0.65em, fill: colors.muted)[#year],
      )),
    )
  },
  caption: [Adoption of the theme, entirely invented],
  kind: image,
))

// 11. Table
== Results

#align(center + horizon, table(
  columns: 4,
  align: (left, right, right, right),
  inset: (x: 0.7em, y: 0.4em),
  stroke: none,
  table.hline(stroke: 0.9pt + structure),
  table.header([Method], [Error], [Params], [GPU hours]),
  table.hline(stroke: 0.5pt + colors.line),
  [Manual baseline], [3.46], [3.4M], [n/a],
  [Search, first order], [2.83], [3.3M], [96],
  [Ours], [*2.55*], [*2.9M*], [*9*],
  table.hline(stroke: 0.9pt + structure),
))

// 12. Code
== Code

Blocks take the pale maize surface, a hairline border, and a soft radius:

```python
def annarbor(base="Boadilla", colors="wolverine"):
    """Resolve the palette beamer's AnnArbor theme inherits."""
    palette = COLOR_THEMES[colors]
    return palette | {"inner": "rounded", "outer": "infolines"}
```

// 13. Mathematics
== Mathematics

#align(center)[
  #math.equation(
    block: true,
    alt: "beta hat equals the inverse of X transpose X, times X transpose y",
    $ hat(beta) = (X^top X)^(-1) X^top y $,
  )
]

#v(0.5em)

#table(
  columns: (auto, 1fr),
  stroke: none,
  row-gutter: 0.4em,
  [#math.equation(alt: "X", $X$)], [The design matrix, one row per observation],
  [#math.equation(alt: "y", $y$)], [The outcome vector],
  [#math.equation(alt: "beta hat", $hat(beta)$)], [The least-squares coefficients],
)

// 14. Incremental reveal
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

// 15. Closing
== Questions?

#v(1em)

#align(center)[
  #text(size: 1.1em, fill: structure, weight: "bold")[Thank you]

  #v(1em)

  jane\@example.edu
]
