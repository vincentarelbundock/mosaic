#import "../mosaic/src/settings.typ": make-settings, validate-settings

#let settings = make-settings()
#assert(settings.keys().sorted() == (
  "colors", "content", "deck", "notes", "overflow", "roles", "spacing",
))
// `auto` means the semantic roles follow the deck's own colors. A theme with a
// component look of its own supplies a complete palette instead.
#assert(settings.roles == auto)
#assert(settings.content == (:))
#let with-content = make-settings(content: (
  footer: "Footer",
  background: "Background",
  foreground: [Foreground],
  empty: none,
))
#assert(type(with-content.content.footer) == content)
#assert(with-content.content.footer == [Footer])
#assert(with-content.content.background == [Background])
#assert(with-content.content.foreground == [Foreground])
#assert(with-content.content.empty == none)
#assert(settings.deck == (title: none, subtitle: none, authors: (), date: none))
#assert(settings.colors.keys().sorted() == (
  "accent", "canvas", "line", "muted", "surface", "text",
))
#assert(settings.colors.values().all(value => type(value) == color))
// The printed outputs read against paper, not against the deck palette, so the
// defaults stay black regardless of theme. Every field is overridable.
#assert(settings.notes.text-fill == black)
#assert(settings.notes.margin == 15mm)
#assert(make-settings(notes: (margin: 8mm)).notes.margin == 8mm)
#assert(make-settings(notes: (text-fill: red)).notes.text-fill == red)
// An unmerged field keeps its default rather than dropping out of the record.
#assert(make-settings(notes: (margin: 8mm)).notes.text-size == 10pt)
#assert(settings.overflow == "warn")
#assert(make-settings(overflow: "off").overflow == "off")
#assert(validate-settings(settings) == settings)
