// Cells are structural; appearance is native. Every rendered cell is one
// block labeled <mosaic-cell-ID>, so decks style cells with ordinary
// label-targeted set/show rules, deck-wide or scoped around one slide.
#import "@local/mosaic:0.0.2" as mosaic

// The slide command carries no styling fields.
#let command = mosaic.slide(layout: mosaic.layouts.section())[Section].value
#assert("cell-styles" not in command.keys())

// Structural inset is the only visual-adjacent knob on a public cell.
#let structural = mosaic.grids.cell("flat", inset: 4pt)
#assert(structural.id == "flat")
#assert(structural.style.inset == 4pt)

#set page(width: 240pt, height: 135pt, margin: 0pt)
#show: mosaic.setup

// Deck-wide rules restyle the section cell natively.
#show label("mosaic-cell-section"): set align(left + horizon)
#show label("mosaic-cell-section"): set text(fill: white)
#show label("mosaic-cell-section"): it => block(
  width: 100%,
  height: 100%,
  fill: red,
  it,
)

#mosaic.slide(layout: mosaic.layouts.section())[Section]

// A scoped rule overrides the deck-wide rules for one slide only.
#[
  #show label("mosaic-cell-section"): it => block(
    width: 100%,
    height: 100%,
    fill: blue,
    it,
  )
  #mosaic.slide(layout: mosaic.layouts.section())[Scoped section]
]

#mosaic.slide(layout: mosaic.layouts.section())[Deck-wide again]
