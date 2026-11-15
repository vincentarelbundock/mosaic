#import "@local/mosaic:0.0.3" as mosaic
#import "../mosaic/src/grid/constructors.typ": make-cell
#show: mosaic.setup

#let compact = make-cell(
  content: [Compact title],
  id: "compact-radius",
  style: (
    content-sized: true,
    inset: 4pt,
    radius: 4pt,
    fill: red,
  ),
)

#mosaic.slide(layout: mosaic.grids.rows(
  tracks: (auto, 1fr),
  compact,
  mosaic.grids.cell(id: "body"),
))[Body]

#context {
  let top = query(label("mosaic-cell-compact-radius-top")).first().location().position()
  let bottom = query(label("mosaic-cell-compact-radius-bottom")).first().location().position()
  let body-top = query(label("mosaic-cell-body-top")).first().location().position()
  assert(top.page == bottom.page)
  assert(
    bottom.y - top.y < 30pt,
    message: "a rounded content-sized cell must retain intrinsic height",
  )
  assert(
    body-top.y - top.y < 80pt,
    message: "a rounded content-sized row must not consume the full slide",
  )
}
