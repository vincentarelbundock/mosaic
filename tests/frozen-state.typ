#import "@local/mosaic:0.0.1" as mosaic

#let frozen-counter = counter("mosaic-test-frozen-counter")
#let frozen-state = state("mosaic-test-frozen-state", 0)
#let native-counter = counter("mosaic-test-native-counter")
#let native-state = state("mosaic-test-native-state", 0)

#show: mosaic.setup.with(
  frozen-counters: (frozen-counter,),
  frozen-states: (frozen-state,),
)

#let tick(name) = {
  frozen-counter.step()
  frozen-state.update(value => value + 1)
  native-counter.step()
  native-state.update(value => value + 1)
  [#name: frozen #context frozen-counter.get().first()/#context frozen-state.get(); native #context native-counter.get().first()/#context native-state.get()]
}

#mosaic.slide[
  #tick("Reveal")
  #mosaic.steps.reveal[First frame][Second frame]
]

#mosaic.slide[
  #tick("On")
  #mosaic.steps.on(2)[Second frame]
]

#mosaic.slide[
  #tick("Replace")
  #mosaic.steps.replace([First frame], [Second frame])
]

#mosaic.slide[
  Final: frozen #context frozen-counter.get().first()/#context frozen-state.get(); native #context native-counter.get().first()/#context native-state.get().
]
