#import "@local/mosaic:0.0.2" as mosaic

// A heading built with `heading(level: ..)` carries `level` rather than
// `depth`; the compiler must classify it like its markup twin instead of
// aborting on the absent field.
#set page(width: 160pt, height: 90pt, margin: 5pt)
#show: mosaic.setup.with(spacing: (inset: 5pt))
#set text(size: 7pt)

== First

A

#heading(level: 2)[Constructed]

B

#context {
  assert(counter(page).final().first() == 2)
  assert(query(heading).len() == 2)
}
