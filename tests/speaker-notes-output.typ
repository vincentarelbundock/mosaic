#import "@local/mosaic:0.0.2" as m

#let output = sys.inputs.at("output", default: "slides")
#show: m.setup.with(output: output)

#m.slide[
  // The probe reads the weight the note body actually renders at. The frame
  // heading's label sets bold, and a label on a bare sequence used to carry
  // that bold into every printed output but `speaker`.
  #m.note[GENERAL OUTPUT NOTE weight=#context repr(text.weight)]
  #m.steps.reveal(
    [FIRST VISUAL #m.note[FIRST FRAME NOTE]],
    [SECOND VISUAL #m.note[SECOND FRAME NOTE]],
  )
]

#context assert(counter(page).final().first() == 2)