#import "@local/mosaic:0.0.2" as mosaic

// A single reveal body holding list items reveals one item per step, and its
// untimed siblings ride along on every frame. The marker-grid path must keep
// the aside paragraph rather than dropping everything that is not an item.
#set page(width: 160pt, height: 120pt, margin: 5pt)
#show: mosaic.setup.with(spacing: (inset: 5pt))
#set text(size: 7pt)

#mosaic.slide[
  == Reveal
  #mosaic.steps.reveal[
    - ITEM ONE
    UNTIMED ASIDE
    - ITEM TWO
  ]
]

#context {
  assert(counter(page).final().first() == 2)
}
