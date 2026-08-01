#import "@local/mosaic:0.0.1" as m
#show: m.setup

// The thin title cell centers its content through its <mosaic-cell-ID> label.
#show label("mosaic-cell-a"): set align(center + horizon)

#m.slide(
  m.grid.v(
    m.grid.t(
      1fr,
      m.grid.cell("a"),
    ),
    m.grid.t(4fr, m.grid.h(m.grid.t(2fr, "b"), "c")),
  ),
)[
  *A thin title*
][
  *Wider column* \
  This cell receives two thirds of the available width.
][
  *Narrower column* \
  This cell receives one third.
]
