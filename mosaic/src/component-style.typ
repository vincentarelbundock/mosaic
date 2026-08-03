// Shared semantic roles and style normalization for components.
#import "shared.typ": fail, require-dictionary, reject-unknown-keys
#import "settings.typ": settings-state

#let roles = (
  neutral: (fill: luma(96%), accent: luma(35%), text: black),
  accent: (fill: rgb("#e8f1fb"), accent: rgb("#0072B2"), text: black),
  information: (fill: rgb("#e8f1fb"), accent: rgb("#0072B2"), text: black),
  success: (fill: rgb("#e5f5ee"), accent: rgb("#009E73"), text: black),
  warning: (fill: rgb("#fff8d8"), accent: rgb("#E69F00"), text: black),
  danger: (fill: rgb("#fbe9e5"), accent: rgb("#D55E00"), text: black),
  takeaway: (fill: rgb("#f5eafa"), accent: rgb("#CC79A7"), text: black),
)

#let role(name, contextual: false) = {
  if type(name) != str or name not in roles {
    fail(
      "unknown semantic role " + repr(name) + "; expected "
        + roles.keys().sorted().map(repr).join(", "),
    )
  }
  let fallback = roles.at(name)
  if not contextual {
    fallback
  } else {
    let settings = settings-state.get()
    if settings == none or name not in ("neutral", "accent") {
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
    stroke: 0.8pt + colors.accent,
    radius: 6pt,
    inset: 0.65em,
    align: left,
    text: (fill: colors.text),
  ) + defaults + style
}

#let styled-body(style, body) = {
  let text-style = style.text
  align(style.align, text(..text-style, body))
}
