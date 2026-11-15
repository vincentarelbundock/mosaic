// A component is transparent to Mosaic's own commands: a pause, a step, or a
// note written in its body (or its title, attribution, or caption) is counted,
// applied per frame, and collected, as it is in a native container.
// scripts/run-tests.py asserts which words reach which page.
#import "@local/mosaic:0.0.3" as m

#show: m.setup.with(overflow: "off")

// Three pages: a pause in a card, and a step in a card nested inside it. The
// nested step is counted from the pause, as any step after a pause is.
#m.slide[][
  #m.components.card[
    CARDFIRST #m.note[CARD NOTE]
    #m.steps.pause
    CARDSECOND
    #m.components.card[NESTEDFIRST #m.steps.on(2)[NESTEDLATER]]
  ] <labeled-card>
]

// Three pages: a step in a callout's title, a revealed list in its body.
#m.slide[][
  #m.components.callout(title: [TITLEFIRST #m.steps.on(2)[TITLESECOND]])[
    #m.steps.reveal[
      - REVEALONE
      - REVEALTWO
      - REVEALTHREE
    ]
  ]
]

// Two pages: a quotation in a native table cell, with a note in its
// attribution; a badge; a divider's title.
#m.slide[][
  #table(
    columns: 1,
    m.components.quote(attribution: [QUOTEWHO #m.note[QUOTE NOTE]])[
      QUOTEFIRST #m.steps.on(2)[QUOTESECOND]
    ],
  )
  #m.components.badge[BADGEFIRST #m.steps.on(2)[BADGESECOND]]
  #m.components.divider(title: [DIVIDERFIRST #m.steps.on(2)[DIVIDERSECOND]])
]

// Two pages: a figure's content body and its caption.
#m.slide[][
  #m.components.figure(
    rect[FIGUREFIRST #m.steps.on(2)[FIGURESECOND]],
    caption: [CAPTIONFIRST #m.steps.on(2)[CAPTIONSECOND]],
    height: 30%,
  )
]

#context {
  assert(counter(page).final().first() == 10)
  let notes = query(<mosaic-speaker-notes>).map(it => it.value.notes)
  // The card's note sits before its pause, so it is on all three frames; the
  // quotation's note is untimed, so it is on both of that slide's.
  assert(notes.slice(0, 3).all(it => it == ([CARD NOTE],)), message: repr(notes))
  assert(notes.slice(3, 6).all(it => it == ()), message: repr(notes))
  assert(notes.slice(6, 8).all(it => it == ([QUOTE NOTE],)), message: repr(notes))
  // A label written after the component stays on it, on every frame.
  assert(query(<labeled-card>).len() == 3)
}
