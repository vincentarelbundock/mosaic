// Shared semantic roles, structural defaults, and style normalization for
// components.
#import "../shared.typ": fail, require-dictionary, reject-unknown-keys
#import "../settings.typ": settings-state
#import "../role-defaults.typ": default-roles

#let roles = default-roles

// Geometry every component shares, kept apart from the role palette so a theme
// states its colors without restating its shapes. Before the split, a themed
// component module had to repeat the stroke thickness, radius, and inset just to
// change a fill, and the two copies drifted.
#let structure = (
  stroke-thickness: 0.8pt,
  radius: 6pt,
  inset: 0.65em,
  // The rail a callout hangs its accent on, replacing the full border.
  callout-rail: 4pt,
  divider-gutter: 0.45em,
  label-radius: 3pt,
  label-inset: (x: 0.7em, y: 0.3em),
  label-compact-inset: (x: 0.55em, y: 0.18em),
  // Any radius at least half the box height rounds the ends completely, so this
  // is a "larger than any label" value rather than a measured one. Named so the
  // magic number is not repeated at every pill call site.
  pill-radius: 999pt,
  progress-size: 1em,
  progress-thickness: 2pt,
  // A conic gradient starts due east; a progress ring reads from the top.
  progress-start-angle: -90deg,
  quote-gutter: 0.6em,
  quote-attribution-gap: 0.45em,
  quote-attribution-size: 0.72em,
  // How far the quotation's wash is lightened toward the canvas it sits on.
  quote-wash: 94%,
)

// The deck's own colors, for component defaults that should follow the theme
// rather than a fixed value. Components call this inside `context`.
#let deck-colors() = {
  let settings = settings-state.get()
  if settings == none { none } else { settings.colors }
}

#let role(name, contextual: false) = {
  if type(name) != str or name not in roles {
    fail(
      "unknown semantic role " + repr(name) + "; expected "
        + roles.keys().sorted().map(repr).join(", "),
    )
  }
  let fallback = roles.at(name)
  if not contextual {
    return fallback
  }
  let settings = settings-state.get()
  if settings == none {
    return fallback
  }
  // A deck (or theme) that states a complete palette is authoritative: its
  // entry is used verbatim, including roles the derivation below never touches.
  if settings.roles != auto {
    return settings.roles.at(name)
  }
  // Otherwise the two roles that mean "the deck's own surface" follow the deck
  // colors, and the semantic roles keep their fixed palette.
  if name not in ("neutral", "accent") {
    fallback
  } else if name == "neutral" {
    (
      fill: settings.colors.surface,
      accent: settings.colors.line,
      text: settings.colors.text,
    )
  } else {
    (
      fill: settings.colors.surface,
      accent: settings.colors.accent,
      text: settings.colors.text,
    )
  }
}

#let normalize-style(
  style: (:),
  role-name: "neutral",
  defaults: (:),
  contextual: false,
) = {
  require-dictionary(style, "component style")
  let allowed = (
    "fill", "stroke", "radius", "inset", "align", "text",
  )
  reject-unknown-keys(style, allowed, "component style")
  require-dictionary(style.at("text", default: (:)), "component style text")
  let colors = role(role-name, contextual: contextual)
  (
    fill: colors.fill,
    stroke: structure.stroke-thickness + colors.accent,
    radius: structure.radius,
    inset: structure.inset,
    align: left,
    text: (fill: colors.text),
  ) + defaults + style
}

#let styled-body(style, body) = {
  let text-style = style.text
  align(style.align, text(..text-style, body))
}
