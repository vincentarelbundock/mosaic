#import "@local/mosaic:0.0.3" as mosaic

// An inverted slide paints its ground across the whole page, so a deck that
// reclaims a page margin shows no canvas-colored border around the frame.
// The runner asserts the full-page rectangle in the SVG.
#show: mosaic.setup.with(
  paper: (width: 240pt, height: 135pt),
  margin: 20pt,
  spacing: (inset: 5pt),
)
#set text(size: 7pt)

#mosaic.slide(invert: true)[][Inverted to the page edge]

#context assert(counter(page).final().first() == 1)
