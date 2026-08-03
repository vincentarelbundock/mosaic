// Position indicator driven by the deck's logical slide and section counters.
#import "../shared.typ": fail
#import "../deck-state.typ": logical-slide, logical-section
#import "style.typ": role as component-role

/// Displays progress through logical slides or semantic sections in the deck.
///
/// The `1/1` variant displays the current and final values, `1` displays only
/// the current value, `circle` draws a compact progress ring, and `line` draws
/// a full-width track.
/// Set `count` to `sections` to use slides with `layout: "section"`.
/// Explicit `current` and `total` values can be supplied together when the
/// component should represent another sequence; they override `count`.
///
/// -> content
#let progress(
  /// Visual treatment: `1/1`, `1`, `circle`, or `line`.
  /// -> str
  variant: "1/1",
  /// Automatic counter: `slides` or `sections`.
  /// -> str
  count: "slides",
  /// Current position, or `auto` to use the selected counter.
  /// -> auto | int
  current: auto,
  /// Final position, or `auto` to use the selected counter's final value.
  /// -> auto | int
  total: auto,
  /// Semantic role used for the active color.
  /// -> str
  role: "accent",
  /// Width of the line variant.
  /// -> length | relative | fraction
  width: 100%,
  /// Diameter of the circle variant.
  /// -> length
  size: 1em,
  /// Thickness of the circle or line.
  /// -> length
  thickness: 2pt,
  /// Inactive track color; `auto` uses the role's background color.
  /// -> auto | color | gradient | tiling
  track: auto,
  /// Active indicator color; `auto` uses the role's accent color.
  /// -> auto | color
  color: auto,
) = context {
  if type(variant) != str or variant not in ("1/1", "1", "circle", "line") {
    fail("progress variant must be \"1/1\", \"1\", \"circle\", or \"line\"")
  }
  if type(count) != str or count not in ("slides", "sections") {
    fail("progress count must be \"slides\" or \"sections\"")
  }
  if (current == auto) != (total == auto) {
    fail("progress current and total must either both be auto or both be set")
  }
  let automatic-counter = if count == "slides" {
    logical-slide
  } else {
    logical-section
  }
  let current = if current == auto {
    automatic-counter.get().first()
  } else {
    current
  }
  let total = if total == auto {
    automatic-counter.final().first()
  } else {
    total
  }
  if (
    type(current) != int
      or type(total) != int
      or total < 1
      or current < 0
      or current > total
  ) {
    fail("progress requires integers satisfying 0 <= current <= total and total >= 1")
  }
  let colors = component-role(role, contextual: true)
  let track = if track == auto { colors.fill } else { track }
  let active = if color == auto { colors.accent } else { color }
  let amount = 100% * current / total

  if variant == "1/1" {
    text(fill: active)[#current/#total]
  } else if variant == "1" {
    text(fill: active)[#current]
  } else if variant == "circle" {
    box(circle(
      width: size,
      height: size,
      fill: none,
      stroke: thickness + gradient.conic(
        (active, 0%),
        (active, amount),
        (track, amount),
        (track, 100%),
        angle: -90deg,
        space: rgb,
      ),
    ))
  } else {
    block(width: width, height: thickness)[
      #place(top + left, rect(
        width: 100%,
        height: thickness,
        fill: track,
      ))
      #place(top + left, rect(
        width: amount,
        height: thickness,
        fill: active,
      ))
    ]
  }
}
