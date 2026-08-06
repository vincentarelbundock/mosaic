#import "@preview/mosaic:0.0.1" as m

#show metadata: it => repr(it.value)
#show: m.setup

#m.slide[
  #block[#m.note[NESTED SECRET NOTE]]
  VISIBLE CONTENT
]

#context {
  let records = query(<mosaic-speaker-notes>).map(it => it.value)
  assert(records.len() == 1)
  assert(records.first().notes.map(repr) == (repr([NESTED SECRET NOTE]),))
}