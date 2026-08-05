#import "@local/mosaic:0.0.1" as m
#import "@preview/fletcher:0.5.8" as fletcher

#show: m.setup

#let colors = (
  rgb("#E69F00"), rgb("#56B4E9"), rgb("#009E73"), rgb("#F0E442"),
  rgb("#0072B2"), rgb("#D55E00"), rgb("#CC79A7"),
)
#let diagram = m.steps.reduce.with(
  render: fletcher.diagram,
  hide: fletcher.hide,
)

// Center the diagram within its cell through its label.
#show label("mosaic-cell-diagram"): set align(center + horizon)

#m.slide(layout: 
  m.grids.cell("diagram"),
)[
  #diagram(
    node-stroke: 0.1em,
    node-fill: gradient.radial(
      colors.at(1).lighten(75%),
      colors.at(1),
      center: (30%, 20%),
      radius: 80%,
    ),
    spacing: 4em,
    fletcher.edge(
      (-1, 0),
      "r",
      "-|>",
      `open(path)`,
      label-pos: 0,
      label-side: center,
    ),
    fletcher.node((0, 0), `reading`, radius: 2em),
    m.steps.on("2-", (
      fletcher.edge(`read()`, "-|>"),
      fletcher.node((1, 0), `eof`, radius: 2em),
      fletcher.edge(
        (0, 0),
        (0, 0),
        `read()`,
        "--|>",
        bend: 130deg,
      ),
    )),
    m.steps.on("3-", (
      fletcher.edge(`close()`, "-|>"),
      fletcher.node(
        (2, 0),
        `closed`,
        radius: 2em,
        extrude: (-2.5, 0),
      ),
      fletcher.edge(
        (0, 0),
        (2, 0),
        `close()`,
        "-|>",
        bend: -40deg,
      ),
    )),
  )
]
