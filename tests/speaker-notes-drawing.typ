#import "@preview/mosaic:0.0.1" as m

#let renderer(commands) = commands.map(command => [DRAWING SLOT #command]).join()

#show: m.setup

#m.slide[
  VISIBLE DRAWING FRAME
  #m.steps.drawing(
    render: renderer,
    hide: body => hide(body),
    m.note[DRAWING SECRET NOTE],
    block(m.note[NESTED DRAWING SECRET NOTE]),
  )
]

#context {
  let records = query(<mosaic-speaker-notes>).map(it => it.value)
  assert(records.len() == 1)
  assert(records.first().notes.map(repr) == (
    repr([DRAWING SECRET NOTE]),
    repr([NESTED DRAWING SECRET NOTE]),
  ))
}
