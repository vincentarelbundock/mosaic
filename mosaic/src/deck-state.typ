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

// The settings half of the record, or `none` outside a deck. The canonical
// accessor for readers that treat "no deck" as a fallback case; call inside
// `context`.
#let deck-settings() = {
  let record = deck-state.get()
  if record == none { none } else { record.settings }
}

#let write-deck-record(record) = deck-state.update(current => {
  if current != none {
    fail("setup already configured this deck; apply setup exactly once")
  }
  record
})

#let logical-slide = counter(key("logical-slide"))
#let logical-slide-id = counter(key("logical-slide-id"))
#let logical-section = counter(key("logical-section"))

// Whether the slide currently rendering is numbered. The slide runtime writes
// it once per slide, before the planes render, so deck furniture (a folio, a
// statusline, a progress ring) can quiet itself on unnumbered pages such as
// titles and sections:
//
//   context if slide-numbered.get() { .. }
#let slide-numbered = state(key("slide-numbered"), true)
