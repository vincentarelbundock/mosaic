// The appendix marker: where the talk ends and the backup slides begin.
#import "shared.typ": fail, tag
#import "deck-state.typ": deck-state

#let appendix-label = label("mosaic-appendix")

// The record the compiler leaves in the flow in place of the marker. The
// totals are the counters read at its location (see `slide-position` in
// deck-state.typ), and only the compiler emits it, so a marker that reaches
// the document by any other road cannot move the totals.
#let appendix-start = [#metadata((mosaic: tag, kind: "appendix-start"))#label("mosaic-appendix-start")]

// The marker means something only to the deck compiler, which consumes it
// whole: the metadata becomes `appendix-start`, and this guard is dropped.
// Realized anywhere else (inside a slide, inside a `context` block or a
// container, or in a document without setup), the guard fails.
#let appendix-guard-label = label("mosaic-appendix-guard")
#let appendix-guard = [#context {
  if deck-state.final() == none {
    fail(
      "appendix requires a deck; apply setup with a show rule, such as "
        + "`#show: mosaic.setup`, before the first slide",
    )
  }
  fail(
    "appendix marks the end of the talk and belongs between slides, at the "
      + "top level of the deck, not inside a slide or a container",
  )
}#appendix-guard-label]

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

#let is-appendix-guard(value) = (
  type(value) == content
    and value.at("label", default: none) == appendix-guard-label
)
