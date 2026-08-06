#import "@preview/mosaic:0.0.1" as mosaic

// The public entry point, exercised through the package facade rather than the
// module path, so a helper that stops being exported fails here.
#set page(width: 320pt, height: 220pt, margin: 10pt)
#set text(size: 24pt)

// A width alone is a width problem: the region's height must not bind first.
#block(
  width: 120pt,
  stroke: 0.5pt,
  mosaic.fit(width: 1fr)[MOSAIC-AUTOMATIC-SCALING],
)

#pagebreak()

// Both axes constrain, and the smaller ratio wins.
#block(
  width: 180pt,
  height: 90pt,
  stroke: 0.5pt,
  mosaic.fit[
    MOSAIC-FIT-GEOMETRIC: a longer text block scales geometrically to remain
    within a finite width and height.
  ],
)

#pagebreak()

// The other direction. Shrink-only is the default, so growing is opt-in.
#block(
  width: 280pt,
  height: 120pt,
  stroke: 0.5pt,
  mosaic.fit(grow: true)[MOSAIC-FIT-GROW],
)

#pagebreak()

// Content that already fits is returned untouched when growing is off.
#block(
  width: 280pt,
  height: 120pt,
  stroke: 0.5pt,
  mosaic.fit[MOSAIC-FIT-UNTOUCHED],
)

#pagebreak()

// `wrap: false` measures content as it stands. A table offered a narrower width
// would rearrange its columns instead of scaling, so the flag must reach the
// natural-size path and shrink the whole block.
#block(
  width: 200pt,
  height: 120pt,
  stroke: 0.5pt,
  mosaic.fit(
    wrap: false,
    table(
      columns: 4,
      [MOSAIC], [FIT], [WRAP], [FALSE],
      [1], [2], [3], [4],
    ),
  ),
)

#pagebreak()

// Under `measure` there is no allocation to solve against: the region is
// unbounded, the fitters hand the body back rather than dividing by it, and the
// `1fr` block they sit in collapses. A fitted block therefore measures as no
// height at all, which is why overflow observation never reports one. Pinned
// here because the overflow contract in `grid/render.typ` depends on it.
#context {
  let measured = measure(mosaic.fit[MOSAIC-FIT-MEASURED])
  assert(
    measured.height == 0pt,
    message: "a fitted block must measure as no height, got " + repr(measured.height),
  )
  [MOSAIC-FIT-MEASURED-OK]
}
