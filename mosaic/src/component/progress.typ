// Position indicator driven by the deck's logical slide and section counters.
#import "../shared.typ": fail
#import "../deck-state.typ": logical-slide, logical-section
#import "style.typ": role as component-role, structure

/// Displays progress through logical slides or semantic sections in the deck.
///
/// It reads the deck's own counters, so it needs no arguments in the ordinary
/// case. The usual home for it is a setup-level footer default, which puts one
/// indicator on every slide that has a footer.
///
/// ```typ
/// #show: mosaic.setup.with(
///   content: (
///     footer: align(right, mosaic.components.progress()),
///   ),
/// )
/// ```
///
/// *Variants*
///
/// - `1/1`: the current and final values, as text. The default.
/// - `1`: the current value alone.
/// - `circle`: a compact ring filling clockwise, sized by `size` and
///   `thickness`.
/// - `line`: a horizontal track filling left to right, sized by `width` and
///   `thickness`.
///
/// *What it counts*
///
/// `count` selects the automatic counter: `slides` counts logical slides, and
/// `sections` counts slides with `layout: "section"`.
///
/// To represent something else entirely, give `current` and `total` explicitly.
/// They override `count`, and must be supplied together.
///
/// ```typ
/// #mosaic.components.progress(variant: "line", current: 3, total: 8)
/// ```
///
/// -> content
#let progress(
  /// Visual treatment: `"1/1"`, `"1"`, `"circle"`, `"line"`, or a function
  /// drawing one. A renderer is called with a dictionary holding `current`,
  /// `total`, `amount`, `active`, `track`, `width`, `size`, and `thickness`,
  /// and returns the content to place.
  ///
  /// ```typ
  /// #mosaic.components.progress(
  ///   variant: state => grid(
  ///     columns: state.total,
  ///     ..range(state.total).map(i => rect(
  ///       height: state.thickness,
  ///       fill: if i < state.current { state.active } else { state.track },
  ///     )),
  ///   ),
  /// )
  /// ```
  /// -> str | function
  variant: "1/1",
  /// Which automatic counter to read: `"slides"` or `"sections"`. Ignored when
  /// `current` and `total` are given.
  /// -> str
  count: "slides",
  /// Current position, or `auto` to read the selected counter. Must be given
  /// together with `total`.
  /// -> auto | int
  current: auto,
  /// Final position, or `auto` to read the selected counter's final value. Must
  /// be given together with `current`.
  /// -> auto | int
  total: auto,
  /// Semantic role supplying the default colors: `accent`, `neutral`,
  /// `information`, `success`, `warning`, `danger`, or `takeaway`. The role's
  /// accent paints the active part and its fill paints the track.
  /// -> str
  role: "accent",
  /// Width of the `line` variant.
  /// -> length | relative | fraction
  width: 100%,
  /// Diameter of the `circle` variant.
  /// -> length
  size: structure.progress-size,
  /// Stroke thickness of the `circle` and `line` variants.
  /// -> length
  thickness: structure.progress-thickness,
  /// Color of the inactive remainder. `auto` uses the role's fill.
  /// -> auto | color | gradient | tiling
  track: auto,
  /// Color of the completed portion, and of the text variants. `auto` uses the
  /// role's accent.
  /// -> auto | color
  color: auto,
) = context {
  if type(variant) != function and (
    type(variant) != str or variant not in ("1/1", "1", "circle", "line")
  ) {
    fail(
      "progress variant must be \"1/1\", \"1\", \"circle\", \"line\", or a "
        + "renderer function",
    )
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

  // A renderer receives everything the built-in treatments draw from, so an
  // extension theme can add a treatment without forking this component.
  if type(variant) == function {
    return variant((
      current: current,
      total: total,
      amount: amount,
      active: active,
      track: track,
      width: width,
      size: size,
      thickness: thickness,
    ))
  }
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
        angle: structure.progress-start-angle,
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
