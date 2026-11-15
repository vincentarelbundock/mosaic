// A fitted title measures as what it occupies. Under `measure` Typst gives a
// body no height to fit against, so the title fitters answer from the region
// they were really placed in: non-zero, and inside that region. Content that
// was never placed has no such region and measures at its natural size.
//
// A title layout is a whole-slide grid, so it cannot be dropped into an
// `auto` track, `fit`, or `steps.replace`; the one reader that measures a
// title cell is the overflow observer. This fixture measures the cells the
// same way, from a plane of the slide that places them.
#import "@local/mosaic:0.0.3" as mosaic
#import "../mosaic/src/layout/resolver.typ": resolve-layout
#import "../mosaic/src/settings.typ": make-settings
#import "support/grid.typ" as grid-test

#let title = [A rather long title that wraps over several lines to test the collision behaviour of each variant in turn and then keeps going for a good while longer so that no slide could hold it at its natural size]
#let authors = range(8).map(index => mosaic.layouts.author(
  [Author Number #str(index)],
  affiliations: ([University #str(calc.rem(index, 3))],),
  email: "author" + str(index) + "@example.org",
))
#let deck = (title: title, subtitle: [A subtitle], authors: authors, date: [2026])

#show: mosaic.setup.with(..deck, overflow: "error")

// The title cell's own content, as the renderer hands it to the observer.
#let title-cell(variant) = grid-test.info(
  resolve-layout(mosaic.layouts.title(variant: variant), make-settings(deck: deck)),
  "title",
).cell.content

// The fitters read the placed region back through introspection, which is
// empty on the first layout pass, so nothing can be asserted inside the
// callback. Each measurement is published as a record instead, and
// scripts/run-tests.py checks the converged values.
#let measured(variant, placed) = layout(region => {
  // The display size a theme states on the cell's inner label applies here
  // too, so this is the stack the slide sets.
  let size = measure(title-cell(variant), width: region.width)
  [#metadata((
    variant: variant,
    placed: placed,
    height: size.height.pt(),
    region: region.height.pt(),
  ))<title-measure>]
})

// Placed: each variant's title cell measures as non-empty and inside the
// slide it was fitted to.
#for variant in ("centered", "bordered", "ruled", "kicker", "panel", "academic") {
  mosaic.slide(
    layout: "title",
    variant: variant,
    foreground: measured(variant, true),
  )
}

// Never placed: on a slide that renders no title, the same cells have no
// region on record and report their natural size, which is taller than the
// slide. That is the size the fitting above brought down.
#mosaic.slide(
  foreground: {
    for variant in ("centered", "ruled", "kicker") {
      measured(variant, false)
    }
  },
)[== Unplaced]
