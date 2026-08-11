#import "@local/mosaic:0.0.2" as m
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
