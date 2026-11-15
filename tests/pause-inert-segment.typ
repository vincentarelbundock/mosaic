// A stretch between two pauses that holds only spacing has nothing to reveal
// and mints no frame.
#import "@local/mosaic:0.0.3" as m

#show: m.setup

#m.slide[
  INERT FIRST
  #m.steps.pause
  #v(1em)
  #m.steps.pause
  #h(1em) \
  #m.steps.pause
  INERT SECOND
]

#context assert(counter(page).final().first() == 2)
