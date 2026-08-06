#import "@preview/mosaic:0.0.1" as mosaic

#set page(width: 240pt, height: 135pt, margin: 8pt)
#set heading(offset: 1)
#show: mosaic.setup.with(
  spacing: (inset: 8pt),
)
#set text(size: 9pt)

= Offset section

== Offset slide

Source depth, rather than resolved native level, defines the slide boundary.

#context {
  let levels = query(heading).map(it => it.level)
  assert(levels == (2, 3), message: repr(levels))
  assert(counter(page).final().first() == 2)
}
