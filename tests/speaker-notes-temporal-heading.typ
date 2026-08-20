#import "@local/mosaic:0.0.2" as mosaic

// A heading inside a speaker note never renders on a slide, so a note tied to
// a frame through `steps.on` may carry one without tripping the
// temporal-heading stability guard.
#set page(width: 160pt, height: 90pt, margin: 5pt)
#show: mosaic.setup.with(spacing: (inset: 5pt))
#set text(size: 7pt)

#mosaic.slide[
  == Stable
  #mosaic.steps.on(2)[LATE CONTENT #mosaic.note[== NOTE HEADING]]
]

#context {
  assert(counter(page).final().first() == 2)
  assert(query(heading).len() == 1)
}
