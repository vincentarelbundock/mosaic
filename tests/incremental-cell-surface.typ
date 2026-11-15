#import "@local/mosaic:0.0.3" as mosaic

// `steps.on` around a cell hides the whole cell, not just its body: the paint
// a label rule puts on the cell block is hidden with it, as it is for a cell
// inside a hidden split. A hidden cell still holds its place, including in an
// `auto` track, so nothing moves when it appears. The runner asserts that the
// fills are absent from frame 1 and present on frame 2.
#show: mosaic.setup.with(
  paper: (width: 240pt, height: 135pt),
  spacing: (inset: 5pt),
)
#set text(size: 7pt)
#show label("mosaic-cell-strip"): set block(fill: rgb("#ff4136"))
#show label("mosaic-cell-side"): set block(fill: rgb("#0074d9"))
#show label("mosaic-cell-logo"): set block(fill: rgb("#2ecc40"))

#mosaic.slide(mosaic.grids.rows(
  mosaic.grids.track(auto, mosaic.steps.on("2-", mosaic.grids.cell("strip"))),
  mosaic.grids.track(auto, mosaic.grids.columns(
    "head",
    mosaic.grids.track(auto, mosaic.steps.on("2-", mosaic.grids.cell("logo"))),
  )),
  mosaic.grids.columns(
    "body",
    mosaic.steps.on("2-", mosaic.grids.cell("side")),
  ),
))[Strip][Head][Logo][Body][Side]

#context {
  assert(counter(page).final().first() == 2)
  for anchor in (
    "strip-bottom", "head-top-right", "logo-top-left", "body-top",
    "body-right", "side-bottom-right",
  ) {
    let positions = query(label("mosaic-cell-" + anchor)).map(
      item => item.location().position(),
    )
    assert(positions.len() == 2, message: anchor + ": " + repr(positions))
    assert(
      positions.first().x == positions.last().x
        and positions.first().y == positions.last().y,
      message: anchor + ": " + repr(positions),
    )
  }
  // The hidden strip is not collapsed: the row below it starts lower.
  let strip = query(<mosaic-cell-strip-top>).first().location().position()
  let head = query(<mosaic-cell-head-top>).first().location().position()
  assert(head.y > strip.y + 5pt, message: repr((strip, head)))
}
