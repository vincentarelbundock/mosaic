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
// The notes record is geometry only: the printed pages' typography lives in
// show rules on the <mosaic-note-heading> and <mosaic-note-body> labels, not
// in settings. Every geometric field is overridable.
#assert(settings.notes.keys().sorted() == (
  "bottom-gap", "heading-gap", "margin", "note-gap", "thumbnail-gap",
  "thumbnail-stroke",
))
#assert(settings.notes.margin == 15mm)
#assert(make-settings(notes: (margin: 8mm)).notes.margin == 8mm)
// An unmerged field keeps its default rather than dropping out of the record.
#assert(make-settings(notes: (margin: 8mm)).notes.note-gap == 3mm)
#assert(settings.overflow == "warn")
#assert(make-settings(overflow: "off").overflow == "off")
#assert(validate-settings(settings) == settings)
