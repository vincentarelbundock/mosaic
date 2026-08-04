// A section variant's visual recipe is named and overridable, and the text
// tiers it emits are reachable by native show rules.
#import "@local/mosaic:0.0.1" as mosaic
#import "../mosaic/src/layout/section.typ": section-styles, variant-style

// Every designed variant has a complete recipe rather than buried literals.
#assert(section-styles.rule.rule-thickness == 0.16em)
#assert(section-styles.numeral.number-size == 6.8em)
#assert(section-styles.toc.item-size == 0.64em)

// Overrides merge over the variant's defaults; unstated fields survive.
#let tuned = variant-style("rule", (rule-thickness: 1pt))
#assert(tuned.rule-thickness == 1pt)
#assert(tuned.number-size == section-styles.rule.number-size)

// The image variants compose their text like `plain`, so they share its entry.
#assert(variant-style("image-left", (:)) == section-styles.plain)

#show: mosaic.setup.with(
  layouts: (section: mosaic.layouts.section(
    variant: "rule",
    style: (number-size: 2em, gap-below-rule: 1em),
  )),
)

// The labeled tiers are targetable without touching the composition.
#show label("mosaic-section-number"): set text(style: "italic")
#show label("mosaic-section-subtitle"): set text(weight: "bold")

= Tuned Section
Subtitle under the rule

#mosaic.slide[
  == Check
  #context {
    assert(query(label("mosaic-section-number")).len() == 1)
    assert(query(label("mosaic-section-subtitle")).len() == 1)
  }
]
