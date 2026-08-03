#import "../../component-api.typ" as _base
#import "../../shared.typ": fail as _fail
#import "tokens.typ" as _tokens

// `information` aliases `accent`, as in the light palette.
#let _accent-role = (fill: rgb("#13233a"), accent: _tokens.accent, text: _tokens.text)

#let _role-colors = (
  neutral: (fill: _tokens.surface, accent: _tokens.line, text: _tokens.text),
  accent: _accent-role,
  information: _accent-role,
  success: (fill: rgb("#102a22"), accent: rgb("#56d364"), text: _tokens.text),
  warning: (fill: rgb("#2f2710"), accent: _tokens.attention, text: _tokens.text),
  danger: (fill: rgb("#321b1e"), accent: _tokens.error, text: _tokens.text),
  takeaway: (fill: rgb("#241d33"), accent: _tokens.secondary, text: _tokens.text),
)

#let _role(name) = {
  if type(name) != str or name not in _role-colors {
    _fail(
      "unknown semantic role " + repr(name) + "; expected "
        + _role-colors.keys().sorted().map(repr).join(", "),
    )
  }
  _role-colors.at(name)
}
#let _component-style(name) = {
  let colors = _role(name)
  (
    fill: colors.fill,
    stroke: 0.8pt + colors.accent,
    text: (fill: colors.text),
  )
}

#let frame(body, role: "neutral", style: (:), ..args) = _base.frame(
  body,
  role: role,
  style: _component-style(role) + style,
  ..args,
)

#let callout(body, kind: "information", title: none, style: (:)) = {
  let colors = _role(kind)
  frame(
    [
      #if title != none {
        text(weight: "bold", fill: colors.accent)[#title]
        parbreak()
      }
      #body
    ],
    role: kind,
    style: (stroke: (left: 4pt + colors.accent, rest: none)) + style,
  )
}

#let label(
  body,
  role: "neutral",
  radius: 3pt,
  text-style: (:),
  style: (:),
) = _base.label(
  body,
  role: role,
  radius: radius,
  text-style: text-style,
  style: _component-style(role) + style,
)

#let quote(
  body,
  attribution: none,
  portrait: none,
  source: none,
  role: "neutral",
  style: (:),
) = _base.quote(
  body,
  attribution: attribution,
  portrait: portrait,
  source: source,
  role: role,
  style: _component-style(role) + (stroke: none) + style,
)

#let divider(label: none, stroke: 0.8pt + _tokens.line) = _base.divider(
  label: label,
  stroke: stroke,
)

#let progress(
  variant: "1/1",
  count: "slides",
  current: auto,
  total: auto,
  role: "accent",
  width: 100%,
  size: 1em,
  thickness: 2pt,
  track: auto,
  color: auto,
) = {
  let colors = _role-colors.at(role)
  _base.progress(
    variant: variant,
    count: count,
    current: current,
    total: total,
    role: role,
    width: width,
    size: size,
    thickness: thickness,
    track: if track == auto { _tokens.line } else { track },
    color: if color == auto { colors.accent } else { color },
  )
}

#import "../../component-api.typ": image
