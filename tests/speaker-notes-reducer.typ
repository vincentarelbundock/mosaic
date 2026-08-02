#import "@local/mosaic:0.0.1" as m

#let renderer(commands) = commands.map(command => [REDUCER SLOT #command]).join()

#show: m.setup

#m.slide[
  VISIBLE REDUCER FRAME
  #m.steps.reduce(
    render: renderer,
    hide: body => hide(body),
    m.note[REDUCER SECRET NOTE],
    block(m.note[NESTED REDUCER SECRET NOTE]),
  )
]

#context {
  let records = query(<mosaic-speaker-notes>).map(it => it.value)
  assert(records.len() == 1)
  assert(records.first().notes.map(repr) == (
    repr([REDUCER SECRET NOTE]),
    repr([NESTED REDUCER SECRET NOTE]),
  ))
}
