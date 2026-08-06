// A cell that states no inset of its own must take `settings.spacing.inset`.
// Regression: `styled-cell` used to inject a literal `1.25em`, which silently
// outranked the configured token and made `spacing.inset` a no-op for cells.
#import "../mosaic/src/grid/constructors.typ": cell, styled-cell
#import "../mosaic/src/grid/render.typ": configured-inset
#import "../mosaic/src/settings.typ": default-spacing, make-settings
#import "../mosaic/src/deck-record.typ": configure-deck

// The constructor defers rather than deciding.
#assert(styled-cell(id: "body").style.inset == auto)
#assert(cell("body").style.inset == auto)
// An explicit inset still wins, including one passed through `styled-cell`.
#assert(cell("body", inset: 4pt).style.inset == 4pt)
#assert(styled-cell(id: "body", style: (inset: 9pt)).style.inset == 9pt)

// Outside `setup` there is no deck to read, so the library default applies.
#context assert(configured-inset() == default-spacing.inset)

#configure-deck(settings: make-settings(spacing: (inset: 33pt)))
#context assert(configured-inset() == 33pt)

Cell inset follows setup spacing.
