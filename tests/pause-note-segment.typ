#import "@local/mosaic:0.0.2" as mosaic

// A pause segment holding only a speaker note spans no step of its own, but
// its note must still reach the notes output rather than being dropped from
// the schedule with the segment.
#set page(width: 160pt, height: 120pt, margin: 5pt)
#show: mosaic.setup.with(output: "notes", spacing: (inset: 5pt))
#set text(size: 7pt)

#mosaic.slide[
  == Pauses
  ALPHA
  #mosaic.steps.pause
  #mosaic.note[PAUSE SEGMENT NOTE]
  #mosaic.steps.pause
  BETA
]

#context {
  assert(counter(page).final().first() == 2)
}
