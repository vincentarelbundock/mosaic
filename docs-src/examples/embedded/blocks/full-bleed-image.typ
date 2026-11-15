#import "@local/mosaic:0.0.3" as m

#show: m.setup

// The text cell centers its content vertically through its label.
#show label("mosaic-cell-b"): set align(left + horizon)

#m.slide(layout: m.grids.columns(
  tracks: (1fr, 2fr),
  m.grids.cell(
    "a",
    inset: 0pt,
    content: m.components.image(
      path("/docs-src/assets/images/dog.webp"),
      alt: "A brown dog",
    ),
  ),
  "b",
))[
  == A full-bleed image cell

  Cells have an `inset` by default. To cover the entire cell, set it to `0pt`;
  `m.components.image()` supplies the full-size cover defaults.

  The image cell receives one third of the width through
  `tracks: (1fr, 2fr)`.
]
