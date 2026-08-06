#import "@preview/mosaic:0.0.1" as mosaic

#let dog = path("/docs-src/assets/images/dog.webp")
#let bonsai = path("/docs-src/assets/images/bonsai.webp")

// Without a caption the result is a centered picture and no figure is involved.
// The defaults are the in-cell ones: uncropped, and filling the cell.
#let bare = mosaic.components.figure(dog, alt: "A brown dog")
#assert(bare.func() == align)
#assert(bare.body.func() == image)
#assert(bare.body.at("fit") == "contain")
#assert(bare.body.at("width") == 100%)
#assert(bare.body.at("height") == 100%)
#assert(bare.body.at("alt") == "A brown dog")

// An explicit height sizes the picture area directly, so the composition is
// settled at construction and the caption follows beneath it.
#let sized = mosaic.components.figure(dog, height: 40%, caption: [Sized])
#assert(sized.func() == align)
#assert(sized.body.func() == figure)
#assert(sized.body.body.at("height") == 40%)
#assert(sized.body.body.at("fit") == "contain")

// `height: auto` with a caption has to measure the caption before it can size
// the picture, so nothing is settled at construction: the composition is
// deferred to a layout pass, and the rendered pages below are what pin it.
#let auto-sized = mosaic.components.figure(dog, caption: [Auto])
#assert(auto-sized.func() != align)
#assert(auto-sized.func() != figure)

// A content body is scaled rather than refitted, so nothing is settled at
// construction there either, captioned or not.
#let tabled = mosaic.components.figure(table(columns: 1, [a]))
#assert(tabled.func() == align)
#assert(tabled.body.func() != table)

// Overrides reach the picture: a scrim wraps it, and cropping is still available
// for a figure that is meant to fill its cell exactly.
#let scrimmed = mosaic.components.figure(
  dog,
  fit: "cover",
  scrim: black.transparentize(65%),
)
#assert(scrimmed.body.func() != image)

#show: mosaic.setup.with(overflow: "off")
#set figure(numbering: none)

// The pair is the case the component exists for: two aspect ratios, no
// hand-found height, and one caption baseline across both cells.
#mosaic.slide(layout: "content", columns: 2)[== FIGURE PAIR][
  #mosaic.components.figure(dog, caption: [PORTRAIT CAPTION])
][
  #mosaic.components.figure(bonsai, caption: [LANDSCAPE CAPTION])
]

// A figure sharing its cell with prose cannot read the space left over, so it
// takes an explicit height.
#mosaic.slide(layout: "content", columns: 2)[== FIGURE BESIDE PROSE][
  - First claim
  - Second claim
  #mosaic.components.figure(dog, height: 50%, caption: [INLINE CAPTION])
][
  #mosaic.components.figure(bonsai, caption: [FULL CELL CAPTION])
]

// An uncaptioned figure fills its cell, and a scrim still applies.
#mosaic.slide(layout: "content", columns: 2)[== UNCAPTIONED][
  #mosaic.components.figure(bonsai)
][
  #mosaic.components.figure(dog, scrim: white.transparentize(70%))
]

// A content body keeps its own size and is scaled only when it does not fit, so
// a small table is left alone and captions directly beneath itself. `kind` is
// stated because scaling costs the figure its automatic detection.
#let estimates = table(
  columns: 3,
  [Spec], [Estimate], [SE],
  [Baseline], [0.42], [0.08],
  [Controls], [0.37], [0.09],
)
#mosaic.slide(layout: "content", columns: 2)[== CONTENT BODY][
  #mosaic.components.figure(
    estimates,
    caption: [SMALL TABLE CAPTION],
    kind: table,
  )
][
  #mosaic.components.figure(bonsai, caption: [PICTURE CAPTION])
]

// A body taller than its cell is scaled down as a whole rather than overflowing,
// and the caption keeps the size the deck gave it.
#mosaic.slide[== OVERSIZED CONTENT][
  #mosaic.components.figure(
    table(
      columns: 3,
      ..range(14).map(row => ([Row #row], [#row], [#calc.pow(2, row)])).flatten(),
    ),
    caption: [TALL TABLE CAPTION],
    kind: table,
  )
]
