// The deck record and internal logical-slide numbering.
//
// Typst gives a show-rule package exactly two channels between `setup` and the
// slide commands a user authors outside its lexical scope: `state` or metadata
// plus `query`. Mosaic uses one state value for everything `setup` declares:
// settings (colors, roles, spacing, notes geometry, content defaults, deck
// metadata, overflow policy), configured layouts, freezing, handout, output,
// and paper. The record is written exactly once, by `setup`, and never mutated
// afterward; `write-deck-record` enforces that, so the record behaves as
// declared configuration rather than evolving hidden state. Readers that can
// run outside a deck (components, cell insets) treat `none` as "no deck" and
// fall back to library defaults.
#import "shared.typ": fail, key

#let deck-state = state(key("deck"), none)

#let write-deck-record(record) = deck-state.update(current => {
  if current != none {
    fail("setup already configured this deck; apply setup exactly once")
  }
  record
})

#let logical-slide = counter(key("logical-slide"))
#let logical-slide-id = counter(key("logical-slide-id"))
#let logical-section = counter(key("logical-section"))
