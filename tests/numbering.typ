#import "@local/mosaic:0.0.1" as mosaic
#import "support/grid.typ" as grid-test

#set page(width: 160pt, height: 90pt, margin: 5pt)
#let numbered-grid = mosaic.grids.v(
  "left",
  mosaic.grids.t(
    auto,
    mosaic.grids.cell(id: "right", content: align(right)[Fixed furniture]),
  ),
)
#assert(grid-test.count(numbered-grid) == 2)

#let slide-number = [
  #place(bottom + right, dx: -5pt, dy: -5pt)[
    #mosaic.components.progress(variant: "1/1")
  ]
]

#show: mosaic.setup.with(
  spacing: (inset: 5pt),
  layouts: (content: numbered-grid),
  content: (
    background: [Inherited background],
    foreground: [Inherited foreground #slide-number],
  ),
)
#set text(size: 7pt)

// Two frames, one logical slide, and one supplied body. The fixed cell does
// not consume a body.
#mosaic.slide[
  #mosaic.steps.reveal[First][Second]
]

// An unnumbered slide is excluded from the logical number and total. Its
// foreground set to none explicitly suppresses both inherited furniture and
// the number; background none disables the inherited background plane.
#mosaic.slide(
  layout: mosaic.grids.cell(id: "body"),
  content: (background: none, foreground: none),
  numbered: false,
)[Unnumbered]

// Two replacement frames inherit the deck background and override only the
// foreground. This is logical slide 2.
#mosaic.slide(
  layout: mosaic.grids.cell(id: "body"),
  content: (foreground: [Local foreground #slide-number]),
)[
  #mosaic.steps.replace[Before][After]
]

// Temporal foreground content contributes frames even when the body is static.
#mosaic.slide(
  layout: mosaic.grids.cell(id: "body"),
  content: (
    background: none,
    foreground: [#mosaic.steps.on("2-")[Foreground step] #slide-number],
  ),
)[Static body]

#context assert(counter(page).final().first() == 7)
