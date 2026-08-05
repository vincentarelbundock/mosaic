#import "../mosaic/src/settings.typ": make-settings, validate-settings

#let settings = make-settings()
#assert(settings.keys().sorted() == (
  "background", "cells", "colors", "deck", "foreground", "notes", "overflow",
  "spacing",
))
// The header default rides in the settings record itself, so every reader of
// `settings.cells` sees the same optional-header contract.
#assert(settings.cells == (header: none))
#let with-cells = make-settings(
  cells: (footer: "Footer", empty: none),
  background: "Background",
  foreground: [Foreground],
)
#assert(type(with-cells.cells.footer) == content)
#assert(with-cells.cells.footer == [Footer])
#assert(with-cells.cells.empty == none)
// The planes are their own settings fields, not entries in the cell map.
#assert(with-cells.background == [Background])
#assert(with-cells.foreground == [Foreground])
#assert(settings.background == none)
#assert(settings.foreground == none)
#assert(settings.deck == (title: none, subtitle: none, authors: (), date: none))
// One flat palette: six deck colors plus the three status colors components
// paint with. There is no second role record beside it.
#assert(settings.colors.keys().sorted() == (
  "accent", "canvas", "error", "line", "muted", "surface", "text", "warning",
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
#assert(settings.overflow == "off")
#assert(make-settings(overflow: "off").overflow == "off")
#assert(validate-settings(settings) == settings)
