#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup.with(
  colors: mosaic.color.scheme("light"),
  features: (
    progress: true,
    slide-number: true,
  ),
)

#mosaic.slide[
  Base before
]

#mosaic.slide(
  colors: mosaic.color.scheme("editorial"),
)[
  Editorial only
]

#mosaic.slide[
  Base after
]

#mosaic.slide(
  colors: (accent: rgb("#d97706")),
)[
  Inherited light with amber accent
]

#mosaic.slide(
  colors: mosaic.color.scheme("spotlight"),
)[
  #mosaic.reveal[
    - First frame
  ][
    - Second frame
  ]
]

#context assert(counter(page).final().first() == 6)
