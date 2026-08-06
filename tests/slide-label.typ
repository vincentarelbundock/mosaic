#import "@preview/mosaic:0.0.1" as mosaic

#show: mosaic.setup

// <mosaic-slide> wraps the whole cell grid, so one rule reaches every cell the
// resolved layout produced, whatever they are.
#[
  #show label("mosaic-slide"): set text(fill: red)
  #mosaic.slide(layout: "content", columns: 2)[== SLIDE LABEL HEADER][
    SLIDE LABEL BODY ONE
  ][SLIDE LABEL BODY TWO]
]

// Per-cell rules sit inside the slide rule and refine it.
#[
  #show label("mosaic-slide"): set text(fill: red)
  #show label("mosaic-cell-header"): set text(fill: blue)
  #mosaic.slide()[== SLIDE LABEL REFINED][SLIDE LABEL REFINED BODY]
]

#context assert(
  query(label("mosaic-slide")).len() >= 2,
  message: "every slide must carry the <mosaic-slide> label",
)
