// A layout's content fields are transparent to Mosaic's own commands. A
// section tagline is the section layout's `subtitle` field, and a pause, a
// step, or a note written there works as it does in a cell body: the runtime
// counts steps over the fields and resolves each frame's layout from the
// fields already transformed for that step.
#import "@local/mosaic:0.0.3" as m

#show: m.setup

// Two pages: a pause and a note in an automatic section tagline.
= Field section

TAGLINEFIRST #m.note[TAGLINE NOTE] #m.steps.pause TAGLINESECOND

// Two pages: steps in the title layout's `title` and `subtitle` fields.
#m.slide(
  layout: "title",
  title: [FIELDTITLE #m.steps.on(2)[TITLESECOND]],
  subtitle: [FIELDSUBTITLE #m.steps.pause SUBTITLESECOND #m.note[SUBTITLE NOTE]],
)

#context {
  assert(counter(page).final().first() == 4)
  let notes = query(<mosaic-speaker-notes>).map(it => it.value.notes)
  assert(notes == (
    ([TAGLINE NOTE],),
    ([TAGLINE NOTE],),
    (),
    ([SUBTITLE NOTE],),
  ), message: repr(notes))
}
