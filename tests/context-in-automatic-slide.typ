#import "@local/mosaic:0.0.3" as mosaic

// A `context` block a deck writes in an automatic slide is content like any
// other: it renders, before and after an explicit slide command, whose
// trailing setup guard is the only `context` element the compiler consumes.
#show: mosaic.setup.with(
  paper: (width: 160pt, height: 90pt),
  spacing: (inset: 5pt),
)
#set text(size: 7pt)

== First

Before #context [CONTEXT-ONE] after.

#mosaic.slide[Explicit #context [CONTEXT-TWO]]

== Second

#context [CONTEXT-THREE]
