#import "@local/mosaic:0.0.1" as mosaic

#let frozen-counter = counter("mosaic-handout-frozen")
#let frozen-state = state("mosaic-handout-frozen-state", 0)
#let native-counter = counter("mosaic-handout-native")
#let native-state = state("mosaic-handout-native-state", 0)
#let command-list = mosaic.reduce.with(
  render: values => values.join(" | "),
  hide: values => values,
)

#show: mosaic.setup.with(
  handout: true,
  frozen-counters: (frozen-counter,),
  frozen-states: (frozen-state,),
)

#let tick = {
  frozen-counter.step()
  frozen-state.update(value => value + 1)
  native-counter.step()
  native-state.update(value => value + 1)
}

#mosaic.slide[
  #tick
  #mosaic.replace([REPLACE FIRST], [REPLACE FINAL])
  HANDOUT STEP #mosaic.step-number(total: true)
]

#mosaic.slide[
  #mosaic.reveal[REVEAL FIRST][REVEAL FINAL]
]

#mosaic.slide[
  ON BASE
  #mosaic.on(2, before: "removed")[ON FINAL]
]

#mosaic.slide[
  #command-list((
    [REDUCER BASE],
    mosaic.on(2, [REDUCER FINAL]),
  ))
]

#mosaic.slide(
  background: mosaic.replace(
    [#place(top + left, dx: 30pt, dy: 20pt)[BACKGROUND FIRST]],
    [#place(top + left, dx: 30pt, dy: 20pt)[BACKGROUND FINAL]],
  ),
  foreground: mosaic.replace(
    [#move(dx: 500pt, dy: 20pt)[FOREGROUND FIRST]],
    [#move(dx: 500pt, dy: 20pt)[FOREGROUND FINAL]],
  ),
)[#align(center + horizon)[PLANE BODY]]

#mosaic.slide[
  STATIC FINAL: frozen #context frozen-counter.get().first()/#context frozen-state.get(); native #context native-counter.get().first()/#context native-state.get().
]

#context assert(counter(page).final().first() == 6)
