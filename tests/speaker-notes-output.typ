#import "@local/mosaic:0.0.1" as m

#let output = sys.inputs.at("output", default: "slides")
#show: m.setup.with(output: output)

#m.slide[
  #m.note[GENERAL OUTPUT NOTE]
  #m.steps.reveal(
    [FIRST VISUAL #m.note[FIRST FRAME NOTE]],
    [SECOND VISUAL #m.note[SECOND FRAME NOTE]],
  )
]

#context assert(counter(page).final().first() == 2)