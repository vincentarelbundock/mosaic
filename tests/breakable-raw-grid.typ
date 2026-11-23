// A raw rows grid breaks like the content layout, and lays its rows out as
// the fixed frame does. Its body cell leaves `inset` at `auto` and the split
// has a gutter, the two places the flowing layout could drift: the runner
// checks that the body's first line and the footer sit at the same height on
// the fixed short slide and on every page of the paginated long one.
#import "@local/mosaic:0.0.3" as mosaic

#show: mosaic.setup.with(breakable: true, spacing: (inset: 24pt))

#let stack = mosaic.grids.rows(
  gutter: 12pt,
  mosaic.grids.track(auto, "header"),
  "body",
  mosaic.grids.track(auto, "footer"),
)

#mosaic.slide(stack)[Head][Bodystart of the short slide.][Footmark]

#mosaic.slide(stack)[Head][Bodystart of the long slide.\ #for index in range(1, 25) [Line #index.\ ]][Footmark]
