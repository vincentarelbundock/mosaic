// Passive starter definition: design values and native rules only.
#import "_starter-layouts.typ" as layouts

#let _navy = rgb("#1f2a44")
#let _gold = rgb("#d9a441")

#let apply(body, colors: (:), options: (:)) = {
  show list.where(tight: true): it => list(tight: false, ..it.children)
  set list(spacing: 0.9em)
  show label("mosaic-cell-section"): it => block(
    width: 100%, height: 100%, fill: colors.accent, it,
  )
  body
}
#let definition = (
  name: "Starter",
  colors: (
    canvas: rgb("#f4f1ea"),
    surface: white,
    text: _navy,
    muted: _navy.lighten(25%),
    line: _navy.lighten(55%),
    accent: _gold,
  ),
  text: (size: 20pt),
  normalize-lists: false,
  layouts: (
    content: layouts.content(),
    title: layouts.title(),
    section: layouts.section(),
  ),
  apply: apply,
)
