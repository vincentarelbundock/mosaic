#import "@local/mosaic:0.0.1" as m

#show: m.setup

#m.slide(m.grid.h(
  m.grid.t(
    1fr,
    m.grid.cell(
      id: "a",
      content: m.image(
        path("/docs/assets/images/dog.webp"),
        alt: "A brown dog",
      ),
    ),
  ),
  m.grid.t(
    2fr,
    m.grid.cell("b"),
  ),
), cell-styles: (
  a: (inset: 0pt),
  b: (align: left + horizon),
))[
  == A full-bleed image cell

  Cells have an `inset` by default. To cover the entire cell, set it to `0pt`;
  `m.image()` supplies the full-size cover defaults.

  The first child receives one third of the width through
  `m.grid.t(1fr, ...)`.
]
