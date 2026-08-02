// Shared semantic roles and style normalization for components.
#import "shared.typ": fail, require-dictionary, reject-unknown-keys

#let roles = (
  neutral: (fill: luma(96%), accent: luma(35%), text: black),
  accent: (fill: rgb("#e8f1fb"), accent: rgb("#0072B2"), text: black),
  information: (fill: rgb("#e8f1fb"), accent: rgb("#0072B2"), text: black),
  success: (fill: rgb("#e5f5ee"), accent: rgb("#009E73"), text: black),
  warning: (fill: rgb("#fff8d8"), accent: rgb("#E69F00"), text: black),
  danger: (fill: rgb("#fbe9e5"), accent: rgb("#D55E00"), text: black),
  takeaway: (fill: rgb("#f5eafa"), accent: rgb("#CC79A7"), text: black),
)

#let role(name) = {
  if type(name) != str or name not in roles {
    fail(
      "unknown semantic role " + repr(name) + "; expected "
        + roles.keys().sorted().map(repr).join(", "),
    )
  }
  roles.at(name)
}

#let normalize-style(style: (:), role-name: "neutral", defaults: (:)) = {
  require-dictionary(style, "component style")
  let allowed = (
    "fill", "stroke", "radius", "inset", "align", "text",
  )
  reject-unknown-keys(style, allowed, "component style")
  require-dictionary(style.at("text", default: (:)), "component style text")
  let colors = role(role-name)
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
