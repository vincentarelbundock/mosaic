#import "@local/mosaic:0.0.1" as mosaic

// The shrink-to-fit engine is reachable from both public producers: the `fit:`
// field on the content layout and `fit:` on a hand-built cell. The same body
// that overflows an ordinary cell must stay inside a fitted one, so overflow
// observation reports the control cell and nothing else.
#show: mosaic.setup.with(overflow: "warn")

#mosaic.slide(layout: mosaic.layouts.content(variant: "body", fit: "auto"))[
  #lorem(180)
]

#mosaic.slide(layout: mosaic.layouts.content(variant: "body", fit: "contain"))[
  #lorem(180)
]

#mosaic.slide(layout: mosaic.grid.v(
  mosaic.grid.cell("wide", fit: "width"),
  mosaic.grid.cell("tall", fit: "auto"),
))[
  MOSAIC-FIT-SINGLE-LINE-THAT-IS-FAR-TOO-WIDE-FOR-THIS-CELL-TO-HOLD
][
  #lorem(180)
]

// Control: the same body without `fit` genuinely overflows, so the pages above
// prove the fitters ran rather than that the content fit anyway.
#mosaic.slide(layout: mosaic.layouts.content(variant: "body"))[
  #lorem(180)
]

#context assert(counter(page).final().first() == 4)
