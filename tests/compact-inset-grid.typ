// A hand-built grid draws the same header strip as the built-in content
// layout. Regression: a user cell in an `auto` row took the full inset on all
// four sides while the built-in header took a shallower vertical inset, so a
// recolored header changed depth between a custom content slide and an image
// slide in the same deck.
#import "@local/mosaic:0.0.3" as mosaic
#import mosaic.themes.metropolis as m

#show: m.setup.with(spacing: (compact-inset: 20pt))

#let hand-built = m.grids.rows(
  m.grids.track(auto, "header"),
  m.grids.track(1fr, "body"),
)

#m.slide(layout: hand-built)[== Hand-built][Body]
#m.slide(layout: m.layouts.content(variant: "header-body"))[== Built-in][Body]
#m.slide(
  layout: "image",
  image: rect(width: 4cm, height: 3cm),
)[== Image]

#context {
  let bottoms = query(label("mosaic-cell-header-bottom-left")).map(it => {
    it.location().position().y
  })
  assert(bottoms.len() == 3, message: repr(bottoms))
  assert(
    bottoms.all(y => y == bottoms.first()),
    message: "header strips differ: " + repr(bottoms),
  )
}
