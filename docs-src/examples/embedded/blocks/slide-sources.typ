#import "@preview/mosaic:0.0.1" as m

// A body cell over an auto-height strip that holds the notes for this slide.
#let cited = m.grids.rows(
  m.grids.cell("body", inset: (x: 1.5em, top: 1.5em, bottom: 0.5em)),
  m.grids.track(auto, m.grids.cell("sources", inset: (x: 1.5em, bottom: 1em))),
)

#show: m.setup
#set text(size: 18pt)

// Numbered like footnote markers, but laid out by the grid, so the entries
// stay on the slide that references them.
#let marker(number) = super(str(number))
#let source(number, body) = block(below: 0.4em)[#marker(number) #body]

#m.slide(layout: cited)[
  == Sources stay on the slide

  Position judgments are more accurate than area judgments.#marker(1)

  Panels that share one scale invite comparison.#marker(2)
][
  #set text(size: 0.6em, fill: luma(35%))
  #source(1)[Cleveland, _Visualizing Data_, 1993.]
  #source(2)[Tufte, _Envisioning Information_, 1990.]
]
