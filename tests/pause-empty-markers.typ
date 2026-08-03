#import "@local/mosaic:0.0.1" as m

#show: m.setup

#m.slide[
  #m.pause
  #m.pause
  EMPTY MARKER VISUAL
  #m.pause
  #m.pause
]

#context assert(counter(page).final().first() == 1)
