#import "@local/mosaic:0.0.1" as m

#show: m.setup

#m.slide(
  layout: m.grid.cell(
    id: "fixed",
    content: [
      FIXED STREAM FIRST #m.note[FIXED FIRST NOTE]
      #m.pause
      FIXED STREAM SECOND #m.note[FIXED SECOND NOTE]
    ],
  ),
  content: (
    background: [
      BACKGROUND STREAM FIRST
      #m.pause
      BACKGROUND STREAM SECOND
    ],
    foreground: [
      FOREGROUND STREAM FIRST
      #m.pause
      FOREGROUND STREAM SECOND
    ],
  ),
)

#context {
  assert(counter(page).final().first() == 2)
  let records = query(<mosaic-speaker-notes>).map(it => it.value)
  assert(records.len() == 2)
  assert(records.at(0).notes == ([FIXED FIRST NOTE],))
  assert(records.at(1).notes == (
    [FIXED FIRST NOTE],
    [FIXED SECOND NOTE],
  ))
}
