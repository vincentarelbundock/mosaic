// Shared semantic roles, structural defaults, and style normalization for
// components.
#import "../shared.typ": fail, validate-dictionary, validate-keys
#import "../deck-state.typ": deck-settings
#import "../role-defaults.typ": default-roles
#import "../color-defaults.typ": default-colors

#let roles = default-roles

// Geometry every component shares, kept apart from the role palette so a theme
// states its colors without restating its shapes. Before the split, a themed
// component module had to repeat the stroke thickness, radius, and inset just to
// change a fill, and the two copies drifted.
#let component-tokens = (
  stroke-thickness: 0.8pt,
  radius: 6pt,
  inset: 0.65em,
  // The rail a callout hangs its accent on, replacing the full border.
  callout-rail: 4pt,
  divider-gap: 0.45em,
  badge-radius: 3pt,
  badge-inset: (x: 0.7em, y: 0.3em),
  progress-size: 1em,
  progress-thickness: 2pt,
  // A conic gradient starts due east; a progress ring reads from the top.
  progress-start-angle: -90deg,
  quote-attribution-gap: 0.45em,
  quote-attribution-size: 0.72em,
  // How far the quotation's wash is lightened toward the canvas it sits on.
  quote-tint: 94%,
)

// The deck's own colors, for component defaults that should follow the theme
// rather than a fixed value. Components call this inside `context`; outside a
// deck they render in the library's light palette rather than an ad-hoc gray.
#let deck-colors() = {
  let settings = deck-settings()
  if settings == none { default-colors } else { settings.colors }
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
  let settings = deck-settings()
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

#let validate-style(
  style: (:),
  role-name: "neutral",
  defaults: (:),
  contextual: false,
) = {
  _ = validate-dictionary(style, "component style")
  let allowed = (
    "fill", "stroke", "radius", "inset", "align", "text",
  )
  _ = validate-keys(style, allowed, "component style")
  _ = validate-dictionary(style.at("text", default: (:)), "component style text")
  let colors = role(role-name, contextual: contextual)
  (
    fill: colors.fill,
    stroke: component-tokens.stroke-thickness + colors.accent,
    radius: component-tokens.radius,
    inset: component-tokens.inset,
    align: left,
    text: (fill: colors.text),
  ) + defaults + style
}

#let styled-body(style, body) = {
  let text-style = style.text
  align(style.align, text(..text-style, body))
}
