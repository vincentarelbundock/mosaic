#import "@local/mosaic:0.0.2" as m

#show: m.setup

#m.slide[
  #m.note[ALWAYS NOTE]
  COMPOSE FIRST

  #m.steps.pause

  #m.steps.reveal(
    [COMPOSE SECOND #m.note[SECOND NOTE]],
    [COMPOSE THIRD #m.note[THIRD NOTE]],
  )
]

#context {
  let records = query(<mosaic-speaker-notes>).map(it => it.value)
  assert(counter(page).final().first() == 3)
  assert(records.len() == 3)
  assert(records.at(0).notes == ([ALWAYS NOTE],))
  assert(records.at(1).notes == ([ALWAYS NOTE], [SECOND NOTE]))
  assert(records.at(2).notes == (
    [ALWAYS NOTE],
    [SECOND NOTE],
    [THIRD NOTE],
  ))
}
