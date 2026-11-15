// The sizes `fit` accepts, and how prose that must shrink fills its cell.
#import "@local/mosaic:0.0.3" as mosaic

#set page(width: 320pt, height: 220pt, margin: 10pt)
#set text(size: 12pt)

// A ruler whose right edge reports how wide the fitted block ended up.
#let edge(name) = place(top + right)[#metadata(none)#label(name)]
#let ruler(name) = box(width: 2000pt, height: 10pt, edge(name))

// A relative width keeps its ratio: half the region plus a fixed part.
#block(width: 200pt, mosaic.fit(width: 50% + 20pt, ruler("relative-edge")))

// A ratio and a length resolve the same way.
#block(width: 200pt, mosaic.fit(width: 50%, ruler("ratio-edge")))
#block(width: 200pt, mosaic.fit(width: 6em, ruler("length-edge")))

// A fractional width is the whole region whatever its magnitude.
#block(width: 200pt, mosaic.fit(width: 2fr, ruler("fraction-edge")))

#pagebreak()

// Prose too tall for its cell is re-wrapped at a wider measure before it is
// scaled, so the result fills most of the cell's width rather than a narrow
// column of it.
#block(
  width: 300pt,
  height: 120pt,
  mosaic.fit[
    #box(width: 100%, height: 1pt, edge("prose-edge"))
    #lorem(400) #metadata(none) <prose-end>
  ],
)

#context {
  let x(name) = query(label(name)).first().location().position().x - 10pt
  let near(actual, expected) = calc.abs(actual - expected) < 0.5pt
  assert(near(x("relative-edge"), 120pt), message: repr(x("relative-edge")))
  assert(near(x("ratio-edge"), 100pt), message: repr(x("ratio-edge")))
  assert(near(x("length-edge"), 72pt), message: repr(x("length-edge")))
  assert(near(x("fraction-edge"), 200pt), message: repr(x("fraction-edge")))
  assert(x("prose-edge") > 240pt, message: repr(x("prose-edge")))
  let end = query(<prose-end>).first().location().position()
  assert(end.page == 2 and end.y <= 130pt + 0.5pt, message: repr(end))
}
