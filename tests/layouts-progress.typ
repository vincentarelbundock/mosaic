#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup

#mosaic.slide(
  grid: mosaic.layouts.default(
    variant: "header-body",
    progress: "1/1",
  ),
  colors: (accent: rgb("#d97706")),
)[
  == Slide-local number
][
  The number uses the slide-local accent.
]

#mosaic.slide(
  grid: mosaic.layouts.default(
    progress: "circle",
  ),
  colors: (accent: rgb("#ffffff")),
)[
  == White circle
][
  The circle uses the slide-local accent.
][
  Footer
]

#mosaic.slide(
  grid: mosaic.layouts.default(
    progress: "circle",
  ),
  colors: (accent: rgb("#fedcba")),
)[
  == Styled circle
][
  The slide-local accent also styles progress.
][
  Styled footer
]

#mosaic.slide(
  grid: mosaic.layouts.default(
    variant: "header-body",
    progress: "line",
  ),
  colors: (accent: rgb("#123456")),
)[
  == Slide-local line
][
  The line uses the slide-local accent.
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
