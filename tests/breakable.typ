// Deck-wide breakable slides. The references slide outgrows one frame and
// continues on two more pages, each repeating the header and the footer, and
// the footer keeps reporting the one logical slide it belongs to. The deck
// default skips what it cannot break: the title slide and the stepped slide
// stay fixed frames. `overflow: "error"` proves the flowing cell is never
// observed, since it has no fixed region to overflow.
#import "@local/mosaic:0.0.3" as mosaic

#show: mosaic.setup.with(
  breakable: true,
  overflow: "error",
  title: [Breakable],
  layouts: (content: mosaic.layouts.content(variant: "header-body-footer")),
  cells: (footer: context [Footer of slide #mosaic.info().slide.number]),
)

#mosaic.slide("title")

== Before
Short.

== References
#for index in range(1, 19) [Entry #index of the references.\ ]

== Stepped
First.
#mosaic.steps.pause
Second.

== After
Short again.
