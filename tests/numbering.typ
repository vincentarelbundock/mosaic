#import "@local/mosaic:0.0.1" as mosaic
#import "support/grid.typ" as grid-test

#set page(width: 160pt, height: 90pt, margin: 5pt)
#let numbered-grid = mosaic.grid.v(
  "left",
  mosaic.grid.t(
    auto,
    mosaic.grid.cell(id: "right", content: align(right)[Fixed furniture]),
  ),
)
#assert(grid-test.count(numbered-grid) == 2)

#show: mosaic.setup.with(
  spacing: (inset: 5pt),
  default-grid: numbered-grid,
  features: (slide-number: true, slide-total: true),
  background: [Inherited background],
  foreground: [Inherited foreground],
)
#set text(size: 7pt)

// Two frames, one logical slide, and one supplied body. The fixed cell does
// not consume a body.
#mosaic.slide[
  #mosaic.steps.reveal[First][Second]
]

// An unnumbered slide is excluded from the logical number and total. Its
// built-in numbering produces no content; the reserved `background` entry set
// to none disables the inherited plane.
#mosaic.slide(
  grid: mosaic.grid.cell(id: "body"),
  content: (background: none),
  numbered: false,
)[Unnumbered]

// Two replacement frames inherit the deck background and override only the
// foreground. This is logical slide 2.
#mosaic.slide(
  grid: mosaic.grid.cell(id: "body"),
  content: (foreground: [Local foreground]),
)[
  #mosaic.steps.replace[Before][After]
]

// Temporal foreground content contributes frames even when the body is static.
#mosaic.slide(
  grid: mosaic.grid.cell(id: "body"),
  content: (
    background: none,
    foreground: mosaic.steps.on("2-")[Foreground step],
  ),
)[Static body]

#context assert(counter(page).final().first() == 7)
