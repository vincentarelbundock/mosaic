#import "@local/mosaic:0.0.1" as mosaic

#show: mosaic.setup.with(handout: false)

#mosaic.slide[
  #mosaic.steps.replace([ORDINARY FIRST], [ORDINARY FINAL])
]

#context assert(counter(page).final().first() == 2)
