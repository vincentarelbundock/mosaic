#import "@local/mosaic:0.0.1" as m

#show: m.setup

#m.slide[
  NESTED OUTSIDE
  #block[
    NESTED FIRST
    #m.steps.pause
    NESTED SECOND
  ]
]

#context assert(counter(page).final().first() == 2)
