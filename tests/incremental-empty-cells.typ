#import "@local/mosaic:0.0.2" as mosaic

// An `on(..)`-wrapped spacer cell — empty fixed content, no paint of its own —
// changes nothing visually, so it must not mint extra frames on which every
// page looks the same.
#set page(width: 160pt, height: 90pt, margin: 5pt)
#show: mosaic.setup.with(spacing: (inset: 5pt))
#set text(size: 7pt)

#mosaic.slide(
  layout: mosaic.grids.rows(
    mosaic.grids.track(1fr, "body"),
    mosaic.steps.on("2-", mosaic.grids.cell("spacer", content: [])),
  ),
)[ONLY VISIBLE THING]

#context {
  assert(counter(page).final().first() == 1)
}
