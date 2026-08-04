#import "@preview/cetz:0.5.2"

// Colors double as theme tokens on the website: `docs/theme/css/mosaic.css`
// rewrites these exact values inside `.mosaic-diagram` frames, so labels and
// leader arrows follow the page text color and the surfaces adapt to dark
// mode. Keep the literals here in sync with that stylesheet.
#let ink = rgb("#1f2933")

#let diagram = {
  set text(fill: ink)
  cetz.canvas(length: 0.65cm, {
    import cetz.draw: content, line, rect

    let blue = rgb("#176b87")
    let pale-blue = rgb("#e8f1fb")
    let pale-gold = rgb("#fff4cf")
    let pale-green = rgb("#e5f5ee")
    let arrow = (end: "stealth", fill: ink, scale: 0.8)

    // Slide and its three cells.
    rect((0, 0), (12, 6.75), fill: white, stroke: 1.2pt + blue)
    rect((0, 4.5), (12, 6.75), fill: pale-blue, stroke: 0.8pt + blue)
    rect((0, 0), (7, 4.5), fill: pale-gold, stroke: 0.8pt + blue)
    rect((7, 0), (12, 4.5), fill: pale-green, stroke: 0.8pt + blue)

    // Dashed inset boundary inside cell 1.
    rect(
      (0.55, 0.55),
      (6.45, 3.95),
      stroke: (paint: blue, dash: "dashed", thickness: 0.7pt),
    )

    // Abstract content aligned to the content area's dotted edges.
    rect((0.55, 3.25), (1.35, 3.95), fill: blue, stroke: none)
    line(
      (1.65, 3.95),
      (6.45, 3.95),
      stroke: (paint: blue, thickness: 2pt),
    )
    line(
      (0.55, 2.7),
      (5.75, 2.7),
      stroke: (paint: blue, thickness: 1.4pt),
    )
    line(
      (0.55, 2.2),
      (6.45, 2.2),
      stroke: (paint: blue, thickness: 1.4pt),
    )
    line(
      (0.55, 1.7),
      (4.8, 1.7),
      stroke: (paint: blue, thickness: 1.4pt),
    )

    // The outer rectangle is the slide itself.
    content((6, 7.55), [*Slide*], anchor: "south")
    line((6, 7.45), (6, 6.85), stroke: ink, mark: arrow)

    // The boundary between two cells is a split.
    content((9.3, -0.75), [*Split*], anchor: "north")
    line((9.1, -0.5), (7, 0.9), stroke: ink, mark: arrow)

    // Cell annotations.
    content((13.5, 6.0), [*Cell 0*], anchor: "west")
    line((13.25, 5.9), (10.5, 5.55), stroke: ink, mark: arrow)

    content((-1.1, 3.65), [*Cell 1*], anchor: "east")
    line((-0.9, 3.55), (1.2, 3.1), stroke: ink, mark: arrow)

    content((13.5, 2.2), [*Cell 2*], anchor: "west")
    line((13.25, 2.1), (10.1, 2.0), stroke: ink, mark: arrow)

    content((3.5, -0.75), [*Inset*], anchor: "north")
    line((3.5, -0.5), (3.5, 0.27), stroke: ink, mark: arrow)
  })
}
