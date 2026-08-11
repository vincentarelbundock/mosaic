#import "@local/mosaic:0.0.2" as m

#show: m.setup

#m.slide[
  #m.steps.pause
  #m.steps.pause
  EMPTY MARKER VISUAL
  #m.steps.pause
  #m.steps.pause
]

#context assert(counter(page).final().first() == 1)
