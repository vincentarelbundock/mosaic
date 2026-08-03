// Native Typst content components for common presentation patterns.
#import "shared.typ": fail, require-dictionary
#import "deck-state.typ": logical-slide, logical-section
#import "component-style.typ": (
  role as component-role,
  normalize-style,
  styled-body,
)

/// Wraps content in a clipped, semantically styled block.
///
/// -> content
#let frame(
  /// Content inside the frame.
  /// -> content
  body,
  /// Semantic role name.
  /// -> str
  role: "neutral",
  /// Component-style overrides.
  /// -> dictionary
  style: (:),
  /// Native block width.
  /// -> auto | length | relative | fraction
  width: auto,
  /// Native block height.
  /// -> auto | length | relative | fraction
  height: auto,
) = context {
  let it = normalize-style(style: style, role-name: role, contextual: true)
  block(
    width: width,
    height: height,
    fill: it.fill,
    stroke: it.stroke,
    radius: it.radius,
    inset: it.inset,
    clip: true,
    styled-body(it, body),
  )
}

/// Creates a framed callout with a semantic side stripe.
///
/// -> content
#let callout(
  /// Callout content.
  /// -> content
  body,
  /// Semantic role name.
  /// -> str
  kind: "information",
  /// Optional bold title.
  /// -> content | none
  title: none,
  /// Component-style overrides.
  /// -> dictionary
  style: (:),
) = context {
  let colors = component-role(kind, contextual: true)
  frame(
    [
      #if title != none {
        text(weight: "bold", fill: colors.accent)[#title]
        parbreak()
      }
      #body
    ],
    role: kind,
    style: (
      stroke: (left: 4pt + colors.accent, rest: none),
    ) + style,
  )
}

#let _compact(body, role, style, radius: 999pt) = context {
  let it = normalize-style(
    style: style,
    role-name: role,
    contextual: true,
    defaults: (radius: radius, inset: (x: 0.55em, y: 0.18em)),
  )
  box(
    fill: it.fill,
    stroke: it.stroke,
    radius: it.radius,
    inset: it.inset,
    styled-body(it, body),
  )
}

/// Creates a compact inline label.
///
/// -> content
#let label(
  /// Label content.
  /// -> content
  body,
  /// Semantic role name.
  /// -> str
  role: "neutral",
  /// Corner radius.
  /// -> length | dictionary
  radius: 3pt,
  /// Native text styling arguments.
  /// -> dictionary
  text-style: (:),
  /// Component-style overrides.
  /// -> dictionary
  style: (:),
) = {
  require-dictionary(text-style, "label text-style")
  let text-style = style.at("text", default: (:)) + text-style
  _compact(
    body,
    role,
    (inset: (x: 0.7em, y: 0.3em))
      + style
      + (radius: radius, text: text-style),
    radius: radius,
  )
}
/// Creates a quotation treatment with optional portrait and attribution.
///
/// -> content
#let quote(
  /// Quotation content.
  /// -> content
  body,
  /// Optional author or speaker.
  /// -> content | none
  attribution: none,
  /// Optional content placed beside the quotation.
  /// -> content | none
  portrait: none,
  /// Optional source appended to the attribution.
  /// -> content | none
  source: none,
  /// Semantic role name.
  /// -> str
  role: "neutral",
  /// Component-style overrides.
  /// -> dictionary
  style: (:),
) = frame(
  role: role,
  style: (
    fill: black.transparentize(94%),
    stroke: none,
  ) + style,
)[
  #grid(
    columns: if portrait == none { (1fr,) } else { (auto, 1fr) },
    gutter: 0.6em,
    ..if portrait == none { (body,) } else { (portrait, body) },
  )
  #if attribution != none or source != none {
    [#linebreak() #align(right)[
      #text(size: 0.72em)[
        #if attribution != none { attribution }
        #if attribution != none and source != none { [, ] }
        #if source != none { source }
      ]
    ]]
  }
]

/// Creates a horizontal divider, optionally split around a label.
///
/// -> content
#let divider(
  /// Optional centered label.
  /// -> content | none
  label: none,
  /// Stroke used for both line segments.
  /// -> stroke
  stroke: 0.8pt + gray,
) = grid(
  columns: if label == none { (1fr,) } else { (1fr, auto, 1fr) },
  gutter: 0.45em,
  align: horizon,
  ..if label == none {
    (line(length: 100%, stroke: stroke),)
  } else {
    (
      line(length: 100%, stroke: stroke),
      label,
      line(length: 100%, stroke: stroke),
    )
  },
)

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
