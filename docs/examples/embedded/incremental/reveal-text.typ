#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(default-grid: m.grid.cell("body", inset: 1.5em))
#set text(size: 22pt)
#let slide = m.slide

#slide[
  == `on`: words and sentences

  The estimate is
  #m.steps.on(1, after: "visible")[*preliminary*],
  #m.steps.on(2, before: "dimmed", after: "dimmed")[*under review*],
  and finally
  #m.steps.on("3-")[*confirmed*].

  #m.steps.on("2-4", before: "hidden", after: "removed")[
    This sentence occupies space on steps 2 to 4.
  ]
]
