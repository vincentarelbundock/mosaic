#import "@local/mosaic:0.0.1" as m

#show: m.setup

#m.slide(numbered: false)[#m.note[FIRST UNNUMBERED NOTE] FIRST]
#m.slide(numbered: false)[#m.note[SECOND UNNUMBERED NOTE] SECOND]
#m.slide[#m.note[NUMBERED NOTE] THIRD]

#context {
  let records = query(<mosaic-speaker-notes>).map(it => it.value)
  assert(records.map(it => it.logical-slide) == (1, 2, 3))
}