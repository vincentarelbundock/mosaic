// The text the embedded pdfpc payload carries for a note with markup in it.
// Flattening keeps the words of styled runs, symbols, escapes, term lists,
// and math; scripts/run-tests.py asserts the exact string.
#import "@local/mosaic:0.0.3" as m

#show: m.setup

#m.slide[][
  FLATTEN VISUAL
  #m.note[
    Say #text(fill: red)[THIS] and #strong[that], cost \$5 -- maybe... 50#sym.percent.
    #[#set text(blue); SCOPED]

    / Term: description
    - bullet

    $x^2 / y$
  ]
]
