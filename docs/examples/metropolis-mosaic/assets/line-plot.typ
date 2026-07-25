// Standalone source for line-plot.svg, embedded on the "Line plots" slide.
// Compile with: typst compile --font-path <fira> line-plot.typ line-plot.svg
//
// The curves rise ~82pt above the plot box, so the page is sized taller than
// the axes and the box is anchored to the bottom to keep the peaks in frame.
#set page(width: 499pt, height: 372pt, margin: 0pt, fill: none)

#let axes(width: 494.50pt, height: 275.20pt, body) = box(width: width, height: height)[
  #place(left + bottom)[#line(length: height, angle: 90deg, stroke: 1.07pt + gray)]
  #place(left + bottom)[#line(length: width, stroke: 1.07pt + gray)]
  #body
]

#place(bottom + left, dx: 2pt, dy: -2pt)[
#axes[
  #place(left + horizon, dx: 4.30pt)[
    #curve(
      stroke: 2.15pt + rgb("#4c9ad4"),
      curve.move((0.00pt, 107.50pt)), curve.line((43.00pt, 38.70pt)),
      curve.line((90.30pt, -64.50pt)), curve.line((139.75pt, -111.80pt)),
      curve.line((193.50pt, -21.50pt)), curve.line((247.25pt, 96.75pt)),
      curve.line((301.00pt, 73.10pt)), curve.line((354.75pt, -53.75pt)),
      curve.line((408.50pt, -103.20pt)), curve.line((483.75pt, 43.00pt)),
    )
    #curve(
      stroke: 2.15pt + rgb("#edc948"),
      curve.move((0.00pt, 94.60pt)), curve.line((38.70pt, -90.30pt)),
      curve.line((96.75pt, 86.00pt)), curve.line((154.80pt, -81.70pt)),
      curve.line((215.00pt, 98.90pt)), curve.line((275.20pt, -92.45pt)),
      curve.line((333.25pt, 83.85pt)), curve.line((391.30pt, -77.40pt)),
      curve.line((451.50pt, 92.45pt)), curve.line((483.75pt, 0.00pt)),
    )
  ]
]
]
