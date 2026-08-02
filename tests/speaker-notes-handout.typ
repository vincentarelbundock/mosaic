#import "@local/mosaic:0.0.1" as m

#let output = sys.inputs.at("output", default: "slides")
#show: m.setup.with(handout: true, output: output)

#m.slide[
  #m.note[GENERAL HANDOUT NOTE]
  #m.steps.reveal(
    [FIRST HANDOUT FRAME #m.note[FIRST HANDOUT NOTE]],
    [FINAL HANDOUT FRAME #m.note[FINAL HANDOUT NOTE]],
  )
]

#context {
  assert(counter(page).final().first() == 1)
  let records = query(<mosaic-speaker-notes>).map(it => it.value)
  assert(records.len() == 1)
  assert(records.first().frame == 2)
  assert(records.first().notes.map(repr) == (
    "[GENERAL HANDOUT NOTE]",
    "[FIRST HANDOUT NOTE]",
    "[FINAL HANDOUT NOTE]",
  ))
}