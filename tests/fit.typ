#import "../mosaic/src/fit.typ": fit-to-width, fit-to-height

#set page(width: 320pt, height: 220pt, margin: 10pt)
#set text(size: 24pt)

#block(
  width: 120pt,
  stroke: 0.5pt,
  fit-to-width(width: 1fr, grow: false)[MOSAIC-AUTOMATIC-SCALING],
)

#pagebreak()

#block(
  width: 180pt,
  height: 90pt,
  stroke: 0.5pt,
  fit-to-height(height: 1fr, width: auto, grow: false)[
    A longer text block scales geometrically to remain within a finite width
    and height.
  ],
)
