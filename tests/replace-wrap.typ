// `replace` measures its alternatives at the width the slot is offered, so
// prose wraps inside the cell instead of running off the slide, and the slot
// stays inline when its alternatives are short.
#import "@local/mosaic:0.0.3" as m

#show: m.setup

#m.slide[
  #m.steps.replace(
    [#lorem(40) #metadata(none) <replace-end>],
    [#lorem(12)],
  )
]

#m.slide[
  INLINE-BEFORE #m.steps.replace[short][a longer one] #box(place[#metadata(none) <inline-after>])
]

#context {
  assert(counter(page).final().first() == 4)
  let end = query(<replace-end>).first().location().position()
  assert(end.x < page.width, message: repr(end))
  // The slot sits on the line it was written in: what follows it is to its
  // right, not below it.
  let after = query(<inline-after>).first().location().position()
  assert(after.x > 8cm, message: repr(after))
}
