// The title layout's visual recipe is named and overridable, and the display
// line is a labeled tier a theme styles natively.
#import "@local/mosaic:0.0.1" as mosaic
#import "../mosaic/src/layout/title.typ": title-metrics, title-style

// The measurements that used to be literals in the variants are all named.
#assert(title-metrics.accent-rule-length == 1.6)
#assert(title-metrics.accent-rule-thickness == 0.12)
#assert(title-metrics.overlay-opacity == 30%)
#assert(title-metrics.image-tracks == (2fr, 3fr))
#assert(title-metrics.side-reserve == 35%)

// Overrides merge over the defaults; unstated fields survive.
#let tuned = title-style((accent-rule-length: 3))
#assert(tuned.accent-rule-length == 3)
#assert(tuned.accent-rule-thickness == title-metrics.accent-rule-thickness)

#show: mosaic.setup.with(
  title: [Tuned title],
  subtitle: [With a longer accent rule],
  authors: (mosaic.layouts.author("Ada Lovelace"),),
  date: [2026-08-04],
)

// The display size lives on its own label, so the subordinate tiers below it
// are ordinary em multiples that do not compound with it.
#show label("mosaic-title-display"): set text(tracking: 0.01em)

#mosaic.slide(
  layout: "title",
  variant: "swiss",
  style: (accent-rule-length: 3, subtitle-gap: 1.2),
)

#mosaic.slide[
  == Check
  #context assert(query(label("mosaic-title-display")).len() == 1)
]
