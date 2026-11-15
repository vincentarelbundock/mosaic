// Steps and pauses inside the native containers a slide is made of. Each one
// is rebuilt around the content this frame shows; scripts/run-tests.py asserts
// which words reach which page.
#import "@local/mosaic:0.0.3" as m

#show: m.setup

// One page: `place` at its default alignment carries no alignment field.
#m.slide[][
  PLACEHOST
  #place[PLACEDEFAULT]
  #place(dx: 1cm, dy: 2cm)[PLACEOFFSET]
]

// Two pages each from here on.
#m.slide[][
  #table(
    columns: 2,
    table.header[TABLEHEAD][#m.steps.on(2)[TABLEHEADSECOND]],
    [TABLEFIRST],
    table.cell(m.steps.on(2)[TABLESECOND]),
  )
]

#m.slide[][
  / TERMFIRST: #m.steps.on(2)[TERMSECOND]
]

#m.slide[][
  #rect[RECTFIRST #m.steps.pause RECTSECOND]
  #circle(radius: 3em)[#m.steps.on(2)[CIRCLESECOND]]
]

#m.slide[][
  #rotate(2deg)[ROTATEFIRST #m.steps.pause ROTATESECOND]
  #scale(90%)[#m.steps.on(2)[SCALESECOND]]
  #move(dx: 1em)[#m.steps.on(2)[MOVESECOND]]
]

#m.slide[][
  #columns(2)[COLUMNFIRST #m.steps.on(2)[COLUMNSECOND]]
  #par[PARFIRST #m.steps.on(2)[PARSECOND]]
]

#m.slide[][
  $ ("MATHFIRST" + #m.steps.on(2)[$"FRACSECOND"$]) / 2 $
  $ sqrt(#m.steps.on(2)[$"ROOTSECOND"$]) + x^(#m.steps.on(2)[$"ATTACHSECOND"$]) $
]

#m.slide[][
  #figure(
    rect[FIGUREBODY],
    caption: [CAPTIONFIRST #m.steps.on(2)[CAPTIONSECOND]],
  )
]

// A heading's own body resolves its steps on the frame that carries the real
// heading as well as on the continuation.
#m.slide[][
  === HEADINGHOST #m.steps.on(1)[HEADINGFIRST]#m.steps.on(2)[HEADINGSECOND]
  HEADINGBODY
]

#context assert(counter(page).final().first() == 17)
