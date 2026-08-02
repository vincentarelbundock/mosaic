#import "../../setup.typ": setup as base-setup
#import "../../component-api.typ" as components
#import "../setup-common.typ": configured-options, normalize-lists
#import "layouts.typ" as layouts
#import "tokens.typ" as tokens

/// Sets up Mosaic with Metropolis typography, native cell rules, and layouts.
#let setup(
  body,
  font: "Fira Sans",
  font-mono: "Fira Mono",
  base-size: 21.5pt,
  ..options,
) = {
  let configured = configured-options("Metropolis", layouts, options, defaults: (
    paper: "16-9",
  ))

  show: base-setup.with(..configured)
  show: normalize-lists
  set page(fill: tokens.paper)
  set text(font: font, size: base-size, fill: tokens.ink)
  show raw: set text(font: font-mono)
  show raw.where(block: false): set text(size: 1.125em)
  show raw.where(block: true): set text(size: 0.65em)

  show heading.where(depth: 2): set text(size: 0.75em, weight: "regular")
  show label("mosaic-cell-header"): it => block(
    width: 100%,
    fill: tokens.ink,
    text(fill: tokens.paper, weight: "medium", it),
  )
  show label("mosaic-cell-body"): set align(horizon)
  show label("mosaic-cell-title"): set text(fill: tokens.ink)
  show label("mosaic-cell-section"): set align(left + horizon)
  show label("mosaic-cell-section"): set text(
    size: base-size,
    weight: "regular",
  )
  show label("mosaic-cell-section"): it => block(width: 100%)[
    #it
    #v(0.4em)
    #components.progress(
      variant: "line",
      count: "sections",
      width: 100%,
      thickness: 3.01pt,
      track: tokens.track,
      color: tokens.orange,
    )
  ]
  body
}
