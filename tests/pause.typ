#import "@preview/mosaic:0.0.1" as m
#import m.steps: pause

#show: m.setup

#m.slide[
  PAUSE FIRST
  #pause
  PAUSE SECOND
  #pause
  PAUSE THIRD
]

#context assert(counter(page).final().first() == 3)
