// The appendix marker: where the talk ends and the backup slides begin.
#import "shared.typ": fail, tag
#import "deck-state.typ": deck-state

#let appendix-label = label("mosaic-appendix")

// Like a slide command, the marker means something only to the deck compiler,
// which drops this guard; realized anywhere else, the guard fails when no deck
// was configured. It carries the slide command guard's label, which is what
// the compiler recognizes.
#let appendix-guard = [#context {
  if deck-state.final() == none {
    fail(
      "appendix requires a deck; apply setup with a show rule, such as "
        + "`#show: mosaic.setup`, before the first slide",
    )
  }
}#label("mosaic-setup-guard")]

/// Marks where the talk ends and the backup slides begin.
///
/// Write it once, between two slides:
///
/// ```typ
/// == Conclusion
/// Thank you.
///
/// #mosaic.appendix
///
/// == Robustness checks
/// ```
///
/// The slides and sections after the marker keep counting, but the totals stop
/// at the marker, so a footer reads "12 / 30" through the talk and "31 / 30" on
/// the first backup slide. A progress indicator stays full on backup slides,
/// and the `toc` section variant lists only the sections before the marker.
/// `info()` reports the same totals.
///
/// The marker is content, not a function: write `#mosaic.appendix`, with no
/// parentheses. It belongs between slides; inside a slide it is an error, and
/// a second marker is an error too.
///
/// -> content
#let appendix = [#metadata((mosaic: tag, kind: "appendix"))#appendix-label#appendix-guard]

#let is-appendix-marker(value) = (
  type(value) == content
    and value.func() == metadata
    and value.at("label", default: none) == appendix-label
)
