#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup

#mosaic.slide(
  grid: mosaic.layouts.default(
    variant: "header-body",
    progress: "1/1",
    accent: rgb("#d97706"),
  ),
)[
  == Layout-accent number
][
  The number uses the layout accent.
]

#mosaic.slide(
  grid: mosaic.layouts.default(
    progress: "circle",
    accent: rgb("#ffffff"),
  ),
)[
  == White circle
][
  The circle uses the layout accent.
][
  Footer
]

#mosaic.slide(
  grid: mosaic.layouts.default(
    progress: "circle",
    accent: rgb("#fedcba"),
  ),
)[
  == Styled circle
][
  The explicit layout accent also styles progress.
][
  Styled footer
]

#mosaic.slide(
  grid: mosaic.layouts.default(
    variant: "header-body",
    progress: "line",
    accent: rgb("#123456"),
  ),
)[
  == Layout-accent line
][
  The line uses the layout accent.
]

#mosaic.slide(
  grid: mosaic.layouts.default(
    variant: "header-body",
    progress: none,
  ),
)[
  == No progress
][
  `none` adds no layout foreground.
]

#context assert(counter(page).final().first() == 5)
