#import "@local/mosaic:0.0.3" as mosaic

// A speaker note written in a layout field is collected like one written in
// a cell body. The automatic section tagline is the case that matters: it
// reaches the section layout as its `subtitle` field, which the resolver
// renders where no content walk can see it.
#show: mosaic.setup.with(
  paper: (width: 160pt, height: 90pt),
  spacing: (inset: 5pt),
)
#set text(size: 7pt)

= Section

Tagline. #mosaic.note[Tagline note]

#mosaic.slide(mosaic.layouts.section(subtitle: [Sub #mosaic.note[Field note]]))[
  = Explicit
]

== Slide

Body. #mosaic.note[Body note]

#context {
  let notes = query(<mosaic-speaker-notes>).map(it => it.value.notes)
  assert(
    notes == (([Tagline note],), ([Field note],), ([Body note],)),
    message: repr(notes),
  )
}
