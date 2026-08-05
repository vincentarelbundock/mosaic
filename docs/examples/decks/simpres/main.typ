// A Mosaic re-creation of the Simpres theme for Touying. preamble.typ holds the
// deck-local theme definition; the deck itself is ordinary Mosaic.
#import "preamble.typ": *
#show: setup.with(
  title: [The "Simpres" slide template],
  subtitle: [Presentation Template for Education and Business],
  authors: (layouts.author([thy0s], affiliations: ([Funk Town State University],)),),
  date: [2026-02-05],
)

// 01. Title
#slide(layout: "title")

// 02. Outline. The heading is unnumbered and kept out of the outline it
// prints; everything else on the slide is native Typst.
#slide(cells: (
  header: heading(level: 2, outlined: false, bookmarked: false)[Outline],
  body: outline(title: none, indent: auto, depth: 2),
))

// 03. Section
= Example Slides

// 04. Bullets
== Bullet Points

- Networks are a collection of interconnected, autonomous computing devices #cite(<tanenbaum2021>)

- *Also pay attention to this bold text!*

  - _This here is also important..._

// 05. Figure
== A CeTZ Figure

#figure(
  cetz.canvas(length: 1.4cm, {
    import cetz.draw: *
    let nodes = (
      ("n0", (0, 0), "0", black, white),
      ("n1", (-2.6, -2), "1", none, luma(20%)),
      ("n2", (2.6, -2), "1", none, luma(20%)),
      ("n3", (0.6, -4), "2", none, luma(20%)),
      ("n4", (3.6, -4), "2", none, luma(20%)),
      ("n5", (-3.4, -4), "2", none, luma(20%)),
    )
    for (name, pos, body, fill, ink) in nodes {
      circle(pos, radius: 0.6, fill: fill, name: name)
      content(pos, text(size: 10pt, fill: ink, body))
    }
    let edge = line.with(
      stroke: (paint: black, thickness: 2pt),
      mark: (end: "triangle", length: 0.2),
    )
    edge("n1", "n0")
    edge("n2", "n0")
    edge("n3", "n1")
    edge("n4", "n2")
    edge("n5", "n1")
  }),
  caption: [A fully built routing tree #cite(<winter2012>)],
)

// 06. Focus. Simpres's one bespoke shape: the whole canvas in the primary
// color with a line of display type over it. In Mosaic that is a body-only
// slide with a painted background plane, so it needs no layout of its own.
#[
  #show label("mosaic-cell-body"): set align(center + horizon)
  #show label("mosaic-cell-body"): set text(fill: colors.canvas, size: 2em)
  #slide(
    layout: layouts.content(variant: "body"),
    background: rect(width: 100%, height: 100%, fill: colors.accent),
  )[WATCH OUT]
]

// 07. Code
== Mixing it Up

- The section name above the slide title comes from the enclosing `=` heading

- The footer carries the deck's own date beside the slide counter

```typ
#show: setup.with(
  title: [The "Simpres" slide template],
  subtitle: [Presentation Template for Education and Business],
  authors: (layouts.author([thy0s], affiliations: ([Funk Town State University],)),),
  date: [2026-02-05],
)
```

// 08. References
= References

== Literature

#bibliography("references.bib", title: none, style: "ieee")
