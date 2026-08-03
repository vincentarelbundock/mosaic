#import "@local/mosaic:0.0.1" as m

#show: m.setup.with(handout: true)

#m.slide[
  PAUSE HANDOUT FIRST
  #m.pause
  PAUSE HANDOUT SECOND
  #m.pause
  PAUSE HANDOUT FINAL
]

#context assert(counter(page).final().first() == 1)
