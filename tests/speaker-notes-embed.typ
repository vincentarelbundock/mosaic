// The embedded pdfpc payload: notes travel inside the PDF on the `slides`
// output, keyed by the physical page each note is visible on.
#import "@local/mosaic:0.0.2" as m

#show: m.setup

#m.slide[
  #m.note[EMBED FIRST NOTE]
  FIRST VISUAL
]

// No note at all, so this page must not appear in the payload.
#m.slide[
  SECOND VISUAL
]

// A step-scoped note belongs to the frame it describes, which is the fourth
// page of the deck rather than the third.
#m.slide[
  #m.steps.reveal(
    [THIRD VISUAL],
    [FOURTH VISUAL #m.note[EMBED FRAME NOTE]],
  )
]

// Two notes on one slide accumulate into that page's single note body.
#m.slide[
  #m.note[EMBED PAIR ONE]
  #m.note[EMBED PAIR TWO]
  FIFTH VISUAL
]

#context assert(counter(page).final().first() == 5)
