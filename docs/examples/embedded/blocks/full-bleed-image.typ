#import "@local/mosaic:0.0.1" as m

#show: m.setup

// The text cell centers its content vertically through its label.
#show label("mosaic-cell-b"): set align(left + horizon)

#m.slide(m.grid.h(
  m.grid.t(
    1fr,
    m.grid.cell(
      id: "a",
      inset: 0pt,
      content: m.components.image(
        path("/docs/assets/images/dog.webp"),
        alt: "A brown dog",
      ),
    ),
  ),
  m.grid.t(
    2fr,
    m.grid.cell("b"),
  ),
))[
  == A full-bleed image cell

  Cells have an `inset` by default. To cover the entire cell, set it to `0pt`;
  `m.components.image()` supplies the full-size cover defaults.

  The first child receives one third of the width through
  `m.grid.t(1fr, ...)`.
]
