#import "@local/mosaic:0.0.2" as mosaic
#import "support/grid.typ" as grid-test

#set page(width: 320pt, height: 180pt, margin: 8pt)
#let base = mosaic.grids.cell(id: "main")
#assert(grid-test.count(base) == 1)
#assert(grid-test.info(base, "main").id == "main")
#assert("image" in mosaic.components)
#assert("progress" in mosaic.components)
#show: mosaic.setup.with(
  spacing: (inset: 8pt),
)
#set text(size: 9pt)

#mosaic.slide(layout: mosaic.grids.columns("a", "b"))[
  #mosaic.components.card(role: "accent")[
    #mosaic.components.badge(
      radius: 999pt,
      text: (weight: "bold"),
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
  layout: mosaic.grids.columns("first", "second", "third"),
)[
  #mosaic.components.card(role: "accent")[Panel body]
][
  #mosaic.components.callout(
    [Callout body],
    role: "warning",
    title: [Result],
  )
][
  #mosaic.components.card(role: "warning")[Banner body]
]

#mosaic.slide(
  layout: mosaic.grids.columns("numbers", "circle", "line"),
)[
  #mosaic.components.progress(variant: "1/1")
][
  #mosaic.components.progress(variant: "circle", width: 1.2em)
][
  #mosaic.components.progress(variant: "line")
]

#mosaic.slide()[
  #mosaic.components.progress(variant: "1/1")
  #h(1em)
  #mosaic.components.progress(variant: "circle")
  #v(0.5em)
  #mosaic.components.progress(variant: "line")
]

// A renderer function stands in for the closed variant set, so an extension
// theme can add a treatment without forking the component.
#mosaic.slide()[
  #mosaic.components.progress(
    variant: state => grid(
      columns: (state.thickness,) * state.total,
      column-gutter: 2pt,
      ..range(state.total).map(index => rect(
        width: state.thickness,
        height: state.thickness,
        fill: if index < state.current { state.accent } else { state.fill },
      )),
    ),
  )
]
