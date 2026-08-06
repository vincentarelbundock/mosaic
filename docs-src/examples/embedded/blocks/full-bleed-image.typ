#import "@preview/mosaic:0.0.1" as m

#show: m.setup

// The text cell centers its content vertically through its label.
#show label("mosaic-cell-b"): set align(left + horizon)

#m.slide(layout: m.grids.columns(
  m.grids.track(
    1fr,
    m.grids.cell(
      id: "a",
      inset: 0pt,
      content: m.components.image(
        path("/docs-src/assets/images/dog.webp"),
        alt: "A brown dog",
      ),
    ),
  ),
  m.grids.track(
    2fr,
    m.grids.cell("b"),
  ),
))[
  == A full-bleed image cell

  Cells have an `inset` by default. To cover the entire cell, set it to `0pt`;
  `m.components.image()` supplies the full-size cover defaults.

  The first child receives one third of the width through
  `m.grids.track(1fr, ...)`.
]
