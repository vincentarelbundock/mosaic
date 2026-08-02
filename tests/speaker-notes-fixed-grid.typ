#import "@local/mosaic:0.0.1" as m

#show: m.setup

#m.slide(
  grid: m.grid.cell(
    id: "fixed",
    content: [FIXED VISUAL #m.note[FIXED CELL NOTE]],
  ),
)

#m.slide(
  grid: m.steps.on(
    "2-",
    m.grid.cell(
      id: "timed-fixed",
      content: [TIMED FIXED VISUAL #m.note[TIMED FIXED NOTE]],
    ),
    before: "removed",
  ),
)

#context {
  assert(counter(page).final().first() == 3)
  let records = query(<mosaic-speaker-notes>).map(it => it.value)
  assert(records.len() == 3)
  assert(records.at(0).notes.map(repr) == (repr([FIXED CELL NOTE]),))
  assert(records.at(1).notes == ())
  assert(records.at(2).notes.map(repr) == (repr([TIMED FIXED NOTE]),))
}