#import "@local/mosaic:0.0.1" as mosaic
#import "../mosaic/src/layout/title.typ": title-metrics, title-stack-content
#import "../mosaic/src/settings.typ": make-settings

// The composed title stack scales as a unit. The display line carries its own
// <mosaic-title-display> label, so the theme's display size lands there rather
// than on the cell; every tier below it is an ordinary em of the cell. A native
// size rule on <mosaic-cell-title> therefore moves title, subtitle, and
// metadata by the same factor, instead of shrinking the title past its own
// subtitle.
#show: mosaic.setup

#let settings = make-settings() + (base-size: 28pt, title-metrics: title-metrics)
#let fields = (
  title: [A title that wraps onto a second line],
  subtitle: [A subtitle tier],
  date: [2027],
  image: none,
  variant: "centered",
  authors: (mosaic.layouts.author("Ada Lovelace"),),
  tracks: auto,
  align: left + bottom,
  rule: true,
  accent: rgb("#d97706"),
  mark-accent: none,
)

// The display size a theme sets, stated the way every shipped theme states it.
#show label("mosaic-title-display"): set text(size: 2em, weight: "semibold")

// The region halves along with the type, so line breaking stays proportional.
#let stack(size, width) = text(
  size: size,
  block(width: width, title-stack-content(fields, settings)),
)

// A quarter, not a half: a tier that failed to follow the cell would still
// leave a half-scale stack close enough to pass, while at a quarter it stands
// out well beyond the tolerance that line breaking accounts for.
#context {
  let full = measure(stack(28pt, 560pt))
  let quarter = measure(stack(7pt, 140pt))
  let ratio = quarter.height / full.height
  assert(
    ratio > 0.225 and ratio < 0.275,
    message: "title stack height ratio " + repr(ratio) + " is not proportional",
  )
}

// The same contract through the public surface: one scoped rule quiets the
// whole stack rather than inverting its tiers.
#mosaic.slide(layout: mosaic.layouts.title(
  title: [Cities after dark],
  variant: "centered",
  subtitle: [Infrastructure, evidence, and life after sunset],
  authors: (mosaic.layouts.author("Amara Johnson"),),
  date: [October 2027],
))

#[
  #show label("mosaic-cell-title"): set text(size: 0.45em)
  #mosaic.slide(layout: mosaic.layouts.title(
    title: [Cities after dark],
    variant: "centered",
    subtitle: [Infrastructure, evidence, and life after sunset],
    authors: (mosaic.layouts.author("Amara Johnson"),),
    date: [October 2027],
  ))
]
