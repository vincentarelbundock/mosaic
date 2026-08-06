#import "@preview/mosaic:0.0.1" as mosaic

#show: mosaic.setup.with(
  frozen-counters: (state("not-a-counter", 0),),
)

Invalid frozen counter.
