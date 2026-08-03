#import "@local/mosaic:0.0.1" as m

#show: m.setup

#m.slide[
  #m.note[GENERAL NOTE ONE]
  VISIBLE FRAME
  #m.steps.reveal(
    [FIRST STATE #m.note[FIRST REVEAL NOTE]],
    [SECOND STATE #m.note[SECOND REVEAL NOTE]],
  )
  #m.note[GENERAL NOTE TWO]
  #m.steps.on("2-", before: "removed")[
    #m.note[SECOND FRAME NOTE]
  ]
  #m.steps.on("5-", before: "removed")[
    #m.note[LATE NOTE MUST NOT CREATE A FRAME]
  ]
]

== Automatic heading slide
#m.note[AUTOMATIC SLIDE NOTE]
HEADING SLIDE BODY

== Note-free slide
NOTE-FREE SLIDE BODY

#m.slide(
  layout: m.grid.h("left", "right"),
  content: (
    left: [#m.note[FIRST CELL NOTE] FIRST CELL],
    right: [#m.note[SECOND CELL NOTE] SECOND CELL],
    background: m.note[BACKGROUND NOTE],
    foreground: m.note[FOREGROUND NOTE],
  ),
)

#context {
  assert(counter(page).final().first() == 5)
  let records = query(<mosaic-speaker-notes>).map(it => it.value)
  assert(records.len() == 5)
  assert(records.map(it => it.logical-slide) == (1, 1, 2, 3, 4))
  assert(records.map(it => it.frame) == (1, 2, 1, 1, 1))
  assert(records.at(0).notes.map(repr) == (
    "[GENERAL NOTE ONE]",
    "[FIRST REVEAL NOTE]",
    "[GENERAL NOTE TWO]",
  ))
  assert(records.at(1).notes.map(repr) == (
    "[GENERAL NOTE ONE]",
    "[FIRST REVEAL NOTE]",
    "[SECOND REVEAL NOTE]",
    "[GENERAL NOTE TWO]",
    "[SECOND FRAME NOTE]",
  ))
  assert(records.at(2).notes.map(repr) == (repr([AUTOMATIC SLIDE NOTE]),))
  assert(records.at(3).notes == ())
  assert(records.at(4).notes.map(repr) == (
    repr([FIRST CELL NOTE]),
    repr([SECOND CELL NOTE]),
    repr([BACKGROUND NOTE]),
    repr([FOREGROUND NOTE]),
  ))
}
