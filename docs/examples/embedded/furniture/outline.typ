#import "@preview/mosaic:0.0.1" as m

#show: m.setup
#set text(size: 22pt)

// A contents slide is a slide like any other, so its own heading would be the
// first entry in its own outline. `outlined: false` keeps it out.
#m.slide(numbered: false)[
  #heading(outlined: false, bookmarked: false)[Contents]
][
  // A default entry ends in dotted leaders and a page number. On slides that
  // number counts physical frames, not the logical slides the footer shows, so
  // this rule keeps the linked title alone.
  #show outline.entry: it => block(
    below: 0.9em,
    link(it.element.location(), it.body()),
  )

  #outline(title: none, depth: 1)
]

= Methods

== Data

Describe the data and measurements.

= Results

== Estimates

Present the main estimates.
