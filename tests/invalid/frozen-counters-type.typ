#import "@local/mosaic:0.0.3" as mosaic

#show: mosaic.setup.with(
  frozen-counters: (state("not-a-counter", 0),),
)

Invalid frozen counter.
