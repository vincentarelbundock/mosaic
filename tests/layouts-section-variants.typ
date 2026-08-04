// The designed section variants compile through both authoring paths: an
// automatic `=` heading under a configured variant, and explicit slides
// selecting each variant by name. The trailing assertion guards against the
// heading being realized more than once by the variant treatment, which would
// duplicate outline entries.
#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup.with(
  title: [Section variants],
  layouts: (section: mosaic.layouts.section(variant: "baseline")),
)

= Automatic Baseline
Tagline under the rule

#mosaic.slide(layout: "section", variant: "rule", subtitle: [Rule subtitle])[Rule Section]

#mosaic.slide(layout: "section", variant: "numeral")[Numeral Section]

#mosaic.slide(layout: "section", variant: "toc")[Toc Section]

#mosaic.slide[
  == Closing
  #context {
    let headings = query(heading.where(level: 1, outlined: true))
    assert(
      headings.len() == 1,
      message: "expected exactly one realized section heading, found "
        + str(headings.len()),
    )
    let sections = query(label("mosaic-section-title"))
    assert(
      sections.len() == 4,
      message: "expected four section-title records, found "
        + str(sections.len()),
    )
  }
]
