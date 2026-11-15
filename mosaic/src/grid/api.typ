// Curated public grid-constructor namespace. Track sizes are the `tracks:`
// argument of `columns` and `rows`. The internal wrapper the layout resolvers
// use is `make-track` in constructors.typ and is deliberately not exported;
// the `track` below is a signpost, not a constructor.
#import "constructors.typ": cell, columns, rows
#import "../shared.typ" as _shared

/// Removed. This name exists only to point a deck that still calls it at the
/// replacement: `columns` and `rows` size their children through `tracks:`,
/// an array with one size per child.
///
/// ```typ
/// #mosaic.grids.rows(tracks: (auto, 1fr), "header", "body")
/// ```
///
/// Every call fails with that message, whatever the arguments.
///
/// -> none
#let track(
  /// Ignored; accepted so that any old call reaches the message.
  /// -> arguments
  ..arguments,
) = _shared.fail(
  "grids.track was removed; size the tracks on the split: "
    + "grids.rows(tracks: (auto, 1fr), \"header\", \"body\")",
)
