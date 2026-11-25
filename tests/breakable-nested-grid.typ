// A flowing body that nests a rows split: its fractional tracks turn `auto`
// only so the body can break, and its `auto`-inset cells keep the inset the
// fixed frame gives them. The runner checks that the first line of each
// nested cell sits at the same height on the fixed short slide and on the
// first page of the paginated long one.
#import "@local/mosaic:0.0.3" as mosaic

#show: mosaic.setup.with(breakable: true, spacing: (inset: 24pt))

#let stack = mosaic.grids.rows(
  mosaic.grids.track(auto, "header"),
  mosaic.grids.rows("upper", "lower"),
  mosaic.grids.track(auto, "footer"),
)

#mosaic.slide(stack)[Head][Upperstart short.][Lowerstart short.][Footmark]

#mosaic.slide(stack)[Head][Upperstart long.][Lowerstart long.\ #for index in range(1, 25) [Line #index.\ ]][Footmark]
