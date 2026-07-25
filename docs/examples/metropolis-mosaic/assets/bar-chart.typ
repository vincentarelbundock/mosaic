// Standalone source for bar-chart.svg, embedded on the "Bar charts" slide.
// Compile with: typst compile --font-path <fira> bar-chart.typ bar-chart.svg
//
// Each bar is placed individually against the axes baseline (left + bottom),
// so the three series share one common x-axis instead of stacking in flow.
#set page(width: auto, height: auto, margin: 2pt, fill: none)
#set text(font: "Fira Sans", fill: rgb("#23373b"))

#let axes(width: 494.50pt, height: 275.20pt, body) = box(width: width, height: height)[
  #place(left + bottom)[#line(length: height, angle: 90deg, stroke: 1.07pt + gray)]
  #place(left + bottom)[#line(length: width, stroke: 1.07pt + gray)]
  #body
]

#let blue = rgb("#4c9ad4")
#let yellow = rgb("#edc948")
#let teal = rgb("#76b7b2")

#let heights = (
  blue: (124.70pt, 156.95pt, 144.05pt, 40.85pt),
  yellow: (101.05pt, 144.05pt, 154.80pt, 60.20pt),
  teal: (60.20pt, 113.95pt, 165.55pt, 75.25pt),
)

#axes[
  #for i in range(4) {
    let base = 47.30pt + i * 103.20pt
    place(left + bottom, dx: base, rect(width: 17.20pt, height: heights.blue.at(i), fill: blue))
    place(left + bottom, dx: base + 19.35pt, rect(width: 17.20pt, height: heights.yellow.at(i), fill: yellow))
    place(left + bottom, dx: base + 38.70pt, rect(width: 17.20pt, height: heights.teal.at(i), fill: teal))
  }
  #place(top + right)[#text(size: 11.82pt)[
    ■ lorem #linebreak()
    #text(fill: yellow)[■] ipsum #linebreak()
    #text(fill: teal)[■] dolor
  ]]
]
