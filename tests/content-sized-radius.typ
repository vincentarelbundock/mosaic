#import "@local/mosaic:0.0.1" as mosaic
#import "../mosaic/src/grid/constructors.typ": styled-cell
#show: mosaic.setup

#let compact = styled-cell(
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
  mosaic.grids.track(auto, compact),
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
