#import "@local/mosaic:0.0.2" as m
#show: m.setup
#set page(fill: rgb("#f4f0e8"))
#set text(fill: rgb("#20262d"))

// Two rules per cell: one for the text inside it, one for the block around it.
// Header and footer sit in `auto` tracks, so the paint takes `height: auto`
// and hugs the line each one carries.
#let ink = rgb("#20262d")
#let paper = white

#show label("mosaic-cell-header"): set text(fill: paper)
#show label("mosaic-cell-header"): set block(fill: ink)
#show label("mosaic-cell-footer"): set text(fill: paper)
#show label("mosaic-cell-footer"): set block(fill: ink)

#let myslide = m.slide.with(
  layout: m.layouts.content(),
)

#myslide[
  == Inverted header and footer
][
  #lorem(36)
][
  Both regions share one pair of ordinary Typst color bindings.
]
