#import "@local/mosaic:0.0.1" as mosaic
#import "@preview/fletcher:0.5.8" as fletcher

#set page(width: 160pt, height: 90pt, margin: 5pt)
// Three pages: integer, closed, and open ranges in ordinary content.
#show: mosaic.setup.with(
  spacing: (inset: 5pt),
)
#set text(size: 7pt)

#mosaic.slide[
  #mosaic.steps.on(1, after: "visible")[Always after step 1.]
  #mosaic.steps.on("2-3", before: "dimmed", after: "removed")[Middle.]
  #mosaic.steps.on("3-")[Last.]
]

// Two pages: the active cell changes and removed tracks reflow.
#let changing-columns = mosaic.grid.h(
  mosaic.steps.on(1, after: "removed", mosaic.grid.cell(id: "first")),
  mosaic.steps.on("2-", before: "removed", mosaic.grid.cell(id: "second")),
)
#mosaic.slide(grid: changing-columns)[First cell][Second cell]

// Three pages: list items are recognized inside ordinary list markup.
#mosaic.slide[
  #mosaic.steps.reveal[
    - One
    - Two
    - Three
  ]
]

// Two pages: alternatives share one measured slot.
#mosaic.slide[
  #mosaic.steps.replace([short], [a longer alternative])
]

// Three pages: equation terms use the same structural temporal wrappers.
#mosaic.slide[
  $
    f(x)
      = #mosaic.steps.on("1-")[$x^2$]
      #mosaic.steps.on("2-")[$+ 2x$]
      #mosaic.steps.on("3-")[$+ 1$]
  $
  $
    f(x) = #mosaic.steps.replace([$x^2 + 2x + 1$], [$(x + 1)^2$])
  $
]

// Two pages: command reducers interpret on() without depending on CeTZ.
#let render-commands(commands) = commands.join(", ")
#let preserve-commands(commands) = commands
#let command-canvas = mosaic.steps.reduce.with(
  render: render-commands,
  hide: preserve-commands,
)
#mosaic.slide[
  #command-canvas((
    "base",
    mosaic.steps.on("2-", "later"),
  ))
]

// Three pages: reducers also recognize timed content commands such as
// Fletcher's node and edge metadata.
#let fletcher-diagram = mosaic.steps.reduce.with(
  render: fletcher.diagram,
  hide: fletcher.hide,
)
#mosaic.slide[
  #fletcher-diagram(
    fletcher.node((0, 0), [A]),
    mosaic.steps.reveal(
      start: 2,
      fletcher.edge((0, 0), (1, 0), "->"),
      fletcher.node((1, 0), [B]),
    ),
  )
]

// 3 + 2 + 3 + 2 + 3 + 2 + 3 physical pages.
#context assert(counter(page).final().first() == 18)
