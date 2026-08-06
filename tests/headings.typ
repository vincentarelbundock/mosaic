#import "@preview/mosaic:0.0.1" as mosaic

#set page(width: 160pt, height: 90pt, margin: 5pt)
#show: mosaic.setup.with(
  spacing: (inset: 5pt),
)
#set text(size: 7pt)
#show heading.where(depth: 1): set text(size: 1.9em)

= Section

== First

A #mosaic.steps.on("2-")[B]

=== Detail

C

== Second

#mosaic.steps.replace[X][Y]

#context assert(counter(page).final().first() == 5)
