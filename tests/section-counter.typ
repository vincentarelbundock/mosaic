#import "@local/mosaic:0.0.1" as mosaic

#set page(width: 240pt, height: 135pt, margin: 8pt)
#show: mosaic.setup.with(spacing: (inset: 8pt))
#set text(size: 9pt)

// A semantic section layout increments the dedicated counter automatically.
#mosaic.slide(grid: mosaic.layouts.section())[
  First section
  #mosaic.components.progress(variant: "1/1", count: "sections")
]

// Custom section layouts opt in explicitly and are independent of slide
// numbering. Incremental frames must still represent one section.
#mosaic.slide(section: true, numbered: false)[
  Custom section
  #mosaic.steps.reveal[One][Two][Three]
  #mosaic.components.progress(variant: "1/1", count: "sections")
]

// Ordinary slides retain the active section without incrementing it.
#mosaic.slide[
  Body
  #mosaic.components.progress(variant: "line", count: "slides")
]

#context assert(counter(page).final().first() == 5)