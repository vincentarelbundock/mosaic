// The default semantic role palette: the colors a component paints with when a
// deck states no palette of its own.
//
// These live outside `component/style.typ` so a theme can supply a complete
// replacement through `setup`, and outside `settings.typ` so the component
// modules can read them without importing settings in a cycle. A role is three
// colors: the surface it fills, the accent it draws rails and rules in, and the
// text that sits on the fill.
#import "shared.typ": fail

// `information` is a spelling of `accent`, not a role of its own: same
// treatment, clearer intent at the call site. Binding them to one value keeps
// them from drifting apart.
#let accent-role = (fill: rgb("#e8f1fb"), accent: rgb("#0072B2"), text: black)

#let default-roles = (
  neutral: (fill: luma(96%), accent: luma(35%), text: black),
  accent: accent-role,
  information: accent-role,
  success: (fill: rgb("#e5f5ee"), accent: rgb("#009E73"), text: black),
  warning: (fill: rgb("#fff8d8"), accent: rgb("#E69F00"), text: black),
  danger: (fill: rgb("#fbe9e5"), accent: rgb("#D55E00"), text: black),
  takeaway: (fill: rgb("#f5eafa"), accent: rgb("#CC79A7"), text: black),
)

#let role-names = default-roles.keys().sorted()
#let role-fields = ("accent", "fill", "text")

// `auto` means "derive from the deck's own colors", which is what an unthemed
// deck and the passive light-family themes want. An explicit dictionary is a
// complete palette and is used verbatim, which is what a theme with its own
// component look (Dark) supplies.
#let validate-roles(value, name: "setup roles") = {
  if value == auto {
    return value
  }
  if type(value) != dictionary or value.keys().sorted() != role-names {
    fail(
      name + " must be auto or a dictionary with the roles "
        + role-names.map(repr).join(", "),
    )
  }
  for (role-name, entry) in value {
    if (
      type(entry) != dictionary
        or entry.keys().sorted() != role-fields
        or not entry.values().all(field => type(field) == color)
    ) {
      fail(
        name + " " + role-name + " must have the colors "
          + role-fields.map(repr).join(", "),
      )
    }
  }
  value
}
