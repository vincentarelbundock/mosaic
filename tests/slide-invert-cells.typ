#import "@local/mosaic:0.0.2" as mosaic

// An inverted slide knocks its type out in the canvas color even where the
// theme pins a text fill on a cell label (the Metropolis title), and
// components resolve their colors from the inverted palette rather than the
// deck record.
#show: mosaic.themes.metropolis.setup.with(title: "INVERTED TITLE WORDS")

#mosaic.slide(layout: "title", invert: true)

#mosaic.slide(invert: true)[
  == Inverted Content
  INVERTED BODY INK
  #mosaic.components.quote(attribution: [WHO])[QUOTED LINE]
]

#context {
  assert(counter(page).final().first() == 2)
}
