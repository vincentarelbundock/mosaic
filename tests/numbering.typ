#import "@local/mosaic:0.0.1" as mosaic
#import "support/grid.typ" as grid-test

#set page(width: 160pt, height: 90pt, margin: 5pt)
#let numbered-grid = mosaic.grid.v(
  "left",
  mosaic.grid.t(
    auto,
    mosaic.grid.cell(id: "right", content: align(right)[
      Slide #mosaic.slide-number(total: true)
      · Step #mosaic.step-number(total: true)
      · Page #mosaic.page-number(total: true)
    ]),
  ),
)
#assert(grid-test.count(numbered-grid) == 2)

#show: mosaic.setup.with(
  spacing: (inset: 5pt),
)
#set text(size: 7pt)

#mosaic.deck(
  default-grid: numbered-grid,
  background: [Inherited background],
  foreground: [
    Inherited foreground · #mosaic.slide-number(total: true)
  ],
)

// Two frames, one logical slide, and one supplied body. The fixed cell does
// not consume a body.
#mosaic.slide[
  #mosaic.reveal[First][Second]
]

// An unnumbered slide is excluded from the logical number and total. Its
// inherited slide-number() produces no content; none disables the background.
#mosaic.slide(
  grid: mosaic.grid.cell(id: "body"),
  background: none,
  numbered: false,
)[Unnumbered]

// Two replacement frames inherit the deck background and override only the
// foreground. This is logical slide 2.
#mosaic.slide(
  grid: mosaic.grid.cell(id: "body"),
  foreground: [
    Slide #mosaic.slide-number(total: true)
    · Step #mosaic.step-number(total: true)
  ],
)[
  #mosaic.replace[Before][After]
]

// Temporal foreground content contributes frames even when the body is static.
#mosaic.slide(
  grid: mosaic.grid.cell(id: "body"),
  background: none,
  foreground: mosaic.on("2-")[Foreground step],
)[Static body]

#context assert(counter(page).final().first() == 7)
