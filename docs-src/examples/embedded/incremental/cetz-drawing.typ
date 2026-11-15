#import "@preview/mosaic:0.0.1" as m
#import "@preview/cetz:0.5.2"

#show: m.setup

#let canvas = m.steps.drawing.with(
  render: cetz.canvas,
  hide: cetz.draw.hide.with(bounds: true),
)

#let grid = m.grids.rows(
  m.grids.track(auto, m.grids.cell(
    "title",
    inset: (top: 0.8em, right: 1.5em, bottom: 0.2em, left: 1.5em),
  )),
  m.grids.cell(
    "diagram",
    inset: (top: 0.2em, right: 1em, bottom: 0.8em, left: 1em),
  ),
)

// Center the diagram within its cell through its label.
#show label("mosaic-cell-diagram"): set align(center + horizon)

#m.slide(layout: grid)[
  == Reveal a Bloch sphere
][
  #text(size: 12pt)[
    #canvas(length: 2.2cm, {
      import cetz.draw: circle, content, line

      let rad = 2.5
      let vec-a = (rad / 3, rad / 2)
      let phi-point = (rad / 3, -rad / 5)
      let mark = (end: "stealth", fill: black)

      // Step 1: sphere.
      circle((0, 0), radius: rad)
      circle(
        (0, 0),
        radius: (rad, rad / 3),
        stroke: (dash: "dashed"),
        fill: gray.transparentize(70%),
      )

      // Step 2: coordinate axes.
      (
        m.steps.on("2-", (
          line(
            (0, 0),
            (-rad / 5 * 1.2, -rad / 3 * 1.2),
            mark: mark,
            name: "x1",
          ),
          content("x1.end", math.equation(alt: "x one", $x_1$), anchor: "north"),
          line((0, 0), (1.15 * rad, 0), mark: mark, name: "x2"),
          content("x2.end", math.equation(alt: "x two", $x_2$), anchor: "west"),
          line((0, 0), (0, 1.15 * rad), mark: mark, name: "x3"),
          content("x3.end", math.equation(alt: "x three", $x_3$), anchor: "south"),
        )),
      )

      // Step 3: Bloch vector and projection.
      (
        m.steps.on("3-", (
          line(
            (0, 0),
            vec-a,
            mark: (
              start: "circle",
              end: "circle",
              fill: black,
              scale: 0.5,
              anchor: "center",
            ),
          ),
          content(
            (rel: (0.08, 0.08), to: vec-a),
            math.equation(alt: "vector a", $arrow(a)$),
            anchor: "south-west",
          ),
          line((0, 0), phi-point, style: "dashed"),
          line(phi-point, vec-a, style: "dashed"),
        )),
      )

      // Step 4: angular coordinates.
      (
        m.steps.on("4-", (
          cetz.angle.angle(
            (0, 0),
            (-1, -calc.tan(60deg)),
            (1, -calc.tan(30deg)),
            label: math.equation(alt: "phi", $phi$),
            stroke: (paint: gray, thickness: 0.5pt),
            mark: (end: "stealth", fill: gray, scale: 0.7),
          ),
          cetz.angle.angle(
            (0, 0),
            (1, calc.tan(60deg)),
            (1, calc.tan(90deg)),
            label: math.equation(alt: "theta", $theta$),
            stroke: (paint: gray, thickness: 0.5pt),
            mark: (start: "stealth", fill: gray, scale: 0.7),
            label-radius: 0.75,
          ),
        )),
      )
    })
  ]
]
