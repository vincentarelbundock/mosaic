#import "@local/mosaic:0.0.1" as mosaic
#import "support/grid.typ" as grid-test

#set page(width: 320pt, height: 180pt, margin: 8pt)
#let base = mosaic.grid.cell(id: "main")
#assert(grid-test.count(base) == 1)
#assert(grid-test.info(base, "main").id == "main")
#assert("roles" in mosaic.components)
#assert("progress" in mosaic.components)
#assert("warning" in mosaic.components.roles)
#show: mosaic.setup.with(
  spacing: (inset: 8pt),
)
#set text(size: 9pt)

#mosaic.slide(mosaic.grid.h("a", "b"))[
  #mosaic.components.frame(role: "information")[
    #mosaic.components.label(
      radius: 999pt,
      text-style: (weight: "bold"),
    )[Category]
    #parbreak()
    #text(size: 2em, weight: "bold")[77%]
    #linebreak()
    Primary result
  ]
][
  #mosaic.components.quote(
    [A compact quotation treatment.],
    attribution: [Author],
  )
]

#mosaic.slide(
  mosaic.grid.h("first", "second", "third"),
)[
  #mosaic.components.frame(role: "information")[Panel body]
][
  #mosaic.components.callout(
    [Callout body],
    kind: "takeaway",
    title: [Result],
  )
][
  #mosaic.components.frame(role: "warning")[Banner body]
]

#mosaic.slide(
  mosaic.grid.h("numbers", "circle", "line"),
)[
  #mosaic.components.progress(variant: "1/1")
][
  #mosaic.components.progress(variant: "circle", size: 1.2em)
][
  #mosaic.components.progress(variant: "line")
]

#mosaic.slide()[
  #mosaic.components.progress(
    variant: "1/1",
    current: 2,
    total: 5,
  )
  #h(1em)
  #mosaic.components.progress(
    variant: "circle",
    current: 2,
    total: 5,
  )
  #v(0.5em)
  #mosaic.components.progress(
    variant: "line",
    current: 2,
    total: 5,
  )
]
